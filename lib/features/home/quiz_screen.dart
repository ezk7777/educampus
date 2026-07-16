import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../courses/domain/course.dart';
import '../courses/domain/quiz.dart';
import '../courses/domain/user_progress.dart';
import '../courses/data/course_repository.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final Course course;
  final Quiz quiz;
  final String userId;

  const QuizScreen({
    super.key,
    required this.course,
    required this.quiz,
    required this.userId,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _isSubmitted = false;
  int _score = 0;
  bool _isFinished = false;

  void _selectOption(int index) {
    if (_isSubmitted) return;
    final question = widget.quiz.questions[_currentQuestionIndex];
    setState(() {
      _selectedOptionIndex = index;
      _isSubmitted = true;
      if (index == question.correctOptionIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    final totalQuestions = widget.quiz.questions.length;
    if (_currentQuestionIndex < totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isSubmitted = false;
      });
    } else {
      setState(() {
        _isFinished = true;
      });
    }
  }

  Future<void> _finishQuiz() async {
    final repository = ref.read(courseRepositoryProvider);
    final currentProgress = ref.read(
      userProgressStreamProvider((userId: widget.userId, courseId: widget.course.id)),
    ).value ?? UserProgress.empty(widget.course.id);

    final updatedScores = Map<String, int>.from(currentProgress.quizScores);
    updatedScores[widget.quiz.id] = _score;

    final updatedProgress = currentProgress.copyWith(quizScores: updatedScores);

    // Enregistrer le score dans Hive & Firestore
    await repository.updateUserProgress(widget.userId, updatedProgress);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildQuizContent(Question question, int totalQuestions) {
    final progress = (_currentQuestionIndex + 1) / totalQuestions;

    return Column(
      children: [
        // Indicateur de progression des questions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Question ${_currentQuestionIndex + 1} sur $totalQuestions",
                    style: const TextStyle(
                      color: Color(0xFF64748B), // Slate 500
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${(progress * 100).toInt()}%",
                    style: const TextStyle(
                      color: Color(0xFF4F46E5), // Indigo
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // Texte de la question
                Text(
                  question.questionText,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                // Liste des choix
                ...List.generate(question.options.length, (index) {
                  final optionText = question.options[index];
                  final isSelected = _selectedOptionIndex == index;
                  final isCorrect = question.correctOptionIndex == index;

                  Color borderCol = const Color(0xFFE2E8F0);
                  Color bgCol = Colors.white;
                  Color textCol = const Color(0xFF334155);
                  Widget? suffixIcon;

                  if (_isSubmitted) {
                    if (isCorrect) {
                      borderCol = const Color(0xFF10B981);
                      bgCol = const Color(0xFFD1FAE5); // Vert clair
                      textCol = const Color(0xFF065F46);
                      suffixIcon = const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981));
                    } else if (isSelected) {
                      borderCol = const Color(0xFFEF4444);
                      bgCol = const Color(0xFFFEE2E2); // Rouge clair
                      textCol = const Color(0xFF991B1B);
                      suffixIcon = const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444));
                    } else {
                      textCol = const Color(0xFF94A3B8); // Estomper les autres options
                    }
                  } else if (isSelected) {
                    borderCol = const Color(0xFF4F46E5);
                    bgCol = const Color(0xFFEEF2FF); // Indigo très clair
                    textCol = const Color(0xFF3730A3);
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: bgCol,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.01),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _selectOption(index),
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: TextStyle(
                                    color: textCol,
                                    fontSize: 16,
                                    fontWeight: isSelected || (_isSubmitted && isCorrect)
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (suffixIcon != null) ...[
                                const SizedBox(width: 8),
                                suffixIcon,
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Explication de la réponse après validation
                if (_isSubmitted) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _selectedOptionIndex == question.correctOptionIndex
                                  ? Icons.thumb_up_alt_rounded
                                  : Icons.info_outline_rounded,
                              color: _selectedOptionIndex == question.correctOptionIndex
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedOptionIndex == question.correctOptionIndex
                                  ? "Explication (Correct !)"
                                  : "Explication (Incorrect)",
                              style: TextStyle(
                                color: _selectedOptionIndex == question.correctOptionIndex
                                    ? const Color(0xFF065F46)
                                    : const Color(0xFFB45309),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          question.explanation,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        ),

        // Barre d'actions en bas
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              )
            ],
            border: const Border(
              top: BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selectedOptionIndex == null ? null : _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentQuestionIndex == totalQuestions - 1 ? "Terminer" : "Continuer",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinishedContent(int totalQuestions) {
    final double percent = (_score / totalQuestions);
    final int scorePercent = (percent * 100).toInt();

    String title = "Félicitations !";
    String desc = "Vous avez complété le quiz.";
    IconData icon = Icons.emoji_events_rounded;
    Color iconColor = const Color(0xFFF59E0B);

    if (scorePercent == 100) {
      title = "Score Parfait ! 🏆";
      desc = "Vous maîtrisez totalement ce sujet. Un travail exceptionnel !";
    } else if (scorePercent >= 70) {
      title = "Félicitations ! 👍";
      desc = "Très bon score. Vous avez bien assimilé l'essentiel de la matière !";
    } else {
      title = "Quiz terminé ! 📚";
      desc = "Pas de souci, l'apprentissage est continu. Relisez les leçons pour vous améliorer !";
      icon = Icons.menu_book_rounded;
      iconColor = const Color(0xFF4F46E5);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Icône de félicitations animée/grande
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 80,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          // Cercle de score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    const Text(
                      "SCORE",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$_score / $totalQuestions",
                      style: TextStyle(
                        color: scorePercent >= 70 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
                const SizedBox(width: 32),
                Column(
                  children: [
                    const Text(
                      "RÉUSSITE",
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$scorePercent%",
                      style: TextStyle(
                        color: scorePercent >= 70 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // Bouton de retour fixe
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _finishQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Enregistrer & Quitter",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = widget.quiz.questions.length;
    final question = totalQuestions > 0 ? widget.quiz.questions[_currentQuestionIndex] : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF0F172A)),
          onPressed: () {
            // Confirmation avant de quitter
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Abandonner le quiz ?"),
                content: const Text("Votre progression actuelle dans ce quiz sera perdue."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Annuler"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx); // fermer la boîte de dialogue
                      Navigator.pop(context); // quitter le quiz
                    },
                    child: const Text("Quitter", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
        title: Text(
          widget.quiz.title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isFinished
            ? _buildFinishedContent(totalQuestions)
            : (question != null
                ? _buildQuizContent(question, totalQuestions)
                : const Center(child: Text("Aucune question de quiz trouvée."))),
      ),
    );
  }
}
