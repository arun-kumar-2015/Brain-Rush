enum Difficulty { beginner, intermediate, advanced }

class Story {
  final String id;
  final String title;
  final String thumbnailPath; // Emoji for simplicity or asset path
  final Difficulty difficulty;
  final int readingTimeMinutes;
  final String category;
  final List<String> sentences;
  final List<Map<String, dynamic>> quizQuestions;

  Story({
    required this.id,
    required this.title,
    required this.thumbnailPath,
    required this.difficulty,
    required this.readingTimeMinutes,
    required this.category,
    required this.sentences,
    required this.quizQuestions,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String,
      title: json['title'] as String,
      thumbnailPath: json['thumbnailPath'] as String,
      difficulty: _difficultyFromString(json['difficulty'] as String),
      readingTimeMinutes: json['readingTimeMinutes'] as int,
      category: json['category'] as String,
      sentences: List<String>.from(json['sentences'] as List),
      quizQuestions: List<Map<String, dynamic>>.from(json['quizQuestions'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'thumbnailPath': thumbnailPath,
        'difficulty': difficulty.toString().split('.').last,
        'readingTimeMinutes': readingTimeMinutes,
        'category': category,
        'sentences': sentences,
        'quizQuestions': quizQuestions,
      };

  static Difficulty _difficultyFromString(String value) {
    switch (value.toLowerCase()) {
      case 'beginner':
        return Difficulty.beginner;
      case 'intermediate':
        return Difficulty.intermediate;
      case 'advanced':
        return Difficulty.advanced;
      default:
        return Difficulty.beginner;
    }
  }
}
