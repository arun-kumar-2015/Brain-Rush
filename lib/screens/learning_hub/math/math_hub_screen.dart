// lib/screens/learning_hub/math/math_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brain_rush/models/math/math_topic.dart';
import 'package:brain_rush/providers/math_provider.dart';
import 'package:google_fonts/google_fonts.dart';

/// Math Hub – displays available math topics as glass‑morphism cards.
class MathHubScreen extends ConsumerWidget {
  const MathHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(mathTopicsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Math Learning Hub', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromRGBO(85, 150, 250, 1), Color.fromRGBO(130, 100, 240, 1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: topicsAsync.when(
          data: (topics) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                return _TopicCard(topic: topic);
              },
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed to load topics: $e')),
        ),
      ),
    );
  }
}

class _TopicCard extends ConsumerWidget {
  final MathTopic topic;
  const _TopicCard({required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // navigate to lesson list for this topic
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => LessonListScreen(topic: topic),
        ));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calculate, size: 48, color: Colors.white70),
                const SizedBox(height: 12),
                Text(topic.name,
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 8),
                Text(topic.description,
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Simple lesson list screen used by the hub (stub – you can flesh out later)
class LessonListScreen extends ConsumerWidget {
  final MathTopic topic;
  const LessonListScreen({required this.topic, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(mathLessonsProvider(topic.id));
    return Scaffold(
      appBar: AppBar(title: Text(topic.name), backgroundColor: Colors.transparent, elevation: 0),
      body: lessonsAsync.when(
        data: (lessons) => ListView.builder(
          itemCount: lessons.length,
          itemBuilder: (context, i) {
            final lesson = lessons[i];
            return ListTile(
              title: Text(lesson.title),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => LessonDetailScreen(lesson: lesson),
                ));
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading lessons: $e')),
      ),
    );
  }
}

class LessonDetailScreen extends StatelessWidget {
  final MathLesson lesson;
  const LessonDetailScreen({required this.lesson, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title), backgroundColor: Colors.transparent, elevation: 0),
      body: Center(child: Text(lesson.content)),
    );
  }
}
