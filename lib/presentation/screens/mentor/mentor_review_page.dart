import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';

class MentorReviewPage extends StatefulWidget {
  final int mentorId;
  final String mentorName;

  const MentorReviewPage({
    super.key,
    required this.mentorId,
    required this.mentorName,
  });

  @override
  State<MentorReviewPage> createState() => _MentorReviewPageState();
}

class _MentorReviewPageState extends State<MentorReviewPage> {
  final _api = ApiService();
  final _reviewCtrl = TextEditingController();

  List<Map<String, dynamic>> _reviews = [];
  double? _avgRating;
  int _totalReviews = 0;
  int _myRating = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasReviewed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final token = await context.read<AuthProvider>().getAccessToken() ?? '';
      final uid = context.read<AuthProvider>().currentUser?.id;
      final res = await _api.getRequest(
        '/mentors/${widget.mentorId}/reviews',
        token,
      );
      if (mounted && res['success'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        final list = List<Map<String, dynamic>>.from(data['reviews'] ?? []);
        setState(() {
          _reviews = list;
          _avgRating = data['avg_rating'] != null
              ? (data['avg_rating'] as num).toDouble()
              : null;
          _totalReviews = data['total'] as int? ?? 0;
          // Check if current user already reviewed
          if (uid != null) {
            final mine = list.where((r) => r['reviewer_id'] == uid).toList();
            if (mine.isNotEmpty) {
              _hasReviewed = true;
              _myRating = mine.first['rating'] as int? ?? 0;
              _reviewCtrl.text = mine.first['review'] as String? ?? '';
            }
          }
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (_myRating == 0) {
      Helpers.showSnackBar(context, 'Please select a rating', isError: true);
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final token = await context.read<AuthProvider>().getAccessToken() ?? '';
      final res = await _api.postRequest(
        '/mentors/${widget.mentorId}/reviews',
        token,
        {'rating': _myRating, 'review': _reviewCtrl.text.trim()},
      );
      if (mounted) {
        if (res['success'] == true) {
          Helpers.showSnackBar(context, 'Review submitted!');
          _load();
        } else {
          Helpers.showSnackBar(
            context,
            res['message'] ?? 'Failed',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) Helpers.showSnackBar(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Star selector ─────────────────────────────────────────
  Widget _starSelector() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(5, (i) {
      final star = i + 1;
      return GestureDetector(
        onTap: () => setState(() => _myRating = star),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            star <= _myRating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: star <= _myRating
                ? const Color(0xFFFFC107)
                : Colors.grey.shade400,
            size: 44,
          ),
        ),
      );
    }),
  );

  // ── Rating bar ────────────────────────────────────────────
  Widget _ratingBar(bool isDark) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.card(isDark),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border(isDark)),
    ),
    child: Row(
      children: [
        Column(
          children: [
            Text(
              _avgRating != null ? _avgRating!.toStringAsFixed(1) : '—',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.text(isDark),
              ),
            ),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < (_avgRating ?? 0).round()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: const Color(0xFFFFC107),
                  size: 16,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$_totalReviews review${_totalReviews == 1 ? '' : 's'}',
              style: TextStyle(
                color: AppColors.textMuted(isDark),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: List.generate(5, (i) {
              final star = 5 - i;
              final count = _reviews
                  .where((r) => (r['rating'] as int?) == star)
                  .length;
              final pct = _totalReviews > 0 ? count / _totalReviews : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text(
                      '$star',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted(isDark),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: const Color(0xFFFFC107),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 6,
                          backgroundColor: AppColors.border(
                            isDark,
                          ).withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFFFFC107),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted(isDark),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    ),
  );

  // ── Review card ───────────────────────────────────────────
  Widget _reviewCard(Map<String, dynamic> r, bool isDark) {
    final rating = r['rating'] as int? ?? 0;
    final review = r['review'] as String? ?? '';
    final name = r['reviewer_name'] as String? ?? 'User';
    final picture = r['reviewer_picture'] as String?;
    final date = r['created_at'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
                backgroundImage: picture != null ? NetworkImage(picture) : null,
                child: picture == null
                    ? Text(
                        Helpers.getInitials(name),
                        style: const TextStyle(
                          color: AppColors.primaryCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: AppColors.text(isDark),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      Helpers.getRelativeTime(date),
                      style: TextStyle(
                        color: AppColors.textMuted(isDark),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFFFC107),
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          if (review.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review,
              style: TextStyle(
                color: AppColors.textSecondary(isDark),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: Text('${widget.mentorName} — Reviews'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primaryCyan,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Rating overview ──────────────────────
                  _ratingBar(isDark),
                  const SizedBox(height: 24),

                  // ── Write review ─────────────────────────
                  Text(
                    _hasReviewed ? 'Update Your Review' : 'Write a Review',
                    style: TextStyle(
                      color: AppColors.text(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _starSelector(),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _reviewCtrl,
                    maxLines: 4,
                    style: TextStyle(color: AppColors.text(isDark)),
                    decoration: InputDecoration(
                      hintText: 'Share your experience with this mentor...',
                      hintStyle: TextStyle(color: AppColors.textMuted(isDark)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      filled: true,
                      fillColor: AppColors.inputFill(isDark),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryCyan,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              _hasReviewed ? 'Update Review' : 'Submit Review',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Reviews list ─────────────────────────
                  if (_reviews.isNotEmpty) ...[
                    Text(
                      'All Reviews ($_totalReviews)',
                      style: TextStyle(
                        color: AppColors.text(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._reviews.map((r) => _reviewCard(r, isDark)),
                  ] else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No reviews yet.\nBe the first to review!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textMuted(isDark)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
