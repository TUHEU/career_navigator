import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';

class AIResponseWidget extends StatefulWidget {
  final String text;
  final bool isStreaming;
  final bool hasResult;
  final String title;
  final Color accentColor;

  const AIResponseWidget({
    super.key,
    required this.text,
    required this.isStreaming,
    required this.hasResult,
    required this.title,
    this.accentColor = AppColors.primaryCyan,
  });

  @override
  State<AIResponseWidget> createState() => _AIResponseWidgetState();
}

class _AIResponseWidgetState extends State<AIResponseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorCtrl;
  late Animation<double> _cursorAnim;

  @override
  void initState() {
    super.initState();
    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _cursorAnim = Tween<double>(begin: 0, end: 1).animate(_cursorCtrl);
  }

  @override
  void dispose() {
    _cursorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (widget.text.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isStreaming
              ? widget.accentColor.withValues(alpha: 0.4)
              : AppColors.border(isDark),
          width: widget.isStreaming ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    widget.isStreaming
                        ? Icons.stream
                        : (widget.hasResult
                              ? Icons.auto_awesome
                              : Icons.error_outline),
                    color: widget.isStreaming
                        ? widget.accentColor
                        : (widget.hasResult ? widget.accentColor : Colors.red),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isStreaming
                        ? 'Grok is thinking...'
                        : (widget.hasResult ? widget.title : 'Error'),
                    style: TextStyle(
                      color: AppColors.text(isDark),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              // Copy button when done
              if (!widget.isStreaming && widget.hasResult)
                IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 16),
                  color: AppColors.textMuted(isDark),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.text));
                    Helpers.showSnackBar(context, 'Copied to clipboard!');
                  },
                ),
            ],
          ),

          // Streaming progress bar
          if (widget.isStreaming) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                backgroundColor: widget.accentColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(widget.accentColor),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Text content + blinking cursor
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: AppColors.textSecondary(isDark),
                fontSize: 13,
                height: 1.7,
                fontFamily: 'Roboto',
              ),
              children: [
                TextSpan(text: widget.text),
                if (widget.isStreaming)
                  WidgetSpan(
                    child: AnimatedBuilder(
                      animation: _cursorAnim,
                      builder: (_, _) => Opacity(
                        opacity: _cursorAnim.value,
                        child: Text(
                          '▋',
                          style: TextStyle(
                            color: widget.accentColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
