// providers/posts_provider.dart — v10 Community Feed
import 'package:flutter/material.dart';
import '../data/datasources/remote/api_service.dart';
import '../data/datasources/local/token_store.dart';

class Post {
  final int id;
  final String content;
  final String category;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final bool likedByMe;
  final String authorName;
  final String? authorPicture;
  final String authorRole;
  final DateTime createdAt;
  final List<String> tags;

  const Post({
    required this.id,
    required this.content,
    required this.category,
    this.imageUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.likedByMe,
    required this.authorName,
    this.authorPicture,
    required this.authorRole,
    required this.createdAt,
    required this.tags,
  });

  factory Post.fromJson(Map<String, dynamic> j) => Post(
    id:            (j['id'] as num?)?.toInt() ?? 0,
    content:       j['content'] as String? ?? '',
    category:      j['category'] as String? ?? 'general',
    imageUrl:      j['image_url'] as String?,
    likesCount:    (j['likes_count'] as num?)?.toInt() ?? 0,
    commentsCount: (j['comments_count'] as num?)?.toInt() ?? 0,
    likedByMe:     (j['liked_by_me'] as num?)?.toInt() == 1,
    authorName:    j['author_name'] as String? ?? 'User',
    authorPicture: j['author_picture'] as String?,
    authorRole:    j['author_role'] as String? ?? 'job_seeker',
    createdAt:     DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
    tags:          (j['tags'] is List) ? List<String>.from(j['tags'] as List) : [],
  );

  Post copyWith({int? likesCount, bool? likedByMe}) => Post(
    id: id, content: content, category: category, imageUrl: imageUrl,
    likesCount: likesCount ?? this.likesCount,
    commentsCount: commentsCount,
    likedByMe: likedByMe ?? this.likedByMe,
    authorName: authorName, authorPicture: authorPicture,
    authorRole: authorRole, createdAt: createdAt, tags: tags,
  );
}

class PostsProvider extends ChangeNotifier {
  final _api   = ApiService();
  final _store = TokenStore();

  List<Post> _posts   = [];
  bool _loading       = false;
  bool _creating      = false;
  String? _error;
  String _category    = '';

  List<Post> get posts    => _posts;
  bool get isLoading      => _loading;
  bool get isCreating     => _creating;
  String? get error       => _error;

  Future<void> loadPosts({String category = ''}) async {
    _loading  = true;
    _category = category;
    _error    = null;
    notifyListeners();
    try {
      final token = await _store.getAccess() ?? '';
      final res   = await _api.getPosts(token: token, category: category);
      if (res['success'] == true) {
        final list = res['data'] as List<dynamic>? ?? [];
        _posts = list.map((e) => Post.fromJson(e as Map<String,dynamic>)).toList();
      } else {
        _error = res['message'] as String? ?? 'Failed to load posts';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost({required String content, required String category, List<String> tags = const []}) async {
    _creating = true; notifyListeners();
    try {
      final token = await _store.getAccess() ?? '';
      final res   = await _api.createPost(
        token: token, content: content,
        category: category, tags: tags,
      );
      if (res['success'] == true) {
        await loadPosts(category: _category);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _creating = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(int postId) async {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final post = _posts[idx];
    // Optimistic update
    _posts[idx] = post.copyWith(
      likedByMe:  !post.likedByMe,
      likesCount: post.likedByMe ? post.likesCount - 1 : post.likesCount + 1,
    );
    notifyListeners();
    try {
      final token = await _store.getAccess() ?? '';
      if (post.likedByMe) {
        await _api.unlikePost(token: token, postId: postId);
      } else {
        await _api.likePost(token: token, postId: postId);
      }
    } catch (_) {
      // Revert on failure
      _posts[idx] = post;
      notifyListeners();
    }
  }

  Future<bool> deletePost(int postId) async {
    try {
      final token = await _store.getAccess() ?? '';
      final res   = await _api.deletePost(token: token, postId: postId);
      if (res['success'] == true) {
        _posts.removeWhere((p) => p.id == postId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
