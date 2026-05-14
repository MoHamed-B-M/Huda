# High-Performance Quran App - Flutter 3.x with Material 3

A modern, feature-rich Quranic reading application built with Flutter 3.x, showcasing Material 3 Expressive design system with advanced features like word-by-word audio synchronization, offline support, and beautiful glassmorphism UI.

## 🌟 Key Features

### Core Features
- ✨ **Material 3 Expressive Design** with dynamic color theming
- 📖 **Verse-by-verse and Word-by-word** reading
- 🎵 **Audio Streaming & Playback** with `just_audio`
- 🔤 **Word-Level Synchronization** (Lyrics-style highlighting)
- 🔍 **Advanced Search** with SearchAnchor
- 💾 **Offline Support** with download management
- 🎨 **Theme Customization** (font sizes, colors, modes)
- 📌 **Bookmarks & Reading History**
- 🚀 **High-Performance State Management** with Riverpod

### Design & UX
- 🎭 Glassmorphism effects with `BackdropFilter`
- ✨ Shared Axis transitions between views
- 📱 Material 3 components (`NavigationBar`, `SearchAnchor`, `SegmentedButton`)
- 🎬 Expressive motion curves (`Curves.elasticOut`, bouncy animations)
- 📊 Progress indicators for downloads
- 🎯 Responsive layout for all screen sizes

## 📦 Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── surah.dart                    # Surah models
│   ├── ayah.dart                     # Verse & word models
│   ├── reciter.dart                  # Audio reciter info
│   └── local_storage_model.dart      # Local storage models
├── services/
│   ├── api/
│   │   └── quran_api.dart            # Quran.com API (Retrofit)
│   ├── download_service.dart         # Download management
│   └── storage_service.dart          # Local storage (Hive)
├── providers/
│   ├── surah_provider.dart           # Surah providers
│   ├── audio_provider.dart           # Audio playback state
│   └── theme_provider.dart           # Theme customization
└── views/
    ├── surah_list_view.dart          # Surah list & search
    ├── quran_reader_view.dart        # Verse reading with sync
    ├── audio_player_view.dart        # Mini/full audio player
    ├── bookmarks_view.dart           # Bookmarks management
    └── settings_view.dart            # App settings
```

## 🚀 Getting Started

### Prerequisites
- Flutter 3.11+ and Dart 3.1+
- Android Studio or VS Code
- iOS/Android emulator or physical device

### Installation

1. **Clone and setup:**
   ```bash
   cd quran_app
   flutter pub get
   ```

2. **Generate code:**
   ```bash
   flutter pub run build_runner build
   ```

3. **Run app:**
   ```bash
   flutter run
   ```

## 💡 Usage Examples

### 1. Reading Surahs

```dart
// In QuranReaderView
final ayahsAsync = ref.watch(ayahsWithWordsProvider(surahNumber));
ayahsAsync.whenData((ayahs) {
  // Display verses with word-level data
});
```

### 2. Audio Playback with Word Sync

```dart
// Load audio and get word timings
final audioState = ref.watch(audioPlayerProvider);
final timingsAsync = ref.watch(audioTimingsProvider((
  verseKey: '1:1',  // Surah:Ayah
  reciterId: 5,     // Mishary Rashid Alafasy
)));

// Seek to word
audioNotifier.seekToWord(timestamp);
audioNotifier.setCurrentWord(wordId);
```

### 3. Download Offline Content

```dart
// Download a Surah
ref.read(surahDownloadProvider((
  surahNumber: 1,
  reciterId: 5,
)).notifier).download();

// Check if downloaded
final isDownloaded = ref.watch(isSurahDownloadedProvider((
  surahNumber: 1,
  reciterId: 5,
)));
```

### 4. Create Bookmarks

```dart
// Add bookmark
await storage.addBookmark(
  surahNumber: 1,
  ayahNumber: 7,
  label: 'Important verse',
  notes: 'Remember this for reflection',
);

// Get bookmarks
final bookmarks = storage.getBookmarks();
```

### 5. Customize Theme

```dart
final themeConfig = ref.watch(themeConfigProvider);

// Change seed color
ref.read(themeConfigProvider.notifier)
    .setSeedColor(Color(0xFF1F7A5E));

// Adjust font size
ref.read(themeConfigProvider.notifier)
    .setArabicFontSize(26.0);

// Change theme mode
ref.read(themeConfigProvider.notifier)
    .setThemeMode(ThemeMode.dark);
```

## 🎨 Material 3 Customization

### Color Scheme
```dart
ColorScheme.fromSeed(
  seedColor: Color(0xFF1F7A5E),  // Islamic green
  brightness: Brightness.light,
  dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
)
```

### Typography
```dart
// Arabic text with optimized line height
GoogleFonts.amiri(
  fontSize: 24,
  height: 2.2,  // Better readability
)

// English fallback
GoogleFonts.amiri(fontSize: 16)
```

### Components
- `NavigationBar` for bottom navigation
- `Card(variant: CardVariant.outlined)` for Ayahs
- `SearchAnchor` for Surah search
- `SegmentedButton` for mode selection
- `BackdropFilter` for glassmorphism

## 🔊 Word-by-Word Audio Sync

### How It Works

1. **Audio Timings API:**
   ```
   GET /verses/{surah}:{ayah}/timings/{reciterId}
   ```
   Returns array: `[{word_id: 1, timestamp: 0.5}, ...]`

2. **Real-time Highlighting:**
   ```dart
   // Position updates trigger word highlight
   audioState.position → currentWordId → UI update
   ```

3. **Click to Seek:**
   ```dart
   // User clicks word → Seek to timestamp
   onWordTap(word) → audioNotifier.seekToWord(timestamp)
   ```

### Implementation Details

```dart
// Map word IDs to timestamps
final timings = <int, double>{};
for (var timing in response.timings) {
  timings[timing.wordId] = timing.timestamp;
}

// Highlight current word based on position
int currentWordId = -1;
timings.forEach((wordId, timestamp) {
  if (audioState.position.inSeconds >= timestamp) {
    currentWordId = wordId;
  }
});
```

## 📥 Offline Downloads

### Features
- Download full Surahs for a reciter
- Track download progress
- View downloaded list
- Delete individual downloads
- Check local file paths

### Usage
```dart
// Download with progress
await downloadService.downloadSurahAudio(
  surahNumber: 1,
  reciterId: 5,
  onProgress: (progress) => print('$progress%'),
);

// Check if available locally
final isDownloaded = await downloadService.isSurahDownloaded(
  surahNumber: 1,
  reciterId: 5,
);

// Get local path for offline playback
final localPath = await downloadService.getSurahLocalPath(
  surahNumber: 1,
  reciterId: 5,
);
```

## 🎯 Riverpod State Management

### Provider Types Used

**FutureProvider** - Async data fetching
```dart
final surahListProvider = FutureProvider((ref) async {
  final api = ref.watch(quranApiProvider);
  return api.getAllSurahs();
});
```

**StateNotifierProvider** - Mutable state
```dart
final audioPlayerProvider = StateNotifierProvider((ref) {
  return AudioPlayerNotifier();
});
```

**StateProvider** - Simple state
```dart
final searchQueryProvider = StateProvider((ref) => '');
```

**FamilyProvider** - Parameterized providers
```dart
final ayahsProvider = FutureProvider.family((ref, surahNumber) async {
  // Fetch ayahs for specific surah
});
```

## 🎬 Animations & Transitions

### Glassmorphism Mini-Player
```dart
BackdropFilter(
  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  child: Container(
    decoration: BoxDecoration(
      color: color.withOpacity(0.7),
      border: Border.all(color: outline.withOpacity(0.2)),
    ),
  ),
)
```

### Shared Axis Transitions
```dart
OpenContainer(
  transitionType: ContainerTransitionType.fadeThrough,
  closedBuilder: (context, action) => SurahCard(),
  openBuilder: (context, action) => QuranReaderPage(),
)
```

### Word Highlighting Animation
```dart
ScaleTransition(
  scale: isCurrentWord ? AlwaysStoppedAnimation(1.1) : AlwaysStoppedAnimation(1.0),
  child: WordChip(),
)
```

## 📱 Responsive Design

- Adaptive layouts for phone/tablet
- Custom scroll behavior
- Flexible grid items
- Safe area padding

## 🔗 API Integration

### Quran.com API v4 Endpoints
- `GET /chapters` - All Surahs
- `GET /chapters/{id}` - Surah details
- `GET /chapters/{id}/verses` - Verses with words
- `GET /verses/{key}/timings/{reciterId}` - Audio timings
- `GET /reciters` - Available reciters

### No Authentication Required
- Free public API
- ~100 requests/minute limit
- Automatic caching with Riverpod

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

## 🐛 Troubleshooting

### Audio Not Playing
1. Check internet connection
2. Verify reciter ID is valid
3. Check audio permissions (Android/iOS)

### Words Not Highlighting
1. Verify timings API returns data
2. Check position/timestamp sync
3. Clear app cache

### Build Errors
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🎓 Learning Resources

- 📚 [Quran.com API Docs](https://api.quran.com/docs/)
- 🎨 [Material 3 Design](https://m3.material.io/)
- 🚀 [Flutter Best Practices](https://flutter.dev/docs)
- 📱 [Riverpod Docs](https://riverpod.dev/)
- 🎬 [Flutter Animations](https://flutter.dev/docs/development/ui/animations)

## 📄 License

This project is provided as-is for educational purposes.

---

## 🤝 Contributing

Suggestions and improvements welcome! Report issues or contribute features through pull requests.

**Built with ❤️ using Flutter & Material Design 3 Expressive**

Last Updated: May 2026
Version: 1.0.0
