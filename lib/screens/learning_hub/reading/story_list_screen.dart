import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/story_model.dart';
import '../../../services/story_service.dart';
import 'story_reader_screen.dart';

class StoryListScreen extends StatefulWidget {
  const StoryListScreen({super.key});

  @override
  State<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  final StoryService _storyService = StoryService();

  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showOnlyFavorites = false;

  List<String> _favorites = [];
  Map<String, double> _progressMap = {};
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final favs = await _storyService.getFavorites();
    final coins = await _storyService.getCoins();
    
    // Load progress for each story
    Map<String, double> tempProgress = {};
    for (var story in _storyService.stories) {
      final lastSentenceIdx = await _storyService.getProgress(story.id);
      final pct = (lastSentenceIdx / story.sentences.length).clamp(0.0, 1.0);
      tempProgress[story.id] = pct;
    }

    if (mounted) {
      setState(() {
        _favorites = favs;
        _progressMap = tempProgress;
        _coins = coins;
      });
    }
  }

  List<Story> get _filteredStories {
    return _storyService.stories.where((story) {
      final matchesSearch = story.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          story.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || story.category == _selectedCategory;
      final matchesFavorite = !_showOnlyFavorites || _favorites.contains(story.id);
      return matchesSearch && matchesCategory && matchesFavorite;
    }).toList();
  }

  List<String> get _categories {
    final cats = _storyService.stories.map((s) => s.category).toSet().toList();
    return ['All', ...cats];
  }

  @override
  Widget build(BuildContext context) {
    final categoriesList = _categories;
    final storiesToShow = _filteredStories;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        title: Text('Story Library', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                const SizedBox(width: 4),
                Text('$_coins', style: GoogleFonts.nunito(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.nunito(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search stories...',
                  hintStyle: GoogleFonts.nunito(color: Colors.white30),
                  prefixIcon: const Icon(Icons.search, color: Colors.white30),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            // Filters (Favorites toggle + Category list)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _showOnlyFavorites = !_showOnlyFavorites),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _showOnlyFavorites ? Colors.pink.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _showOnlyFavorites ? Colors.pink : Colors.white24,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                            color: _showOnlyFavorites ? Colors.pink : Colors.white54,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text('Favorites', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoriesList.length,
                        itemBuilder: (context, idx) {
                          final cat = categoriesList[idx];
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedCategory = cat),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.green.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? Colors.green : Colors.white24,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  cat,
                                  style: GoogleFonts.nunito(
                                    color: isSelected ? Colors.greenAccent : Colors.white70,
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stories List
            Expanded(
              child: storiesToShow.isEmpty
                  ? Center(
                      child: Text(
                        'No stories found!',
                        style: GoogleFonts.nunito(color: Colors.white54, fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: storiesToShow.length,
                      itemBuilder: (context, idx) {
                        final story = storiesToShow[idx];
                        final isFav = _favorites.contains(story.id);
                        final progress = _progressMap[story.id] ?? 0.0;

                        return Card(
                          color: Colors.white.withOpacity(0.05),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StoryReaderScreen(story: story),
                                ),
                              );
                              _refreshData();
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // Thumbnail (Emoji)
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      story.thumbnailPath,
                                      style: const TextStyle(fontSize: 36),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Story details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          story.title,
                                          style: GoogleFonts.nunito(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            // Difficulty Badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getDiffColor(story.difficulty).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: _getDiffColor(story.difficulty)),
                                              ),
                                              child: Text(
                                                story.difficulty.toString().split('.').last.toUpperCase(),
                                                style: GoogleFonts.nunito(
                                                  color: _getDiffColor(story.difficulty),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.access_time, color: Colors.white60, size: 14),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${story.readingTimeMinutes}m',
                                              style: GoogleFonts.nunito(color: Colors.white60, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Progress bar
                                        Row(
                                          children: [
                                            Expanded(
                                              child: LinearProgressIndicator(
                                                value: progress,
                                                minHeight: 6,
                                                backgroundColor: Colors.white12,
                                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${(progress * 100).round()}%',
                                              style: GoogleFonts.nunito(color: Colors.white60, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Fav icon
                                  IconButton(
                                    icon: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? Colors.pink : Colors.white30,
                                    ),
                                    onPressed: () async {
                                      await _storyService.toggleFavorite(story.id);
                                      _refreshData();
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDiffColor(Difficulty diff) {
    switch (diff) {
      case Difficulty.beginner:
        return Colors.green;
      case Difficulty.intermediate:
        return Colors.orange;
      case Difficulty.advanced:
        return Colors.red;
      default:
        return Colors.green;
    }
  }
}
