class UserModel {
  final String uid;
  final String email;
  final String name;
  final String photoUrl;
  final int totalScore;
  final Map<String, int> bestScores;
  final int gamesPlayed;

  UserModel({
    required this.uid,
    required this.email,
    this.name = '',
    this.photoUrl = '',
    this.totalScore = 0,
    this.bestScores = const {},
    this.gamesPlayed = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'totalScore': totalScore,
      'bestScores': bestScores,
      'gamesPlayed': gamesPlayed,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      totalScore: map['totalScore'] ?? 0,
      bestScores: Map<String, int>.from(map['bestScores'] ?? {}),
      gamesPlayed: map['gamesPlayed'] ?? 0,
    );
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    int? totalScore,
    Map<String, int>? bestScores,
    int? gamesPlayed,
  }) {
    return UserModel(
      uid: this.uid,
      email: this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      totalScore: totalScore ?? this.totalScore,
      bestScores: bestScores ?? this.bestScores,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    );
  }
}
