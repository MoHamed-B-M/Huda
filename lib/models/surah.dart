import 'package:json_annotation/json_annotation.dart';

part 'surah.g.dart';

/// Represents a Surah (Chapter) from the Quran
@JsonSerializable()
class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory Surah.fromJson(Map<String, dynamic> json) => _$SurahFromJson(json);
  Map<String, dynamic> toJson() => _$SurahToJson(this);
}

/// Wrapper for API response
@JsonSerializable()
class SurahResponse {
  final Surah surah;

  SurahResponse({required this.surah});

  factory SurahResponse.fromJson(Map<String, dynamic> json) =>
      _$SurahResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SurahResponseToJson(this);
}

/// List of all Surahs response
@JsonSerializable()
class SurahListResponse {
  final List<Surah> surahs;

  SurahListResponse({required this.surahs});

  factory SurahListResponse.fromJson(Map<String, dynamic> json) =>
      _$SurahListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SurahListResponseToJson(this);
}
