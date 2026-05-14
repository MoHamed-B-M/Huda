import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'local_storage_model.g.dart';

/// Model for storing downloaded Surah info locally
@HiveType(typeId: 0)
@JsonSerializable()
class DownloadedSurah {
  @HiveField(0)
  final int surahNumber;

  @HiveField(1)
  final String surahName;

  @HiveField(2)
  final int reciterId;

  @HiveField(3)
  final String reciterName;

  @HiveField(4)
  final DateTime downloadedAt;

  @HiveField(5)
  final int fileSizeInBytes;

  @HiveField(6)
  final String? localFilePath;

  DownloadedSurah({
    required this.surahNumber,
    required this.surahName,
    required this.reciterId,
    required this.reciterName,
    required this.downloadedAt,
    required this.fileSizeInBytes,
    this.localFilePath,
  });

  factory DownloadedSurah.fromJson(Map<String, dynamic> json) =>
      _$DownloadedSurahFromJson(json);
  Map<String, dynamic> toJson() => _$DownloadedSurahToJson(this);
}

/// Model for bookmarks/favorites
@HiveType(typeId: 1)
@JsonSerializable()
class Bookmark {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int surahNumber;

  @HiveField(2)
  final int? ayahNumber;

  @HiveField(3)
  final String label;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String? notes;

  Bookmark({
    required this.id,
    required this.surahNumber,
    this.ayahNumber,
    required this.label,
    required this.createdAt,
    this.notes,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) =>
      _$BookmarkFromJson(json);
  Map<String, dynamic> toJson() => _$BookmarkToJson(this);
}

/// Model for reading history
@HiveType(typeId: 2)
@JsonSerializable()
class ReadingHistory {
  @HiveField(0)
  final int surahNumber;

  @HiveField(1)
  final int? lastAyahRead;

  @HiveField(2)
  final DateTime lastReadAt;

  @HiveField(3)
  final Duration timeSpent;

  ReadingHistory({
    required this.surahNumber,
    this.lastAyahRead,
    required this.lastReadAt,
    required this.timeSpent,
  });

  factory ReadingHistory.fromJson(Map<String, dynamic> json) =>
      _$ReadingHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$ReadingHistoryToJson(this);
}

/// Model for user preferences
@HiveType(typeId: 3)
@JsonSerializable()
class UserPreferences {
  @HiveField(0)
  final double? arabicFontSize;

  @HiveField(1)
  final double? englishFontSize;

  @HiveField(2)
  final int? preferredReciterId;

  @HiveField(3)
  final String? preferredTranslation;

  @HiveField(4)
  final bool? enableWordHighlighting;

  @HiveField(5)
  final bool? enableAutoScroll;

  @HiveField(6)
  final String? selectedThemeMode; // 'light', 'dark', 'system'

  UserPreferences({
    this.arabicFontSize = 24.0,
    this.englishFontSize = 16.0,
    this.preferredReciterId = 5,
    this.preferredTranslation,
    this.enableWordHighlighting = true,
    this.enableAutoScroll = false,
    this.selectedThemeMode = 'system',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  UserPreferences copyWith({
    double? arabicFontSize,
    double? englishFontSize,
    int? preferredReciterId,
    String? preferredTranslation,
    bool? enableWordHighlighting,
    bool? enableAutoScroll,
    String? selectedThemeMode,
  }) {
    return UserPreferences(
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      englishFontSize: englishFontSize ?? this.englishFontSize,
      preferredReciterId: preferredReciterId ?? this.preferredReciterId,
      preferredTranslation: preferredTranslation ?? this.preferredTranslation,
      enableWordHighlighting:
          enableWordHighlighting ?? this.enableWordHighlighting,
      enableAutoScroll: enableAutoScroll ?? this.enableAutoScroll,
      selectedThemeMode: selectedThemeMode ?? this.selectedThemeMode,
    );
  }
}
