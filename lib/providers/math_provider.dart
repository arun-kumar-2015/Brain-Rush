// lib/providers/math_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brain_rush/models/math/math_topic.dart';
import 'package:brain_rush/services/math/math_repository.dart';
import 'package:brain_rush/services/math/local_math_repository.dart';
import 'package:brain_rush/services/math/math_generation_service.dart';

/// Provides a singleton SharedPreferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  final asyncPrefs = ref.watch(_sharedPreferencesFutureProvider);
  return asyncPrefs.when(
    data: (prefs) => prefs,
    loading: () => throw Exception('SharedPreferences not ready'),
    error: (e, _) => throw Exception('SharedPreferences error: $e'),
  );
});

final _sharedPreferencesFutureProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provides the MathRepository implementation.
final mathRepositoryProvider = Provider<MathRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalMathRepository(prefs);
});

/// Provides the generation service.
final mathGenerationServiceProvider = Provider<MathGenerationService>((ref) => MathGenerationService());

/// Example provider that fetches all topics.
final mathTopicsProvider = FutureProvider<List<MathTopic>>((ref) async {
  final repo = ref.watch(mathRepositoryProvider);
  return await repo.getAllTopics();
});
