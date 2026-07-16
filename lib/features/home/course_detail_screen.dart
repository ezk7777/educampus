import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../courses/domain/course.dart';
import '../courses/data/course_repository.dart';
import '../auth/data/auth_repository.dart';
import 'lesson_detail_screen.dart';
import 'quiz_screen.dart';

class CourseDetailScreen extends ConsumerWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'sécurité':
        return const Color(0xFFEF4444);
      case 'mobile':
        return const Color(0xFF06B6D4);
      case 'web':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authRepositoryProvider).currentUser;
    final userId = currentUser?.uid ?? 'guest';
    final progressAsync = ref.watch(userProgressStreamProvider((userId: userId, courseId: course.id)));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: progressAsync.when(
        data: (progress) {
          final totalLessons = course.lessons.length;
          final completedLessons = progress.completedLessonIds.length;
          final progressPercent = progress.getProgressPercentage(totalLessons);

          final quizId = course.quiz?.id ?? 'quiz_${course.id}';
          final previousScore = progress.quizScores[quizId];
          final totalQuestions = course.quiz?.questions.length ?? 0;
          final hasProgress = completedLessons > 0;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // 1. En-tête de cours avec design premium
                  SliverAppBar(
                    expandedHeight: 240,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: const Color(0xFF1E293B), // Slate 800
                    leading: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.3),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getCategoryColor(course.category),
                              const Color(0xFF1E293B),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  course.category.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                course.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 16, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(
                                    course.duration,
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.menu_book_rounded, size: 16, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(
                                    "$totalLessons leçons",
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Description du cours
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "À propos de ce cours",
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            course.description,
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Mini-barre de progression dans le détail
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "$completedLessons de $totalLessons leçons complétées",
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${(progressPercent * 100).toInt()}%",
                                style: const TextStyle(
                                  color: Color(0xFF4F46E5),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progressPercent,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progressPercent == 1.0
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF4F46E5),
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Liste ordonnée des leçons
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final lesson = course.lessons[index];
                          final isCompleted = progress.completedLessonIds.contains(lesson.id);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isCompleted
                                    ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                    : const Color(0xFFE2E8F0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                      : const Color(0xFF4F46E5).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                      color: isCompleted
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF4F46E5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                lesson.title,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: const Text(
                                "Leçon éducative • Contenu Markdown",
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                              ),
                              trailing: isCompleted
                                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28)
                                  : const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF4F46E5), size: 28),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LessonDetailScreen(
                                      course: course,
                                      lesson: lesson,
                                      userId: userId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount: totalLessons,
                      ),
                    ),
                  ),
                ],
              ),

              // Bouton flottant de Quiz en bas d'écran (Duolingo style)
              if (course.quiz != null)
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: hasProgress
                            ? [const Color(0xFF4F46E5), const Color(0xFF3B82F6)]
                            : [const Color(0xFF94A3B8), const Color(0xFF64748B)], // Grisé si aucune progression
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (hasProgress ? const Color(0xFF4F46E5) : const Color(0xFF64748B))
                              .withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: !hasProgress
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      "Complétez au moins une leçon avant de tenter le Quiz !",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: const Color(0xFFF59E0B), // Orange warning
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuizScreen(
                                      course: course,
                                      quiz: course.quiz!,
                                      userId: userId,
                                    ),
                                  ),
                                );
                              },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  previousScore != null ? Icons.emoji_events_rounded : Icons.quiz_rounded,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  previousScore != null
                                      ? "Relancer le Quiz (Score : $previousScore / $totalQuestions)"
                                      : "Lancer le Quiz du cours",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (!hasProgress) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Erreur : ${e.toString()}")),
      ),
    );
  }
}