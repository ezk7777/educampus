import 'lesson.dart';
import 'quiz.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String category;
  final List<Lesson> lessons;
  final Quiz? quiz;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.category,
    required this.lessons,
    this.quiz,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'category': category,
      'lessons': lessons.map((l) => l.toMap()).toList(),
      'quiz': quiz?.toMap(),
    };
  }

  factory Course.fromMap(Map<String, dynamic>? map, {String? documentId}) {
    if (map == null) {
      return Course(
        id: documentId ?? '',
        title: '',
        description: '',
        duration: '',
        category: '',
        lessons: const [],
      );
    }

    final parsedLessons = <Lesson>[];
    final lessonsVal = map['lessons'];
    if (lessonsVal is List) {
      for (final item in lessonsVal) {
        if (item is Map) {
          parsedLessons.add(Lesson.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }

    Quiz? parsedQuiz;
    final quizVal = map['quiz'];
    if (quizVal is Map) {
      parsedQuiz = Quiz.fromMap(Map<String, dynamic>.from(quizVal));
    }

    return Course(
      id: documentId ?? map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      duration: map['duration']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      lessons: parsedLessons,
      quiz: parsedQuiz,
    );
  }
}
