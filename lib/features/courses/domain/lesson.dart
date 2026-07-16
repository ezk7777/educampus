class Lesson {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? youtubeVideoId;

  const Lesson({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.youtubeVideoId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'youtubeVideoId': youtubeVideoId,
    };
  }

  factory Lesson.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const Lesson(
        id: '',
        title: '',
        content: '',
      );
    }
    return Lesson(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString(),
      youtubeVideoId: map['youtubeVideoId']?.toString(),
    );
  }
}
