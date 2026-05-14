# API Integration Setup Guide

## Quran.com API v4 Integration

This document explains how to use the Quran.com API v4 endpoints integrated into this app.

## API Service Structure

The API is managed through `lib/services/api/quran_api.dart` using **Retrofit** for type-safe HTTP requests.

### Base URL
```
https://api.quran.com/api/v4
```

## Key Endpoints

### 1. Get All Surahs

**Endpoint:** `GET /chapters`

**Response:**
```json
{
  "surahs": [
    {
      "number": 1,
      "name": "الفاتحة",
      "englishName": "Al-Fatihah",
      "englishNameTranslation": "The Opening",
      "numberOfAyahs": 7,
      "revelationType": "Meccan"
    }
  ]
}
```

**Usage:**
```dart
final surahsAsync = ref.watch(surahListProvider);
surahsAsync.whenData((surahs) {
  // Use surahs
});
```

### 2. Get Verses with Words

**Endpoint:** `GET /chapters/{surahNumber}/verses`

**Query Parameters:**
- `fields` - Include specific text types (e.g., `text_uthmani`)
- `word_fields` - Include word metadata

**Response:**
```json
{
  "ayahs": [
    {
      "number": 1,
      "numberInSurah": 1,
      "text": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
      "juzNumber": 1,
      "hizbNumber": 1,
      "rubNumber": 1,
      "page": 1,
      "words": [
        {
          "id": 1,
          "charTypeId": 0,
          "code": 1611,
          "text": "بِسْمِ",
          "wordId": 1,
          "position": 1,
          "hizbId": 1,
          "rubId": 1,
          "page": 1,
          "line": 1
        }
      ]
    }
  ]
}
```

**Usage:**
```dart
final ayahsAsync = ref.watch(ayahsWithWordsProvider(surahNumber));
```

### 3. Get Audio Timings (Word-by-Word)

**Endpoint:** `GET /verses/{verseKey}/timings/{reciterId}`

**Parameters:**
- `verseKey` - Format: `{surahNumber}:{ayahNumber}` (e.g., `1:1`)
- `reciterId` - Audio reciter ID

**Response:**
```json
{
  "timings": [
    {
      "id": 1,
      "verseKey": "1:1",
      "wordId": 1,
      "timestamp": 0.5  // in seconds
    },
    {
      "id": 2,
      "verseKey": "1:1",
      "wordId": 2,
      "timestamp": 1.2
    }
  ]
}
```

**Usage:**
```dart
final timingsAsync = ref.watch(audioTimingsProvider((
  verseKey: '1:1',
  reciterId: 5,  // Mishary Rashid Alafasy
)));

timingsAsync.whenData((timings) {
  // timings is Map<int, double>: wordId -> timestamp
  final wordId = 1;
  final timestamp = timings[wordId]; // 0.5 seconds
  
  // Seek to that position
  audioNotifier.seekToWord(timestamp);
});
```

### 4. Get Reciters

**Endpoint:** `GET /reciters`

**Query Parameters:**
- `language` - Filter by language (e.g., `en`)

**Response:**
```json
{
  "reciters": [
    {
      "id": 5,
      "name": "Mishary Rashid Alafasy",
      "translatedName": {
        "name": "Mishary Rashid Alafasy",
        "languageName": "English"
      },
      "rewayahs": [
        {
          "id": 12,
          "name": "Rewayat Hafs A'an Assem"
        }
      ]
    }
  ]
}
```

**Usage:**
```dart
final recitersAsync = ref.watch(recitersProvider);
```

## Popular Reciter IDs

| ID | Name | Language |
|----|------|----------|
| 5 | Mishary Rashid Alafasy | English |
| 1 | Abdullah Basfar | Arabic |
| 2 | AbdulBari ath-Thubaity | Arabic |
| 21 | Muhammad Al-Tablawi | Arabic |
| 92 | Abdul Rashid Sufi | English |

## Implementing Word-by-Word Highlighting

### Step-by-Step Implementation

1. **Load Audio Timings:**
   ```dart
   final timingsAsync = ref.watch(audioTimingsProvider((
     verseKey: ayah.getVerseKey(surahNumber),
     reciterId: audioState.currentReciterId ?? 5,
   )));
   ```

2. **Map Words to Timestamps:**
   ```dart
   timingsAsync.whenData((timings) {
     // timings: Map<int, double>
     // Access with: timings[wordId]
   });
   ```

3. **Monitor Position Updates:**
   ```dart
   audioState.position // Updates in real-time
   ```

4. **Calculate Current Word:**
   ```dart
   int currentWordId = -1;
   
   timings.forEach((wordId, timestamp) {
     if (audioState.position.inMilliseconds >= 
         (timestamp * 1000).toInt()) {
       currentWordId = wordId;
     }
   });
   ```

5. **Highlight in UI:**
   ```dart
   _WordChip(
     word: word,
     isHighlighted: word.id == currentWordId,
     onTap: () => audioNotifier.seekToWord(timings[word.id]!),
   )
   ```

## Error Handling

### Common Issues

**No Timings Available:**
```dart
// Some reciters may not have timing data
// Fallback gracefully:
timingsAsync.whenData((timings) {
  if (timings.isEmpty) {
    // Show alternative UI without word sync
    showFullAyahText();
  } else {
    // Show word-by-word highlighting
    showWordHighlighting(timings);
  }
});
```

**Network Errors:**
```dart
timingsAsync.whenError((err, stack) {
  // Handle API errors
  // Offline? Cached data? Show error?
  return {};
});
```

## Rate Limiting

- **Limit:** ~100 requests per minute
- **Behavior:** Returns 429 if exceeded
- **Solution:** Cache responses with Riverpod (automatic)

## Testing the API

Use this curl command to test:

```bash
# Get all Surahs
curl "https://api.quran.com/api/v4/chapters"

# Get verses with words
curl "https://api.quran.com/api/v4/chapters/1/verses?fields=text_uthmani"

# Get word timings (reciter 5)
curl "https://api.quran.com/api/v4/verses/1:1/timings/5"
```

## Advanced: Audio URL

Some implementations may need the actual audio URL:

```dart
// GET /quran_audio/{surahNumber}/{reciterId}
// Returns: { "id": "audio_id", "url": "https://..." }
```

The `just_audio` package handles URL fetching, so this is handled internally.

---

**For more details, visit:** https://api.quran.com/docs/
