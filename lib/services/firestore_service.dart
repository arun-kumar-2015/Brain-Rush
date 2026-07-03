import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'score_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final LocalScoreService _localScore = LocalScoreService();

  // Update user score
  Future<void> updateUserScore(String uid, String gameName, int score) async {
    // 1. Save locally first (Offline support)
    await _localScore.saveScoreLocally(gameName, score);

    // 2. Try to update Firestore
    try {
      DocumentReference userRef = _db.collection('users').doc(uid);
      
      await _db.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userRef);
        
        if (!snapshot.exists) return;
        
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        Map<String, int> bestScores = Map<String, int>.from(data['bestScores'] ?? {});
        int currentBest = bestScores[gameName] ?? (gameName == 'Reaction Test' ? 9999 : 0);
        
        int newTotalScore = (data['totalScore'] ?? 0) + (gameName == 'Reaction Test' ? (1000 - score).clamp(0, 1000) : score);
        int newGamesPlayed = (data['gamesPlayed'] ?? 0) + 1;
        
        Map<String, dynamic> updates = {
          'totalScore': newTotalScore,
          'gamesPlayed': newGamesPlayed,
        };
        
        bool isBetter = gameName == 'Reaction Test' 
            ? (score < currentBest) 
            : (score > currentBest);

        if (isBetter) {
          bestScores[gameName] = score;
          updates['bestScores'] = bestScores;
        }
        
        transaction.update(userRef, updates);
        
        // Update global leaderboard
        transaction.set(_db.collection('leaderboard').doc(uid), {
          'uid': uid,
          'name': data['name'],
          'photoUrl': data['photoUrl'],
          'totalScore': newTotalScore,
        });
      });
    } catch (e) {
      print("Error updating score: $e");
    }
  }

  // Stream of top players for leaderboard
  Stream<List<Map<String, dynamic>>> getLeaderboard() {
    return _db.collection('leaderboard')
        .orderBy('totalScore', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
