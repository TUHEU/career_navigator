import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../providers/theme_provider.dart';

// ── Quiz data ─────────────────────────────────────────────────
class _Question {
  final String question;
  final List<String> options;
  final int correct; // index
  final String category;
  final String explanation;

  const _Question({
    required this.question,
    required this.options,
    required this.correct,
    required this.category,
    required this.explanation,
  });
}

// ── Built-in question bank ────────────────────────────────────
const List<_Question> _questionBank = [
  _Question(
    question: 'What does REST stand for in API design?',
    options: [
      'Remote Execution Service Transfer',
      'Representational State Transfer',
      'Resource Endpoint Standard Type',
      'Relational Server Technology',
    ],
    correct: 1,
    category: 'Technical',
    explanation:
        'REST (Representational State Transfer) is an architectural style for distributed hypermedia systems.',
  ),
  _Question(
    question: 'Which data structure uses LIFO (Last In First Out)?',
    options: ['Queue', 'Stack', 'Linked List', 'Tree'],
    correct: 1,
    category: 'Technical',
    explanation:
        'A Stack is a LIFO structure — the last element inserted is the first to be removed.',
  ),
  _Question(
    question: 'What is the time complexity of binary search?',
    options: ['O(n)', 'O(n²)', 'O(log n)', 'O(1)'],
    correct: 2,
    category: 'Technical',
    explanation:
        'Binary search halves the search space each step, giving O(log n) time complexity.',
  ),
  _Question(
    question: 'In Flutter, what widget is used to detect gestures?',
    options: [
      'GestureWidget',
      'GestureDetector',
      'TouchListener',
      'TapHandler',
    ],
    correct: 1,
    category: 'Flutter',
    explanation:
        'GestureDetector wraps a widget and provides callbacks for various gestures.',
  ),
  _Question(
    question: 'Which HTTP method is idempotent and used to update a resource?',
    options: ['POST', 'GET', 'PUT', 'DELETE'],
    correct: 2,
    category: 'Technical',
    explanation:
        'PUT is idempotent — calling it multiple times with the same data produces the same result.',
  ),
  _Question(
    question: 'What does SOLID stand for in software design?',
    options: [
      'A set of 5 object-oriented design principles',
      'A programming language paradigm',
      'A database normalization standard',
      'A network security protocol',
    ],
    correct: 0,
    category: 'Software Design',
    explanation:
        'SOLID = Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion.',
  ),
  _Question(
    question: 'Which Git command creates a new branch and switches to it?',
    options: [
      'git branch new-branch',
      'git checkout new-branch',
      'git checkout -b new-branch',
      'git switch --create new-branch',
    ],
    correct: 2,
    category: 'Tools',
    explanation:
        'git checkout -b creates and switches to the new branch in one step.',
  ),
  _Question(
    question: 'What is the primary purpose of a foreign key in SQL?',
    options: [
      'Speed up queries',
      'Enforce referential integrity between tables',
      'Encrypt sensitive data',
      'Create unique index',
    ],
    correct: 1,
    category: 'Database',
    explanation:
        'A foreign key ensures referential integrity by linking a column to a primary key in another table.',
  ),
  _Question(
    question: 'What is the best practice for effective teamwork?',
    options: [
      'Work in isolation to avoid distractions',
      'Communicate clearly and listen actively',
      'Always agree with teammates',
      'Delegate all tasks to one person',
    ],
    correct: 1,
    category: 'Soft Skills',
    explanation:
        'Clear communication and active listening are the foundations of effective teamwork.',
  ),
  _Question(
    question: 'In Python, which keyword is used to handle exceptions?',
    options: ['catch', 'except', 'error', 'handle'],
    correct: 1,
    category: 'Technical',
    explanation: 'Python uses try/except blocks to handle exceptions.',
  ),
];

// ── Page ──────────────────────────────────────────────────────
class SkillAssessmentPage extends StatefulWidget {
  const SkillAssessmentPage({super.key});
  @override
  State<SkillAssessmentPage> createState() => _SkillAssessmentPageState();
}

class _SkillAssessmentPageState extends State<SkillAssessmentPage> {
  // ── State machine ─────────────────────────────────────────
  // intro → quiz → results
  String _stage = 'intro';

  // Quiz state
  int _current = 0;
  int _timeLeft = 30;
  List<int?> _answers = [];
  Timer? _timer;
  bool _answered = false;

  List<_Question> _questions = [];

  // ── Start quiz ────────────────────────────────────────────
  void _start() {
    _questions = List.from(_questionBank)..shuffle();
    _questions = _questions.take(8).toList();
    _answers = List.filled(_questions.length, null);
    _current = 0;
    _answered = false;
    setState(() => _stage = 'quiz');
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          // Time's up — auto advance
          _nextQuestion();
        }
      });
    });
  }

  void _selectAnswer(int idx) {
    if (_answered) return;
    setState(() {
      _answers[_current] = idx;
      _answered = true;
    });
    // Brief pause then advance
    Future.delayed(const Duration(milliseconds: 800), _nextQuestion);
  }

  void _nextQuestion() {
    _timer?.cancel();
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _answered = false;
      });
      _startTimer();
    } else {
      setState(() => _stage = 'results');
    }
  }

  // ── Score calculations ────────────────────────────────────
  int get _score => _answers
      .asMap()
      .entries
      .where((e) => e.value == _questions[e.key].correct)
      .length;

  double get _percentage =>
      _questions.isEmpty ? 0 : _score / _questions.length * 100;

  Map<String, _CatResult> get _categoryResults {
    final map = <String, _CatResult>{};
    for (int i = 0; i < _questions.length; i++) {
      final cat = _questions[i].category;
      final correct = _answers[i] == _questions[i].correct;
      map.putIfAbsent(cat, () => _CatResult(cat));
      map[cat]!.total++;
      if (correct) map[cat]!.correct++;
    }
    return map;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    switch (_stage) {
      case 'quiz':
        return _buildQuiz(isDark);
      case 'results':
        return _buildResults(isDark);
      default:
        return _buildIntro(isDark);
    }
  }

  // ────────────────────────────────────────────────────────
  // INTRO
  // ────────────────────────────────────────────────────────
  Widget _buildIntro(bool isDark) => Scaffold(
    backgroundColor: AppColors.background(isDark),
    appBar: AppBar(
      title: const Text('Skill Assessment'),
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryCyan.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.quiz_outlined,
                size: 64,
                color: AppColors.primaryCyan,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Skill Assessment Quiz',
              style: TextStyle(
                color: AppColors.text(isDark),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Test your knowledge across technical skills, '
              'tools, and soft skills. Identify your strengths '
              'and areas for improvement.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary(isDark),
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            // Quiz info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoChip(Icons.quiz, '8 Questions', isDark),
                _infoChip(Icons.timer_outlined, '30s / Question', isDark),
                _infoChip(Icons.bar_chart, 'Instant Results', isDark),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _start,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCyan,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Start Quiz',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _infoChip(IconData icon, String label, bool isDark) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.card(isDark),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border(isDark)),
    ),
    child: Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryCyan),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(isDark),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  // ────────────────────────────────────────────────────────
  // QUIZ
  // ────────────────────────────────────────────────────────
  Widget _buildQuiz(bool isDark) {
    final q = _questions[_current];
    final pct = _timeLeft / 30;
    final timerColor = _timeLeft > 15
        ? AppColors.primaryCyan
        : _timeLeft > 7
        ? Colors.orange
        : Colors.red;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Question ${_current + 1} of ${_questions.length}',
          style: TextStyle(
            color: AppColors.text(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$_timeLeft s',
                style: TextStyle(
                  color: timerColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress + timer bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_current + 1) / _questions.length,
                    minHeight: 6,
                    backgroundColor: AppColors.border(isDark).withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.primaryCyan,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 4,
                    backgroundColor: AppColors.border(isDark).withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation(timerColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primaryCyan.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      q.category,
                      style: const TextStyle(
                        color: AppColors.primaryCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Question
                  Text(
                    q.question,
                    style: TextStyle(
                      color: AppColors.text(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Options
                  ...q.options.asMap().entries.map((e) {
                    final idx = e.key;
                    final opt = e.value;
                    final selected = _answers[_current] == idx;
                    final isCorrect = idx == q.correct;

                    Color? bgColor;
                    Color? borderColor;
                    if (_answered) {
                      if (isCorrect) {
                        bgColor = Colors.green.withValues(alpha: 0.15);
                        borderColor = Colors.green;
                      } else if (selected) {
                        bgColor = Colors.red.withValues(alpha: 0.15);
                        borderColor = Colors.red;
                      }
                    } else if (selected) {
                      bgColor = AppColors.primaryCyan.withValues(alpha: 0.15);
                      borderColor = AppColors.primaryCyan;
                    }

                    return GestureDetector(
                      onTap: () => _selectAnswer(idx),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor ?? AppColors.card(isDark),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: borderColor ?? AppColors.border(isDark),
                            width: borderColor != null ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: borderColor != null
                                    ? borderColor.withValues(alpha: 0.15)
                                    : AppColors.border(isDark).withValues(alpha: 0.2),
                              ),
                              child: _answered && (isCorrect || selected)
                                  ? Icon(
                                      isCorrect ? Icons.check : Icons.close,
                                      size: 16,
                                      color: isCorrect
                                          ? Colors.green
                                          : Colors.red,
                                    )
                                  : Text(
                                      String.fromCharCode(65 + idx),
                                      style: TextStyle(
                                        color: AppColors.text(isDark),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                opt,
                                style: TextStyle(
                                  color: AppColors.text(isDark),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Explanation
                  if (_answered) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.blue,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              q.explanation,
                              style: TextStyle(
                                color: AppColors.textSecondary(isDark),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // RESULTS
  // ────────────────────────────────────────────────────────
  Widget _buildResults(bool isDark) {
    final pct = _percentage;
    final catRes = _categoryResults;
    final emoji = pct >= 80
        ? '🎉'
        : pct >= 60
        ? '👍'
        : '📚';
    final message = pct >= 80
        ? 'Excellent! You have strong knowledge in these areas.'
        : pct >= 60
        ? 'Good job! A little more practice will get you to expert level.'
        : 'Keep learning! Review the topics below to improve.';

    // Find strengths and weaknesses
    final sorted = catRes.values.toList()
      ..sort((a, b) => b.pct.compareTo(a.pct));
    final strengths = sorted.where((c) => c.pct >= 70).toList();
    final weaknesses = sorted.where((c) => c.pct < 70).toList();

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: const Text('Your Results'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Score circle
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.card(isDark),
                border: Border.all(
                  color: pct >= 80
                      ? Colors.green
                      : pct >= 60
                      ? AppColors.primaryCyan
                      : Colors.orange,
                  width: 4,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 28)),
                  Text(
                    '${pct.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: AppColors.text(isDark),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$_score / ${_questions.length}',
                    style: TextStyle(
                      color: AppColors.textMuted(isDark),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary(isDark),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Category breakdown
          Text(
            'Category Breakdown',
            style: TextStyle(
              color: AppColors.text(isDark),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...catRes.values.map((c) => _catRow(c, isDark)),
          const SizedBox(height: 24),

          // Strengths
          if (strengths.isNotEmpty) ...[
            _sectionHeader('💪 Your Strengths', Colors.green, isDark),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: strengths
                  .map(
                    (c) => Chip(
                      label: Text(c.category),
                      backgroundColor: Colors.green.withValues(alpha: 0.12),
                      side: const BorderSide(color: Colors.green),
                      labelStyle: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Weaknesses
          if (weaknesses.isNotEmpty) ...[
            _sectionHeader('📚 Areas to Improve', Colors.orange, isDark),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: weaknesses
                  .map(
                    (c) => Chip(
                      label: Text(c.category),
                      backgroundColor: Colors.orange.withValues(alpha: 0.12),
                      side: const BorderSide(color: Colors.orange),
                      labelStyle: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Review wrong answers
          Text(
            'Review Your Answers',
            style: TextStyle(
              color: AppColors.text(isDark),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._questions.asMap().entries.map((e) {
            final i = e.key;
            final q = e.value;
            final correct = _answers[i] == q.correct;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: correct
                      ? Colors.green.withValues(alpha: 0.4)
                      : Colors.red.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        correct ? Icons.check_circle : Icons.cancel,
                        color: correct ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          q.question,
                          style: TextStyle(
                            color: AppColors.text(isDark),
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!correct) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Correct: ${q.options[q.correct]}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_answers[i] != null)
                      Text(
                        'Your answer: ${q.options[_answers[i]!]}',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          // Retake button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _start,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCyan,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Retake Quiz',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _catRow(_CatResult c, bool isDark) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              c.category,
              style: TextStyle(
                color: AppColors.text(isDark),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${c.correct}/${c.total} '
              '(${c.pct.toStringAsFixed(0)}%)',
              style: TextStyle(
                color: c.pct >= 70 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: c.pct / 100,
            minHeight: 8,
            backgroundColor: AppColors.border(isDark).withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation(
              c.pct >= 70 ? Colors.green : Colors.orange,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _sectionHeader(String title, Color color, bool isDark) => Row(
    children: [
      Text(
        title,
        style: TextStyle(
          color: AppColors.text(isDark),
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

// ── Category result helper ────────────────────────────────────
class _CatResult {
  final String category;
  int total = 0;
  int correct = 0;
  _CatResult(this.category);
  double get pct => total == 0 ? 0 : correct / total * 100;
}
