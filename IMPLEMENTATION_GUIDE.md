# Quran App - Flutter Implementation Guide

## Project Overview

This is a high-performance Quran reading app built with **Flutter 3.x** using **Material 3 Expressive** design system. The app features:

- ✨ Material 3 dynamic color theming with glassmorphism effects
- 🎵 Audio streaming with word-by-word synchronization
- 🔍 Advanced search with Quran.com API v4 integration
- 📱 Smooth animations with expressive motion curves
- 🚀 Riverpod state management for optimal performance
- 💾 Offline support for downloaded content

## Architecture

### Directory Structure

```
lib/
├── main.dart                          # App entry point with Material 3 setup
├── models/
│   ├── surah.dart                    # Surah (chapter) data model
│   ├── ayah.dart                     # Verse and word-level data models
│   └── reciter.dart                  # Audio reciter information
├── services/
│   └── api/
│       └── quran_api.dart            # Quran.com API integration (Retrofit)
├── providers/
│   ├── surah_provider.dart           # Riverpod providers for Surahs
│   └── audio_provider.dart           # Audio playback state management
└── views/
    ├── surah_list_view.dart          # Main Surah list with Material 3 components
    ├── quran_reader_view.dart        # Verse-by-verse reading with word highlighting
    └── audio_player_view.dart        # Mini-player and full-screen audio player
```

## Key Features

### 1. Material 3 Expressive Design

**Color Scheme:**
```dart
ColorScheme.fromSeed(
  seedColor: Color(0xFF1F7A5E), // Islamic green
  dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
)
```

**Typography:**
- Arabic text: `google_fonts.Amiri` (optimized line-height: 2.2)
- English text: Material 2021 Typography

**Components:**
- `NavigationBar` for M3 bottom navigation
- `SearchAnchor` with Material Search behavior
- `SegmentedButton` for Reading/Listening toggle
- `Card` with outline variant for Ayahs
- `BackdropFilter` for glassmorphic mini-player

### 2. Audio System with Word-by-Word Sync

**Architecture:**
```
Quran.com API v4
    ↓
Audio Timings (timestamp per word)
    ↓
Word ID mapping
    ↓
Real-time highlighting during playback
```

**Implementation Flow:**

1. **Fetch Audio Timings:**
   ```dart
   GET /verses/{surah:ayah}/timings/{reciterId}
   ```
   Returns array of `{word_id, timestamp}` objects

2. **Map to Word UI:**
   ```dart
   audioTimingsProvider returns Map<int, double>
   // wordId -> timestamp in seconds
   ```

3. **Real-time Sync:**
   - `AudioPlayer.positionStream` triggers state updates
   - Current `word_id` highlighted based on position
   - Clicking word seeks to that word's timestamp

### 3. State Management with Riverpod

**Provider Hierarchy:**

```
audioPlayerProvider (StateNotifier)
  ├── isPlaying
  ├── position (Duration)
  ├── duration (Duration)
  ├── currentReciterId
  ├── currentWordId (for highlighting)
  └── playbackSpeed

surahListProvider (FutureProvider)
  ├── getAllSurahs()
  └── searchQueryProvider (filtered)

ayahsWithWordsProvider (FutureProvider)
  └── Returns List<Ayah> with word-level data

audioTimingsProvider (FutureProvider.family)
  └── Params: {verseKey, reciterId}
  └── Returns: Map<int, double> (wordId -> timestamp)
```

## Getting Started

### Prerequisites

- Flutter 3.11+
- Dart 3.1+
- Android Studio or VS Code

### Installation

1. **Generate code:**
   ```bash
   cd quran_app
   flutter pub get
   flutter pub run build_runner build
   ```

2. **Run app:**
   ```bash
   flutter run
   ```

## API Integration

### Endpoints Used

| Endpoint | Purpose |
|----------|---------|
| `GET /chapters` | List all Surahs |
| `GET /chapters/{id}` | Surah details |
| `GET /verses/by_chapter/{id}` | Verses (Ayahs) |
| `GET /chapters/{id}/verses` | Verses with words |
| `GET /reciters` | Available reciters |
| `GET /verses/{key}/timings/{reciterId}` | Word-level audio timings |

### Authentication

No API key required. Rate limits: ~100 req/min for public endpoints.

## Customization

### Change Seed Color

Edit `main.dart`:
```dart
const seedColor = Color(0xFF1F7A5E); // Change to desired color
```

### Change Arabic Font

Edit `main.dart` and views:
```dart
GoogleFonts.amiri()      // Change to 'Lateef' or others
```

### Adjust Word Spacing

Edit `quran_reader_view.dart`:
```dart
Wrap(
  spacing: 4,      // Horizontal spacing
  runSpacing: 8,   // Vertical spacing
  // ...
)
```

## Performance Optimizations

### 1. State Management
- `Riverpod` for reactive, cached data
- `FutureProvider` with automatic caching
- Minimal rebuilds with targeted consumers

### 2. UI Rendering
- `CustomScrollView` with `SliverList` (virtual scrolling)
- `IndexedStack` for tab navigation (keeps state)
- `OpenContainer` animations for page transitions

### 3. Audio Playback
- `just_audio` with platform-specific optimizations
- Background playback support
- Word-level timestamp caching

## Next Steps

### To Implement:
- [ ] Download manager for offline Qurans
- [ ] Bookmark/history persistence with Hive
- [ ] Translation support (Quran.com provides)
- [ ] Tafsir (commentary) display
- [ ] Prayer times integration
- [ ] Qibla direction

### Dependencies for Extensions:

```yaml
# For downloads
flutter_cache_manager: ^3.3.0

# For local storage
hive: ^2.2.3
hive_flutter: ^1.1.0

# For notifications
flutter_local_notifications: ^17.0.0

# For sharing
share_plus: ^7.0.0
```

## Troubleshooting

### Audio not playing?
1. Check `android/app/build.gradle` for audio permissions
2. Verify reciters are available: `GET /reciters`
3. Check internet connection for audio streaming

### Words not highlighting?
1. Verify timings API returns data
2. Check current position matches word timestamps
3. Ensure `currentWordId` state is updating

### Code generation errors?
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## Resources

- 📚 [Quran.com API Documentation](https://api.quran.com/docs/)
- 🎨 [Material 3 Design Guide](https://m3.material.io/)
- 🚀 [Flutter Best Practices](https://flutter.dev/docs)
- 📱 [Riverpod Documentation](https://riverpod.dev/)

## License

This implementation is provided as-is for educational purposes.

---

**Built with ❤️ using Flutter & Material Design 3**
