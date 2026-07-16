import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String coursesBoxName = 'courses_box';
  static const String progressBoxName = 'progress_box';

  static Future<void> init() async {
    // initFlutter() sans argument gère automatiquement le stockage :
    // - IndexedDB sur le Web
    // - Le répertoire de documents approprié sur Mobile et Desktop
    await Hive.initFlutter();
    
    // Ouvrir les boxes qui contiendront nos Maps sérialisées
    await Hive.openBox<Map<dynamic, dynamic>>(coursesBoxName);
    await Hive.openBox<Map<dynamic, dynamic>>(progressBoxName);
  }

  Box<Map<dynamic, dynamic>> get _coursesBox => Hive.box<Map<dynamic, dynamic>>(coursesBoxName);
  Box<Map<dynamic, dynamic>> get _progressBox => Hive.box<Map<dynamic, dynamic>>(progressBoxName);

  // --- Opérations Cours ---

  Future<void> saveCourses(List<Map<String, dynamic>> courses) async {
    final Map<String, Map<String, dynamic>> courseMap = {
      for (var course in courses) course['id'] as String: course
    };
    await _coursesBox.putAll(courseMap);
  }

  List<Map<String, dynamic>> getCachedCourses() {
    return _coursesBox.values
        .map((value) => Map<String, dynamic>.from(value))
        .toList();
  }

  Future<void> clearCourses() async {
    await _coursesBox.clear();
  }

  // --- Opérations Progression utilisateur ---

  Future<void> saveUserProgress(String userId, String courseId, Map<String, dynamic> progressMap) async {
    final String key = '${userId}_$courseId';
    await _progressBox.put(key, progressMap);
  }

  Map<String, dynamic>? getUserProgress(String userId, String courseId) {
    final String key = '${userId}_$courseId';
    final data = _progressBox.get(key);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  Future<void> clearAllProgress() async {
    await _progressBox.clear();
  }
}