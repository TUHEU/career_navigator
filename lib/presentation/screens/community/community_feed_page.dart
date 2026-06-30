// presentation/screens/community/community_feed_page.dart — v10
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/posts_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/loading_widgets.dart';

class CommunityFeedPage extends StatefulWidget {
  const CommunityFeedPage({super.key});
  @override
  State<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  static const _cats = [
    ('All',           ''),
    ('Career Advice', 'career_advice'),
    ('Job Search',    'job_search'),
    ('Success Story', 'success_story'),
    ('Skill Tips',    'skill_tip'),
    ('Questions',     'question'),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _cats.length, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) return;
      context.read<PostsProvider>().loadPosts(category: _cats[_tab.index].$2);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostsProvider>().loadPosts();
    });
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  void _showCreatePost() {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AppColors.surface(isDark),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _CreatePostSheet(isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final posts  = context.watch<PostsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Community', style: TextStyle(
                color: AppColors.text(isDark), fontSize: 24,
                fontWeight: FontWeight.bold)),
              Text('Connect · Share · Grow', style: TextStyle(
                color: AppColors.textMuted(isDark), fontSize: 12)),
            ])),
            GestureDetector(
              onTap: _showCreatePost,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryCyan,
                  borderRadius: BorderRadius.circular(12)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_rounded, color: Colors.black, size: 16),
                  SizedBox(width: 4),
                  Text('Post', style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                ]),
              ),
            ),
          ]),
        ),
        TabBar(
          controller: _tab,
          isScrollable: true, tabAlignment: TabAlignment.start,
          labelColor: AppColors.primaryCyan,
          unselectedLabelColor: AppColors.textMuted(isDark),
          indicatorColor: AppColors.primaryCyan, indicatorWeight: 2,
          dividerColor: AppColors.border(isDark),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: _cats.map((c) => Tab(text: c.$1)).toList(),
        ),
        Expanded(child: posts.isLoading
          ? const LoadingIndicator(message: 'Loading posts...')
          : posts.posts.isEmpty
            ? _EmptyFeed(isDark: isDark, onPost: _showCreatePost)
            : RefreshIndicator(
                color: AppColors.primaryCyan,
                onRefresh: () => posts.loadPosts(category: _cats[_tab.index].$2),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: posts.posts.length,
                  itemBuilder: (_, i) {
                    final post = posts.posts[i];
                    final myName = context.read<AuthProvider>().currentUser?.fullName;
                    return _PostCard(
                      post: post, isDark: isDark,
                      onLike: () => posts.toggleLike(post.id),
                      onDelete: myName == post.authorName
                          ? () => posts.deletePost(post.id)
                          : null,
                    );
                  },
                ),
              ),
        ),
      ])),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post; final bool isDark;
  final VoidCallback onLike;
  final VoidCallback? onDelete;
  const _PostCard({required this.post, required this.isDark,
    required this.onLike, this.onDelete});

  Color _catColor(String cat) {
    switch (cat) {
      case 'career_advice':  return const Color(0xFF00B8D4);
      case 'job_search':     return const Color(0xFF7C3AED);
      case 'success_story':  return const Color(0xFF059669);
      case 'skill_tip':      return const Color(0xFFF59E0B);
      case 'question':       return const Color(0xFFEC4899);
      default:               return const Color(0xFF6B7B99);
    }
  }

  String _catLabel(String cat) => cat.replaceAll('_', ' ')
      .split(' ').map((w) => w.isNotEmpty
          ? w[0].toUpperCase() + w.substring(1) : '').join(' ');

  @override
  Widget build(BuildContext context) {
    final color = _catColor(post.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(isDark))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryCyan.withOpacity(0.15),
              backgroundImage: post.authorPicture != null
                  ? CachedNetworkImageProvider(post.authorPicture!) : null,
              child: post.authorPicture == null
                  ? Text(post.authorName.isNotEmpty
                      ? post.authorName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.primaryCyan, fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(post.authorName, style: TextStyle(
                color: AppColors.text(isDark), fontWeight: FontWeight.bold, fontSize: 14)),
              Text(timeago.format(post.createdAt), style: TextStyle(
                color: AppColors.textMuted(isDark), fontSize: 11)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.3))),
              child: Text(_catLabel(post.category), style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.bold))),
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18)),
            ],
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(post.content, style: TextStyle(
            color: AppColors.text(isDark), fontSize: 14, height: 1.6))),
        if (post.tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Wrap(spacing: 6, children: post.tags.map((t) => Text(
              '#$t', style: const TextStyle(
                color: AppColors.primaryCyan, fontSize: 12,
                fontWeight: FontWeight.w500))).toList())),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(children: [
            _ActionBtn(
              icon: post.likedByMe
                  ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
              label: '${post.likesCount}',
              color: post.likedByMe
                  ? const Color(0xFFEC4899) : AppColors.textMuted(isDark),
              onTap: onLike),
            const SizedBox(width: 16),
            _ActionBtn(
              icon: Icons.chat_bubble_outline_rounded,
              label: '${post.commentsCount}',
              color: AppColors.textMuted(isDark), onTap: () {}),
            const Spacer(),
            _ActionBtn(
              icon: Icons.share_outlined, label: 'Share',
              color: AppColors.textMuted(isDark), onTap: () {}),
          ])),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon; final String label;
  final Color color; final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label,
    required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(
        color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _CreatePostSheet extends StatefulWidget {
  final bool isDark;
  const _CreatePostSheet({required this.isDark});
  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _ctrl = TextEditingController();
  String _category = 'general';
  bool _posting = false;
  static const _cats = [
    ('General', 'general'), ('Career Advice', 'career_advice'),
    ('Job Search', 'job_search'), ('Success Story', 'success_story'),
    ('Skill Tip', 'skill_tip'), ('Question', 'question'),
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _post() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _posting = true);
    final ok = await context.read<PostsProvider>().createPost(
      content: _ctrl.text.trim(), category: _category);
    if (mounted) {
      setState(() => _posting = false);
      if (ok) {
        Navigator.pop(context);
        Helpers.showSnackBar(context, '🎉 Post published!');
      } else {
        Helpers.showSnackBar(context, 'Failed to post', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: AppColors.border(isDark),
            borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 18),
        Text('Create Post', style: TextStyle(
          color: AppColors.text(isDark), fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: _cats.map((c) {
            final sel = _category == c.$2;
            return GestureDetector(
              onTap: () => setState(() => _category = c.$2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primaryCyan.withOpacity(0.15)
                      : AppColors.card(isDark),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel
                      ? AppColors.primaryCyan : AppColors.border(isDark))),
                child: Text(c.$1, style: TextStyle(
                  color: sel ? AppColors.primaryCyan : AppColors.textMuted(isDark),
                  fontSize: 12, fontWeight: FontWeight.w600))));
          }).toList()),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _ctrl, maxLines: 5, autofocus: true,
          style: TextStyle(color: AppColors.text(isDark), fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Share something with the community...',
            hintStyle: TextStyle(color: AppColors.textMuted(isDark)),
            filled: true, fillColor: AppColors.card(isDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primaryCyan))),
        ),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity,
          child: ElevatedButton(
            onPressed: _posting ? null : _post,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCyan, foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: _posting
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('Publish', style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
          )),
      ]),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  final bool isDark; final VoidCallback onPost;
  const _EmptyFeed({required this.isDark, required this.onPost});
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.people_outline_rounded, size: 72, color: AppColors.textMuted(isDark)),
      const SizedBox(height: 16),
      Text('No posts yet', style: TextStyle(
        color: AppColors.text(isDark), fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Text('Be the first to share something!', style: TextStyle(
        color: AppColors.textMuted(isDark), fontSize: 13)),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: onPost,
        icon: const Icon(Icons.add_rounded, color: Colors.black),
        label: const Text('Create Post',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryCyan,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    ],
  ));
}
