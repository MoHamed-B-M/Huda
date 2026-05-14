# Quran App - Best Practices & Code Examples

## 🎯 Best Practices Implemented

### 1. State Management with Riverpod

#### ❌ Anti-Pattern
```dart
// Don't use setState for global state
class _MyWidgetState extends State {
  String searchQuery = '';
  
  void updateSearch(String query) {
    setState(() => searchQuery = query); // ❌ Bad
  }
}
```

#### ✅ Best Pattern
```dart
// Use Riverpod providers
final searchQueryProvider = StateProvider<String>((ref) => '');

// In widget
final query = ref.watch(searchQueryProvider);
ref.read(searchQueryProvider.notifier).state = newQuery; // ✅ Good
```

### 2. Async Data Fetching

#### ❌ Anti-Pattern
```dart
// Don't mix FutureBuilder with setState
Future<List<Surah>> _surahs;

void initState() {
  _surahs = fetchSurahs(); // ❌ Hard to test, error-prone
}
```

#### ✅ Best Pattern
```dart
// Use FutureProvider
final surahListProvider = FutureProvider((ref) async {
  return api.getAllSurahs();
});

// In widget
final surahsAsync = ref.watch(surahListProvider);
surahsAsync.when(
  loading: () => Loading(),
  error: (err, st) => Error(),
  data: (surahs) => List(),
); // ✅ Good
```

### 3. Widget Performance

#### ❌ Anti-Pattern
```dart
// Don't rebuild entire tree
class SurahList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: surahList.map((s) => 
        ComplexSurahWidget(surah: s) // ❌ Rebuilds all on state change
      ).toList(),
    );
  }
}
```

#### ✅ Best Pattern
```dart
// Use Consumer with specific provider
class SurahList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahs = ref.watch(surahListProvider);
    
    return ListView.builder(
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        return SurahItem(index: index); // ✅ Lazy loads
      },
    );
  }
}
```

### 4. Error Handling

#### ❌ Anti-Pattern
```dart
// Don't swallow errors
try {
  await api.fetchData();
} catch (e) {
  // ❌ Silently fails
}
```

#### ✅ Best Pattern
```dart
// Handle and propagate
try {
  await api.fetchData();
} on DioException catch (e) {
  print('API Error: ${e.message}');
  rethrow; // ✅ Let Riverpod handle
} catch (e, st) {
  print('Unexpected error: $e\n$st');
  rethrow;
}
```

---

## 💡 Implementation Patterns

### Pattern 1: Word-by-Word Synchronization

```dart
/// Track audio position and highlight matching words
class WordSyncController {
  final Map<int, double> wordTimings; // wordId -> timestamp
  final AudioPlayerState audioState;
  
  int? getCurrentWord() {
    int currentWordId = -1;
    
    wordTimings.forEach((wordId, timestamp) {
      final positionSeconds = 
          audioState.position.inMilliseconds / 1000;
      
      if (positionSeconds >= timestamp) {
        currentWordId = wordId; // Last matching word
      }
    });
    
    return currentWordId;
  }
  
  void seekToWord(int wordId) {
    final timestamp = wordTimings[wordId];
    if (timestamp != null) {
      audioPlayer.seek(Duration(
        milliseconds: (timestamp * 1000).toInt(),
      ));
    }
  }
}
```

### Pattern 2: Download with Progress

```dart
/// Handle downloads with progress tracking
class DownloadManager {
  Future<void> downloadSurah({
    required int surahNumber,
    required int reciterId,
    required Function(double) onProgress,
  }) async {
    try {
      final dio = Dio();
      
      await dio.download(
        'https://api.quran.com/quran_audio/$surahNumber/$reciterId',
        '/local/path',
        onReceiveProgress: (received, total) {
          final progress = received / total;
          onProgress(progress); // Real-time updates
        },
      );
    } catch (e) {
      handleDownloadError(e);
    }
  }
}
```

### Pattern 3: Local Storage with Hive

```dart
/// Persist data with Hive
class BookmarkRepository {
  late Box<Bookmark> _box;
  
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(BookmarkAdapter());
    _box = await Hive.openBox<Bookmark>('bookmarks');
  }
  
  Future<void> addBookmark(Bookmark bookmark) async {
    await _box.add(bookmark);
  }
  
  List<Bookmark> getBookmarks() {
    return _box.values.toList();
  }
}
```

### Pattern 4: Material 3 Theming

```dart
/// Dynamic theme based on user preferences
ThemeData buildTheme(ThemeConfig config) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: config.seedColor,
    brightness: config.brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
  );
  
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: GoogleFonts.amiriTextTheme(
      ThemeData.light().textTheme,
    ),
  );
}
```

---

## 🔍 Code Examples by Feature

### Reading Verses

```dart
/// Display verses with word highlighting
ConsumerWidget buildVerseDisplay(int surahNumber) {
  return Consumer(
    builder: (context, ref, child) {
      final ayahsAsync = 
          ref.watch(ayahsWithWordsProvider(surahNumber));
      
      return ayahsAsync.when(
        loading: () => LoadingWidget(),
        error: (err, st) => ErrorWidget(error: err),
        data: (ayahs) => ListView.builder(
          itemCount: ayahs.length,
          itemBuilder: (context, index) {
            return AyahCard(ayah: ayahs[index]);
          },
        ),
      );
    },
  );
}
```

### Playing Audio

```dart
/// Manage audio playback with sync
void playAudio(WidgetRef ref, int surahNumber, int reciterId) {
  final audioNotifier = ref.read(audioPlayerProvider.notifier);
  
  // 1. Load audio
  audioNotifier.loadAudio(
    'https://api.quran.com/audio/$surahNumber/$reciterId',
    reciterId,
    surahNumber,
  );
  
  // 2. Play
  audioNotifier.play();
  
  // 3. Get timings for sync
  final timingsAsync = ref.watch(audioTimingsProvider((
    verseKey: '1:1',
    reciterId: reciterId,
  )));
  
  // 4. Sync happens automatically via listeners
}
```

### Bookmarking Verses

```dart
/// Create bookmark from verse
void createBookmark(WidgetRef ref, int surahNumber, int ayahNumber) async {
  final storage = await ref.read(storageServiceProvider.future);
  
  await storage.addBookmark(
    surahNumber: surahNumber,
    ayahNumber: ayahNumber,
    label: 'Surah $surahNumber:$ayahNumber',
    notes: 'Important verse',
  );
  
  // Refresh UI
  ref.invalidate(bookmarksProvider);
}
```

### Offline Downloads

```dart
/// Download for offline
void downloadOffline(WidgetRef ref, int surahNumber, int reciterId) async {
  final downloadNotifier = ref.read(
    surahDownloadProvider((
      surahNumber: surahNumber,
      reciterId: reciterId,
    )).notifier,
  );
  
  // Download with automatic progress tracking
  await downloadNotifier.download();
  
  // Check if available locally
  final isDownloaded = ref.watch(isSurahDownloadedProvider((
    surahNumber: surahNumber,
    reciterId: reciterId,
  )));
  
  isDownloaded.whenData((available) {
    if (available) {
      print('Ready for offline use');
    }
  });
}
```

---

## 🎨 UI Component Patterns

### Glassmorphic Card

```dart
/// Modern glass effect with frosted background
Widget buildGlassmorphicCard(Widget child) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    ),
  );
}
```

### Word Chip with Highlight

```dart
/// Interactive word with real-time highlighting
Widget buildWordChip({
  required Word word,
  required bool isHighlighted,
  required VoidCallback onTap,
}) {
  return Material(
    child: InkWell(
      onTap: onTap,
      child: ScaleTransition(
        scale: isHighlighted 
            ? AlwaysStoppedAnimation(1.1) 
            : AlwaysStoppedAnimation(1.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isHighlighted ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHighlighted ? Colors.blue : Colors.grey,
            ),
          ),
          child: Text(
            word.text,
            style: GoogleFonts.amiri(
              fontSize: 18,
              fontWeight: isHighlighted 
                  ? FontWeight.bold 
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    ),
  );
}
```

### Progress Slider

```dart
/// Audio progress with time display
Widget buildProgressSlider(AudioPlayerState audioState) {
  return Column(
    children: [
      SliderTheme(
        data: SliderThemeData(
          trackHeight: 4,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
        ),
        child: Slider(
          value: audioState.duration.inMilliseconds > 0
              ? audioState.position.inMilliseconds / 
                audioState.duration.inMilliseconds
              : 0,
          onChanged: (value) {
            final newPosition = Duration(
              milliseconds: (value * 
                audioState.duration.inMilliseconds).toInt(),
            );
            // audioPlayer.seek(newPosition);
          },
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_formatDuration(audioState.position)),
          Text(_formatDuration(audioState.duration)),
        ],
      ),
    ],
  );
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
```

---

## 🚨 Common Pitfalls & Solutions

### Pitfall 1: Multiple API Calls

```dart
// ❌ Bad: Calls API every time widget rebuilds
class SurahListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final surahs = await api.getSurahs(); // ❌ Inefficient
    return ListView(...);
  }
}

// ✅ Good: Cached by Riverpod
final surahListProvider = FutureProvider((ref) async {
  return api.getSurahs(); // ✅ Called once, cached
});
```

### Pitfall 2: Lost State on Navigation

```dart
// ❌ Bad: State lost when navigating
Navigator.push(context, MaterialPageRoute(
  builder: (context) => ReaderPage(), // ❌ New instance
));

// ✅ Good: Use Riverpod providers for state
// State persists across navigation
final selectedSurahProvider = StateProvider<int?>((ref) => null);
```

### Pitfall 3: Memory Leaks in Audio

```dart
// ❌ Bad: Never disposed
AudioPlayer _player = AudioPlayer();

// ✅ Good: Properly managed
@override
void dispose() {
  _player.dispose(); // ✅ Clean up
  super.dispose();
}
```

### Pitfall 4: Word Sync Desynchronization

```dart
// ❌ Bad: Wrong calculation
int currentWord = timings.keys.where(
  (k) => timings[k]! < audioState.position.inSeconds
).first; // ❌ Breaks if no match

// ✅ Good: Safe calculation
int currentWord = -1;
timings.forEach((wordId, timestamp) {
  if (audioState.position.inSeconds >= timestamp) {
    currentWord = wordId; // ✅ Always valid
  }
});
```

---

## 📈 Performance Optimization Tips

### 1. Use Consumer Widget Correctly

```dart
// ✅ Only rebuilds when specific provider changes
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(myProvider);
    return Text(data);
  }
}
```

### 2. Lazy Load Lists

```dart
// ✅ Virtual scrolling with ListView.builder
ListView.builder(
  itemCount: 114,
  itemBuilder: (context, index) {
    return SurahTile(index);
  },
)
```

### 3. Cache Expensive Computations

```dart
// ✅ Cache word timings
final cachedTimings = ref.watch(
  audioTimingsProvider((verseKey: '1:1', reciterId: 5)),
);
// Automatically cached and reused
```

### 4. Avoid Unnecessary Rebuilds

```dart
// ✅ Use select() for specific data
final audioPosition = ref.watch(
  audioPlayerProvider.select((state) => state.position),
);
// Only rebuilds when position changes
```

---

## 🧪 Testing Patterns

### Testing Providers

```dart
void main() {
  test('surahListProvider fetches surahs', () async {
    final container = ProviderContainer();
    
    final surahs = await container.read(
      surahListProvider.future,
    );
    
    expect(surahs.length, greaterThan(0));
  });
}
```

### Testing Audio Sync

```dart
void main() {
  test('word highlighting works correctly', () {
    final audioState = AudioPlayerState(
      position: Duration(seconds: 1),
    );
    
    final timings = {1: 0.5, 2: 1.2, 3: 2.0};
    
    int currentWord = -1;
    timings.forEach((wordId, timestamp) {
      if (audioState.position.inSeconds >= timestamp) {
        currentWord = wordId;
      }
    });
    
    expect(currentWord, 1); // Word ID 1 at 1 second
  });
}
```

---

## 🎓 Learning Resources

| Topic | Resource |
|-------|----------|
| Riverpod | https://riverpod.dev/ |
| Material 3 | https://m3.material.io/ |
| Flutter | https://flutter.dev/ |
| Quran API | https://api.quran.com/docs/ |
| just_audio | https://pub.dev/packages/just_audio |
| Hive | https://hivedb.dev/ |

---

**Remember:** Clean code is readable, testable, and maintainable. Always prioritize clarity over cleverness!

Last Updated: May 2026
