import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../courses/domain/course.dart';
import '../courses/domain/lesson.dart';
import '../courses/data/course_repository.dart';

class LessonDetailScreen extends ConsumerWidget {
  final Course course;
  final Lesson lesson;
  final String userId;

  const LessonDetailScreen({
    super.key,
    required this.course,
    required this.lesson,
    required this.userId,
  });

  Future<void> _completeLesson(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(courseRepositoryProvider);
    
    // Récupérer le flux actuel (en une fois) pour mettre à jour la progression
    final progressAsync = ref.read(userProgressStreamProvider((userId: userId, courseId: course.id)));
    
    progressAsync.whenData((progress) async {
      if (!progress.completedLessonIds.contains(lesson.id)) {
        final updatedLessons = [...progress.completedLessonIds, lesson.id];
        final updatedProgress = progress.copyWith(completedLessonIds: updatedLessons);
        
        // Sauvegarde locale + Firestore
        await repository.updateUserProgress(userId, updatedProgress);
      }
      
      if (context.mounted) {
        // Retourner à l'écran précédent et afficher un retour positif
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text("Leçon '${lesson.title}' terminée !"),
              ],
            ),
            backgroundColor: const Color(0xFF10B981), // Émeraude
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)), // Slate 900
        title: Text(
          course.title,
          style: const TextStyle(
            color: Color(0xFF64748B), // Slate 500
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barre d'indication de lecture de la leçon
            Container(
              height: 4,
              width: double.infinity,
              color: const Color(0xFFF1F5F9), // Slate 100
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 1.0, // Indique que nous lisons cette leçon entière
                child: Container(
                  color: const Color(0xFF4F46E5), // Indigo
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre de la leçon
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        color: Color(0xFF0F172A), // Slate 900
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.menu_book_rounded, size: 14, color: Color(0xFF4F46E5)),
                        SizedBox(width: 6),
                        Text(
                          "Leçon pédagogique",
                          style: TextStyle(
                            color: Color(0xFF4F46E5),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Contenu Markdown stylisé premium
                    MarkdownBody(
                      data: lesson.content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                        h1: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          height: 1.5,
                        ),
                        h2: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          height: 1.5,
                        ),
                        p: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF334155),
                          height: 1.6,
                        ),
                        code: const TextStyle(
                          fontSize: 14,
                          backgroundColor: Color(0xFFF1F5F9),
                          color: Color(0xFFEF4444), // Texte de code en rouge
                          fontFamily: 'monospace',
                        ),
                        codeblockPadding: const EdgeInsets.all(16),
                        codeblockDecoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        listBullet: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4F46E5),
                        ),
                        tableBody: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF334155),
                        ),
                        tableBorder: TableBorder.all(
                          color: const Color(0xFFCBD5E1),
                          width: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // Barre de bouton fixe en bas (type Duolingo)
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
                  onPressed: () => _completeLesson(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Terminer la leçon",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
