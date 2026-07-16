import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/course.dart';
import '../domain/user_progress.dart';
import 'local/hive_service.dart';
import 'mock_courses.dart';

class CourseRepository {
  final FirebaseFirestore _firestore;
  final HiveService _hiveService;

  CourseRepository(this._firestore, this._hiveService);

  Future<void> seedFirestoreIfNeeded() async {
    try {
      final collection = _firestore.collection('courses');
      final querySnapshot = await collection.get();
      final existingDocs = {for (var doc in querySnapshot.docs) doc.id: doc.data()};

      for (final mockCourse in mockCourses) {
        final existing = existingDocs[mockCourse.id];
        bool needsSeeding = false;
        
        if (existing == null) {
          needsSeeding = true;
        } else {
          // Vérification si les leçons ou le quiz manquent/sont vides
          final lessons = existing['lessons'];
          final quiz = existing['quiz'];
          if (lessons == null || (lessons is List && lessons.isEmpty) || quiz == null) {
            needsSeeding = true;
          }
        }

        if (needsSeeding) {
          debugPrint("Seeding/mise à jour du cours ${mockCourse.id} sur Firestore...");
          await collection.doc(mockCourse.id).set(mockCourse.toMap());
        }
      }
    } catch (e) {
      debugPrint("Impossible de vérifier/seeder Firestore (erreur réseau ou permissions) : $e");
    }
  }

  Stream<List<Course>> watchCourses() async* {
    // Émettre d'abord le cache local pour un chargement instantané
    final cached = _hiveService.getCachedCourses();
    if (cached.isNotEmpty) {
      try {
        yield cached.map((map) => Course.fromMap(map)).toList();
      } catch (e) {
        debugPrint("Erreur lors de la désérialisation du cache local : $e. Fallback vers mockCourses.");
        yield mockCourses;
      }
    } else {
      yield mockCourses;
      try {
        final coursesMaps = mockCourses.map((c) => c.toMap()).toList();
        await _hiveService.saveCourses(coursesMaps);
      } catch (e) {
        debugPrint("Impossible d'enregistrer le cache initial : $e");
      }
    }

    try {
      final collection = _firestore.collection('courses');
      
      // Lancer le seeding de Firestore si des données manquent ou sont invalides
      await seedFirestoreIfNeeded();

      await for (final snapshot in collection.snapshots()) {
        final List<Course> courses = [];
        for (final doc in snapshot.docs) {
          try {
            final data = doc.data();
            data['id'] = doc.id;
            courses.add(Course.fromMap(data, documentId: doc.id));
          } catch (e) {
            debugPrint("Erreur lors du parsing d'un document Firestore (ignoré) : $e");
          }
        }

        // Si la collection Firestore est vide ou corrompue (aucune leçon par exemple), fallback local
        if (courses.isEmpty || courses.every((c) => c.lessons.isEmpty)) {
          yield mockCourses;
        } else {
          // Sauvegarder dans le cache local Hive
          try {
            final coursesMaps = courses.map((c) => c.toMap()).toList();
            await _hiveService.saveCourses(coursesMaps);
          } catch (e) {
            debugPrint("Impossible de sauvegarder les cours Firestore en cache local: $e");
          }
          yield courses;
        }
      }
    } catch (e) {
      debugPrint("Erreur de récupération des cours sur Firestore: $e. Utilisation du cache local.");
      final cachedFallback = _hiveService.getCachedCourses();
      if (cachedFallback.isNotEmpty) {
        try {
          yield cachedFallback.map((map) => Course.fromMap(map)).toList();
        } catch (_) {
          yield mockCourses;
        }
      } else {
        yield mockCourses;
      }
    }
  }

  Future<List<Course>> getCourses() async {
    try {
      // 1. Lancer le seeding de Firestore si des données manquent ou sont invalides
      await seedFirestoreIfNeeded();

      final collection = _firestore.collection('courses');
      final querySnapshot = await collection.get();
      
      final List<Course> courses = [];
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          courses.add(Course.fromMap(data, documentId: doc.id));
        } catch (e) {
          debugPrint("Erreur lors du parsing d'un document Firestore (getCourses) : $e");
        }
      }

      // 2. Si Firestore est vide, fallback sur mockCourses
      if (courses.isEmpty || courses.every((c) => c.lessons.isEmpty)) {
        return mockCourses;
      }

      // 3. Sauvegarder dans le cache local Hive
      try {
        final coursesMaps = courses.map((c) => c.toMap()).toList();
        await _hiveService.saveCourses(coursesMaps);
      } catch (e) {
        debugPrint("Impossible de sauvegarder les cours Firestore en cache local (getCourses) : $e");
      }

      return courses;
    } catch (e) {
      debugPrint("Erreur de récupération des cours sur Firestore (getCourses) : $e. Utilisation du cache local.");
      final cachedFallback = _hiveService.getCachedCourses();
      if (cachedFallback.isNotEmpty) {
        try {
          return cachedFallback.map((map) => Course.fromMap(map)).toList();
        } catch (_) {
          return mockCourses;
        }
      } else {
        return mockCourses;
      }
    }
  }

  Course? getCourseFromCache(String courseId) {
    final cached = _hiveService.getCachedCourses();
    final match = cached.firstWhere((map) => map['id'] == courseId, orElse: () => const {});
    if (match.isEmpty) return null;
    return Course.fromMap(match);
  }

  // --- Gestion de la progression utilisateur ---

  Stream<UserProgress> watchUserProgress(String userId, String courseId) async* {
    // Émettre le cache local en premier
    final cachedProgress = _hiveService.getUserProgress(userId, courseId);
    if (cachedProgress != null) {
      yield UserProgress.fromMap(cachedProgress);
    } else {
      yield UserProgress.empty(courseId);
    }

    try {
      final docRef = _firestore.collection('users').doc(userId).collection('progress').doc(courseId);
      await for (final doc in docRef.snapshots()) {
        if (doc.exists && doc.data() != null) {
          final progress = UserProgress.fromMap(doc.data()!);
          await _hiveService.saveUserProgress(userId, courseId, progress.toMap());
          yield progress;
        }
      }
    } catch (e) {
      debugPrint("Erreur de récupération de la progression sur Firestore: $e. Utilisation du cache local.");
    }
  }

  Future<void> updateUserProgress(String userId, UserProgress progress) async {
    final courseId = progress.courseId;
    final progressMap = progress.toMap();

    // 1. Sauvegarde locale immédiate (Hive)
    await _hiveService.saveUserProgress(userId, courseId, progressMap);

    // 2. Synchronisation Firebase Firestore
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc(courseId)
          .set(progressMap, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Échec de la synchronisation Firestore. La progression reste sauvegardée en cache local: $e");
    }
  }
}

// Providers Riverpod
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  return CourseRepository(firestore, hiveService);
});

final coursesStreamProvider = StreamProvider<List<Course>>((ref) {
  final repository = ref.watch(courseRepositoryProvider);
  return repository.watchCourses();
});

final userProgressStreamProvider = StreamProvider.family<UserProgress, ({String userId, String courseId})>((ref, arg) {
  final repository = ref.watch(courseRepositoryProvider);
  return repository.watchUserProgress(arg.userId, arg.courseId);
});
