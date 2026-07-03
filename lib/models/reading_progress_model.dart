class ReadingProgress {
  final String storyId;
  final int lastSentenceIndex;
  final double percentComplete;
  final DateTime lastUpdated;

  ReadingProgress({
    required this.storyId,
    required this.lastSentenceIndex,
    required this.percentComplete,
    required this.lastUpdated,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) => ReadingProgress(
        storyId: json['storyId'] as String,
        lastSentenceIndex: json['lastSentenceIndex'] as int,
        percentComplete: (json['percentComplete'] as num).toDouble(),
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      );

  Map<String, dynamic> toJson() => {
        'storyId': storyId,
        'lastSentenceIndex': lastSentenceIndex,
        'percentComplete': percentComplete,
        'lastUpdated': lastUpdated.toIso8601String(),
      };
}
