import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../utils/theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Global Leaderboard')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestore.getLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No rankings yet! Be the first!'));
          }

          final players = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: players.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final player = players[index];
              final isTop3 = index < 3;

              return ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    if (player['photoUrl'] != null && player['photoUrl'].toString().isNotEmpty)
                      CircleAvatar(backgroundImage: NetworkImage(player['photoUrl'])),
                    if (player['photoUrl'] == null || player['photoUrl'].toString().isEmpty)
                      const CircleAvatar(child: Icon(Icons.person)),
                  ],
                ),
                title: Text(player['name'] ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text(
                  '${player['totalScore']} pts',
                  style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
