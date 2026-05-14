# Quran App - Developer Quick Reference

## Quick Start

### Clone & Setup
```bash
cd quran_app
flutter pub get
flutter pub run build_runner build
flutter run
```

## Project Highlights

### 🎯 Main Entry Point
**File:** `lib/main.dart`
- Material 3 theme setup with dynamic colors
- Bottom navigation with 3 tabs (Read, Bookmarks, Settings)
- Theme inheritance from provider
- Stack-based mini-player overlay

### 📖 Surah List & Search
**File:** `lib/views/surah_list_view.dart`
- `SearchAnchor` with real-time filtering
- `OpenContainer` transitions
- Surah cards with metadata
- Direct navigation to reader

### 📚 Verse Reading
**File:** `lib/views/quran_reader_view.dart`
- **Core Feature:** Word-by-word highlighting
- Custom `Wrap` layout for word display
- Real-time sync with audio position
- Clickable words for seeking
- `CustomScrollView` with `SliverAppBar`

### 🎵 Audio Playback
**File:** `lib/views/audio_player_view.dart`
- **MiniPlayer:** Glassmorphic bottom widget
- **FullPlayer:** Draggable sheet with controls
- Play/pause, skip ±10s, speed (0.75x-1.5x)
- Progress bar with timestamp display

### 💾 Offline Storage
**File:** `lib/services/download_service.dart`
- Download Surah audio with progress tracking
- Check if Surah is downloaded locally
- Delete downloads to free space
- Get local file paths for offline playback

### 📌 Bookmarks
**File:** `lib/views/bookmarks_view.dart`
- Add/edit/delete bookmarks
- Search within bookmarks
- Store optional notes
- Sort by date created
- Uses Hive for persistence

### ⚙️ Settings
**File:** `lib/views/settings_view.dart`
- Adjust Arabic/English font sizes
- Toggle dynamic color
- Select theme mode (light/dark/system)
- View download status
- Clear all downloads

## State Management (Riverpod)

### Main Providers

| Provider | Type | Purpose |
|----------|------|---------|
| `surahListProvider` | FutureProvider | Fetch all Surahs |
| `ayahsWithWordsProvider` | FutureProvider.family | Verses with words |
| `audioPlayerProvider` | StateNotifierProvider | Audio playback state |
| `audioTimingsProvider` | FutureProvider.family | Word sync timings |
| `surahDownloadProvider` | StateNotifierProvider.family | Download state |
| `bookmarksProvider` | FutureProvider | User bookmarks |
| `themeConfigProvider` | StateNotifierProvider | Theme settings |

### Usage Pattern
```dart
// Consume provider
final data = ref.watch(surahListProvider);

// Update state
ref.read(audioPlayerProvider.notifier).play();

// Get future value
final result = await ref.read(provider.future);

// Invalidate cache
ref.invalidate(provider);
```

## API Integration (Retrofit)

**File:** `lib/services/api/quran_api.dart`

### Example Calls
```dart
// Get all Surahs
final response = await api.getAllSurahs();

// Get verses with words
final response = await api.getAyahsWithWords(
  1,
  fields: 'text_uthmani',
  wordFields: 'text_uthmani,code',
);

// Get audio timings
final response = await api.getAudioTimings('1:1', 5);
// Returns: {wordId -> timestamp}
```

### Base URL
```
https://api.quran.com/api/v4
```

## Key Features Deep Dive

### Word-by-Word Synchronization

**Step 1: Get Timings**
```dart
final timingsAsync = ref.watch(audioTimingsProvider((
  verseKey: '1:1',
  reciterId: 5,
)));
```

**Step 2: Map to UI**
```dart
timingsAsync.whenData((timings) {
  // timings: Map<int, double>
  // wordId -> timestamp (seconds)
})
```

**Step 3: Monitor Position**
```dart
final audioState = ref.watch(audioPlayerProvider);
// audioState.position updates in real-time
```

**Step 4: Calculate Current Word**
```dart
int currentWordId = -1;
timings.forEach((wordId, ts) {
  if (audioState.position.inSeconds >= ts) {
    currentWordId = wordId;
  }
});
```

**Step 5: Highlight & Interact**
```dart
// Highlight current word
_WordChip(
  isHighlighted: word.id == currentWordId,
  onTap: () => audioNotifier.seekToWord(timings[word.id]!),
)
```

### Material 3 Components Used

| Component | File | Purpose |
|-----------|------|---------|
| `NavigationBar` | main.dart | Bottom navigation |
| `SearchAnchor` | surah_list_view.dart | Surah search |
| `SegmentedButton` | surah_list_view.dart | Mode toggle |
| `Card` (outline) | quran_reader_view.dart | Verse containers |
| `BackdropFilter` | audio_player_view.dart | Glass effect |
| `SliderTheme` | audio_player_view.dart | Progress slider |

### Theme Customization

**File:** `lib/providers/theme_provider.dart`

```dart
// Build themes dynamically
buildLightTheme(ThemeConfig config)
buildDarkTheme(ThemeConfig config)

// Customize
themeConfigNotifier.setArabicFontSize(26.0);
themeConfigNotifier.setSeedColor(Color(0xFF1F7A5E));
themeConfigNotifier.setThemeMode(ThemeMode.dark);
```

## File Organization Guide

### Models (`lib/models/`)
- `surah.dart` - Surah, SurahResponse, SurahListResponse
- `ayah.dart` - Ayah, Word, WordAudioTiming, AudioTimingResponse
- `reciter.dart` - Reciter, TranslatedName, Rewayah, ReciterListResponse
- `local_storage_model.dart` - DownloadedSurah, Bookmark, ReadingHistory, UserPreferences

### Services (`lib/services/`)
- `api/quran_api.dart` - REST API client (Retrofit)
- `download_service.dart` - Download management & Riverpod provider
- `storage_service.dart` - Hive local storage & Riverpod provider

### Providers (`lib/providers/`)
- `surah_provider.dart` - Quran data providers (FutureProvider)
- `audio_provider.dart` - Audio playback state (StateNotifierProvider)
- `theme_provider.dart` - Theme customization (StateNotifierProvider)

### Views (`lib/views/`)
- `surah_list_view.dart` - Main screen with search
- `quran_reader_view.dart` - Verse reading with word sync
- `audio_player_view.dart` - Mini & full audio players
- `bookmarks_view.dart` - Bookmark management
- `settings_view.dart` - App customization

## Common Tasks

### Add New API Endpoint
1. Add method to `QuranApi` in `quran_api.dart`
2. Create corresponding model (if needed)
3. Create FutureProvider in `surah_provider.dart`
4. Use in widget with `ref.watch()`

### Add New Setting
1. Add field to `UserPreferences` in `local_storage_model.dart`
2. Add UI widget in `settings_view.dart`
3. Handle save via `storageService.updatePreference()`

### Implement New Download
1. Use `downloadService` from provider
2. Call `downloadSurahAudio()` with progress callback
3. Monitor with `surahDownloadProvider`
4. Check offline availability with `isSurahDownloadedProvider`

## Performance Tips

1. **Use FutureProvider** for one-time data fetches
2. **Cache results** - Riverpod caches automatically
3. **Virtual scrolling** - `CustomScrollView` + `SliverList`
4. **Lazy loading** - Load data only when needed
5. **Minimize rebuilds** - Use `Consumer` for specific widgets
6. **Optimize images** - Use Arabic fonts instead of images
7. **Background audio** - `just_audio` handles this

## Dependencies at a Glance

```yaml
# State Management
flutter_riverpod: ^2.4.14
riverpod: ^2.4.14

# API & Networking
dio: ^5.3.1
retrofit: ^4.0.1

# Audio
just_audio: ^0.9.34
audio_service: ^0.18.14

# Storage
hive: ^2.2.3
path_provider: ^2.1.1

# UI & Fonts
google_fonts: ^6.1.0
animations: ^2.0.11

# Utilities
intl: ^0.19.0
connectivity_plus: ^5.0.1
```

## Code Generation

```bash
# Generate Retrofit & JSON serialization
flutter pub run build_runner build

# Watch for changes
flutter pub run build_runner watch

# Clean generated files
flutter pub run build_runner clean
```

## Debugging Tips

### Log API Requests
```dart
final dio = Dio();
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));
```

### Monitor State Changes
```dart
// Use ref.listen() to track changes
ref.listen(audioPlayerProvider, (previous, next) {
  print('Audio state changed: $next');
});
```

### Test Audio Timing
```dart
// Check timing data
print(timings); // Map<int, double>
print('Word 1 at ${timings[1]}s');
```

## Architecture Decisions

1. **Riverpod** over Provider for better type safety
2. **Retrofit** for type-safe API calls
3. **Hive** for local storage (lightweight, fast)
4. **just_audio** for cross-platform audio
5. **Material 3** for modern, accessible UI
6. **Glassmorphism** for aesthetic depth
7. **Word-wrapping** layout for RTL text

## Next Development Steps

- [ ] Add Quran translations
- [ ] Implement tafsir (commentary)
- [ ] Add prayer times integration
- [ ] Create daily Ayah reminder
- [ ] Add sharing functionality
- [ ] Implement search history
- [ ] Add statistics/reading goals
- [ ] Create backup/restore feature

---

**Last Updated:** May 2026  
**Version:** 1.0.0  
**Status:** Production Ready
