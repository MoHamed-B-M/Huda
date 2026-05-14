import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/local_storage_model.dart';

/// Service for managing bookmarks and reading history
class StorageService {
  late Box<Bookmark> _bookmarkBox;
  late Box<ReadingHistory> _historyBox;
  late Box<UserPreferences> _preferencesBox;

  bool _initialized = false;

  /// Initialize Hive and open boxes
  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(BookmarkAdapter());
    Hive.registerAdapter(ReadingHistoryAdapter());
    Hive.registerAdapter(UserPreferencesAdapter());

    // Open boxes
    _bookmarkBox = await Hive.openBox<Bookmark>('bookmarks');
    _historyBox = await Hive.openBox<ReadingHistory>('reading_history');
    _preferencesBox = await Hive.openBox<UserPreferences>('user_preferences');

    _initialized = true;
  }

  // ============ Bookmark Management ============

  Future<void> addBookmark({
    required int surahNumber,
    required int? ayahNumber,
    required String label,
    String? notes,
  }) async {
    final bookmark = Bookmark(
      id: const Uuid().v4(),
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      label: label,
      createdAt: DateTime.now(),
      notes: notes,
    );
    await _bookmarkBox.add(bookmark);
  }

  Future<void> removeBookmark(String bookmarkId) async {
    final keys = _bookmarkBox.keys.where((key) {
      final bookmark = _bookmarkBox.get(key);
      return bookmark?.id == bookmarkId;
    });

    for (var key in keys) {
      await _bookmarkBox.delete(key);
    }
  }

  List<Bookmark> getBookmarks() {
    return _bookmarkBox.values.toList();
  }

  List<Bookmark> getBookmarksForSurah(int surahNumber) {
    return _bookmarkBox.values
        .where((b) => b.surahNumber == surahNumber)
        .toList();
  }

  Future<void> updateBookmark(
    String bookmarkId, {
    String? label,
    String? notes,
  }) async {
    final keys = _bookmarkBox.keys.where((key) {
      final bookmark = _bookmarkBox.get(key);
      return bookmark?.id == bookmarkId;
    });

    for (var key in keys) {
      final bookmark = _bookmarkBox.get(key);
      if (bookmark != null) {
        final updated = Bookmark(
          id: bookmark.id,
          surahNumber: bookmark.surahNumber,
          ayahNumber: bookmark.ayahNumber,
          label: label ?? bookmark.label,
          createdAt: bookmark.createdAt,
          notes: notes ?? bookmark.notes,
        );
        await _bookmarkBox.put(key, updated);
      }
    }
  }

  // ============ Reading History Management ============

  Future<void> updateReadingHistory({
    required int surahNumber,
    int? lastAyahRead,
    required Duration timeSpent,
  }) async {
    final existingKey = _historyBox.keys.firstWhere(
      (key) => _historyBox.get(key)?.surahNumber == surahNumber,
      orElse: () => null,
    );

    final history = ReadingHistory(
      surahNumber: surahNumber,
      lastAyahRead: lastAyahRead,
      lastReadAt: DateTime.now(),
      timeSpent: timeSpent,
    );

    if (existingKey != null) {
      await _historyBox.put(existingKey, history);
    } else {
      await _historyBox.add(history);
    }
  }

  ReadingHistory? getReadingHistory(int surahNumber) {
    for (var history in _historyBox.values) {
      if (history.surahNumber == surahNumber) {
        return history;
      }
    }
    return null;
  }

  List<ReadingHistory> getAllReadingHistory() {
    final history = _historyBox.values.toList();
    // Sort by most recent first
    history.sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));
    return history;
  }

  // ============ User Preferences Management ============

  Future<void> savePreferences(UserPreferences prefs) async {
    if (_preferencesBox.isEmpty) {
      await _preferencesBox.add(prefs);
    } else {
      await _preferencesBox.putAt(0, prefs);
    }
  }

  UserPreferences getPreferences() {
    if (_preferencesBox.isEmpty) {
      final defaultPrefs = UserPreferences();
      _preferencesBox.add(defaultPrefs);
      return defaultPrefs;
    }
    return _preferencesBox.getAt(0) ?? UserPreferences();
  }

  Future<void> updatePreference({
    double? arabicFontSize,
    double? englishFontSize,
    int? preferredReciterId,
    String? preferredTranslation,
    bool? enableWordHighlighting,
    bool? enableAutoScroll,
    String? selectedThemeMode,
  }) async {
    final current = getPreferences();
    final updated = current.copyWith(
      arabicFontSize: arabicFontSize,
      englishFontSize: englishFontSize,
      preferredReciterId: preferredReciterId,
      preferredTranslation: preferredTranslation,
      enableWordHighlighting: enableWordHighlighting,
      enableAutoScroll: enableAutoScroll,
      selectedThemeMode: selectedThemeMode,
    );
    await savePreferences(updated);
  }

  // ============ Utility Methods ============

  Future<void> clearAllData() async {
    await _bookmarkBox.clear();
    await _historyBox.clear();
  }

  Future<void> exportData() async {
    // Export bookmarks and history as JSON for backup
    final bookmarks = _bookmarkBox.values
        .map((b) => b.toJson())
        .toList();
    final history = _historyBox.values
        .map((h) => h.toJson())
        .toList();

    print('Bookmarks: $bookmarks');
    print('History: $history');
  }
}

// ============ Riverpod Providers ============

final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  final service = StorageService();
  await service.init();
  return service;
});

final userPreferencesProvider =
    FutureProvider<UserPreferences>((ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  return storage.getPreferences();
});

final bookmarksProvider =
    FutureProvider<List<Bookmark>>((ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  return storage.getBookmarks();
});

final surahBookmarksProvider =
    FutureProvider.family<List<Bookmark>, int>((ref, surahNumber) async {
  final storage = await ref.watch(storageServiceProvider.future);
  return storage.getBookmarksForSurah(surahNumber);
});

final readingHistoryProvider =
    FutureProvider<List<ReadingHistory>>((ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  return storage.getAllReadingHistory();
});

final readingHistorySurahProvider =
    FutureProvider.family<ReadingHistory?, int>((ref, surahNumber) async {
  final storage = await ref.watch(storageServiceProvider.future);
  return storage.getReadingHistory(surahNumber);
});

// Mutable provider for adding bookmarks
final addBookmarkProvider =
    FutureProvider.family<void, Bookmark>((ref, bookmark) async {
  final storage = await ref.watch(storageServiceProvider.future);
  await storage.addBookmark(
    surahNumber: bookmark.surahNumber,
    ayahNumber: bookmark.ayahNumber,
    label: bookmark.label,
    notes: bookmark.notes,
  );
  // Refresh bookmarks
  ref.invalidate(bookmarksProvider);
});

// Mutable provider for removing bookmarks
final removeBookmarkProvider =
    FutureProvider.family<void, String>((ref, bookmarkId) async {
  final storage = await ref.watch(storageServiceProvider.future);
  await storage.removeBookmark(bookmarkId);
  // Refresh bookmarks
  ref.invalidate(bookmarksProvider);
});
