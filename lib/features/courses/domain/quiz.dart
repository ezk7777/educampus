class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  const Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
    };
  }

  factory Question.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const Question(
        id: '',
        questionText: '',
        options: [],
        correctOptionIndex: 0,
        explanation: '',
      );
    }

    final parsedOptions = <String>[];
    final opts = map['options'];
    if (opts is List) {
      for (final opt in opts) {
        parsedOptions.add(opt?.toString() ?? '');
      }
    }

    int correctIdx = 0;
    final idxVal = map['correctOptionIndex'];
    if (idxVal is int) {
      correctIdx = idxVal;
    } else if (idxVal != null) {
      correctIdx = int.tryParse(idxVal.toString()) ?? 0;
    }

    return Question(
      id: map['id']?.toString() ?? '',
      questionText: map['questionText']?.toString() ?? '',
      options: parsedOptions,
      correctOptionIndex: correctIdx,
      explanation: map['explanation']?.toString() ?? '',
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final List<Question> questions;

  const Quiz({
    required this.id,
    required this.title,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  factory Quiz.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const Quiz(
        id: '',
        title: '',
        questions: [],
      );
    }

    final parsedQuestions = <Question>[];
    final qList = map['questions'];
    if (qList is List) {
      for (final item in qList) {
        if (item is Map) {
          parsedQuestions.add(Question.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }

    return Quiz(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      questions: parsedQuestions,
    );
  }
}
