// data/datasources/remote/grok_stream_service.dart
// AI streaming via the Career Navigator backend proxy.
// The AI API key (DeepSeek / xAI / OpenAI) lives in server .env ONLY.
// This file contains ZERO API keys — the Flutter app never sees them.
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../local/token_store.dart';

class GrokStreamService {
  static const String _endpoint =
      '${AppConstants.baseUrl}${ApiEndpoints.aiStream}';

  /// Streams AI responses through the backend proxy (JWT-authenticated).
  /// Works with any provider configured in backend .env:
  ///   AI_PROVIDER=deepseek  → DeepSeek V3 (default)
  ///   AI_PROVIDER=xai       → Grok-3
  ///   AI_PROVIDER=openai    → GPT-4o
  static Future<void> stream({
    required String prompt,
    required void Function(String chunk) onChunk,
    required void Function() onDone,
    required void Function(String error) onError,
    int maxTokens = 1000,
    String systemPrompt =
        'You are a professional career advisor AI assistant.',
  }) async {
    // Token read automatically — no need to pass it from the screen
    final token = await TokenStore().getAccess() ?? '';

    try {
      final request = http.Request('POST', Uri.parse(_endpoint));
      request.headers.addAll({
        'Content-Type':  'application/json',
        'Authorization': 'Bearer $token',
        'Accept':        'text/event-stream',
      });
      request.body = jsonEncode({
        'prompt':        prompt,
        'system_prompt': systemPrompt,
        'max_tokens':    maxTokens.clamp(100, 2000),
      });

      final client   = http.Client();
      final response = await client.send(request).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          client.close();
          throw Exception('Request timed out');
        },
      );

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        String msg  = 'Server error ${response.statusCode}';
        try {
          final obj = jsonDecode(body) as Map<String, dynamic>;
          msg = obj['message'] as String? ?? msg;
        } catch (_) {}
        onError(msg);
        client.close();
        return;
      }

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        for (final line in chunk.split('\n')) {
          final t = line.trim();
          if (t.isEmpty || !t.startsWith('data: ')) continue;
          final data = t.substring(6);

          // Server-forwarded error
          if (data.startsWith('{')) {
            try {
              final obj = jsonDecode(data) as Map<String, dynamic>;
              if (obj.containsKey('error')) {
                onError(obj['error'] as String? ?? 'Unknown AI error');
                client.close();
                return;
              }
            } catch (_) {}
          }

          if (data == '[DONE]') {
            onDone();
            client.close();
            return;
          }

          try {
            final j       = jsonDecode(data) as Map<String, dynamic>;
            final choices = j['choices'] as List?;
            if (choices == null || choices.isEmpty) continue;
            final delta   = (choices[0] as Map)['delta'] as Map?;
            final content = delta?['content'] as String?;
            if (content != null && content.isNotEmpty) onChunk(content);
            final finish  = (choices[0] as Map)['finish_reason'];
            if (finish != null && finish != 'null') {
              onDone();
              client.close();
              return;
            }
          } catch (_) {}
        }
      }

      onDone();
      client.close();
    } catch (e) {
      onError('Connection error: $e');
    }
  }
}
