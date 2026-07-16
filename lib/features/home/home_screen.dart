import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/presentation/auth_screen.dart';
import '../auth/presentation/auth_controller.dart';
import '../auth/data/auth_repository.dart';
import '../courses/data/course_repository.dart';
import '../courses/domain/course.dart';
import 'course_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Tous';
  final List<String> _categories = ['Tous', 'Web', 'Sécurité', 'Mobile'];

  String _getUserDisplayName(String? email, String? displayName) {
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    if (email != null && email.isNotEmpty) {
      final namePart = email.split('@').first;
      return namePart.substring(0, 1).toUpperCase() + namePart.substring(1);
    }
    return 'Apprenant';
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesStreamProvider);
    final currentUser = ref.watch(authRepositoryProvider).currentUser;
    final userName = _getUserDisplayName(currentUser?.email, currentUser?.displayName);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. En-tête personnalisé avec dégradé moderne
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)], // Indigo 600 à Indigo 500
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "EduCampus",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Colors.white),
                          tooltip: 'Déconnexion',
                          onPressed: () async {
                            await ref.read(authControllerProvider.notifier).signOut();
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const AuthScreen()),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Bonjour, $userName 👋",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Prêt à acquérir de nouvelles compétences ?",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Barre de recherche intégrée dans l'en-tête
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: TextField(
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: "Rechercher un cours ou un sujet...",
                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Section Catégories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Catégories",
                      style: TextStyle(
                        color: Color(0xFF0F172A), // Slate 900
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0), // Slate 200
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF475569), // Slate 600
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Section Liste des cours
            coursesAsync.when(
              data: (courses) {
                // Filtrer les cours
                final filtered = courses.where((c) {
                  final matchesCat = _selectedCategory == 'Tous' || c.category == _selectedCategory;
                  final matchesSearch = c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      c.description.toLowerCase().contains(_searchQuery.toLowerCase());
                  return matchesCat && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Text(
                          "Aucun cours ne correspond à vos critères.",
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final course = filtered[index];
                        return _CourseCard(course: course, userId: currentUser?.uid ?? 'guest');
                      },
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5))),
                ),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: Center(
                    child: Text(
                      "Erreur de chargement des cours : ${err.toString()}",
                      style: const TextStyle(color: Colors.red),
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

class _CourseCard extends ConsumerWidget {
  final Course course;
  final String userId;

  const _CourseCard({required this.course, required this.userId});

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'sécurité':
        return const Color(0xFFEF4444); // Rouge 500
      case 'mobile':
        return const Color(0xFF06B6D4); // Cyan 500
      case 'web':
        return const Color(0xFFF59E0B); // Ambre 500
      default:
        return const Color(0xFF6366F1); // Indigo 500
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressStreamProvider((userId: userId, courseId: course.id)));

    return progressAsync.when(
      data: (progress) {
        final totalLessons = course.lessons.length;
        final completedLessons = progress.completedLessonIds.length;
        final progressPercent = progress.getProgressPercentage(totalLessons);
        final isStarted = completedLessons > 0;
        final isFinished = progressPercent == 1.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailScreen(course: course),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne Catégorie + Durée
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(course.category).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          course.category,
                          style: TextStyle(
                            color: _getCategoryColor(course.category),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            course.duration,
                            style: const TextStyle(
                              color: Color(0xFF64748B), // Slate 500
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Titre
                  Text(
                    course.title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A), // Slate 900
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    course.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF475569), // Slate 600
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  const SizedBox(height: 16),
                  // Barre de progression et indicateur textuel
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isFinished
                            ? "Complété ! 🎉"
                            : isStarted
                                ? "$completedLessons / $totalLessons leçons"
                                : "Pas encore commencé",
                        style: TextStyle(
                          color: isFinished
                              ? const Color(0xFF10B981) // Émeraude
                              : const Color(0xFF64748B),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${(progressPercent * 100).toInt()}%",
                        style: TextStyle(
                          color: isFinished ? const Color(0xFF10B981) : const Color(0xFF4F46E5),
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
                      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFinished ? const Color(0xFF10B981) : const Color(0xFF4F46E5),
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bouton d'action
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isFinished
                              ? [const Color(0xFF10B981), const Color(0xFF059669)] // Vert
                              : [const Color(0xFF4F46E5), const Color(0xFF3B82F6)], // Bleu/Indigo
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (isFinished ? const Color(0xFF10B981) : const Color(0xFF4F46E5))
                                .withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseDetailScreen(course: course),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isFinished
                                      ? "Revoir"
                                      : isStarted
                                          ? "Continuer"
                                          : "Commencer",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: SizedBox(
          height: 180,
          child: Card(child: Center(child: CircularProgressIndicator())),
        ),
      ),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}