import 'package:json_annotation/json_annotation.dart';

part 'ayah.g.dart';

/// Represents a word in a verse (Ayah)
@JsonSerializable()
class Word {
  final int id;
  final int charTypeId;
  final int code;
  final String text;
  @JsonKey(name: 'word_id')
  final int wordId;
  final int position;
  @JsonKey(name: 'hizb_id')
  final int hizbId;
  @JsonKey(name: 'rub_id')
  final int rubId;
  @JsonKey(name: 'sajdah_id')
  final int? sajdahId;
  final int page;
  final int line;

  Word({
    required this.id,
    required this.charTypeId,
    required this.code,
    required this.text,
    required this.wordId,
    required this.position,
    required this.hizbId,
    required this.rubId,
    this.sajdahId,
    required this.page,
    required this.line,
  });

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
  Map<String, dynamic> toJson() => _$WordToJson(this);
}

/// Audio timing information for a word
@JsonSerializable()
class WordAudioTiming {
  final int id;
  @JsonKey(name: 'verse_key')
  final String verseKey;
  @JsonKey(name: 'word_id')
  final int wordId;
  final double timestamp;

  WordAudioTiming({
    required this.id,
    required this.verseKey,
    required this.wordId,
    required this.timestamp,
  });

  factory WordAudioTiming.fromJson(Map<String, dynamic> json) =>
      _$WordAudioTimingFromJson(json);
  Map<String, dynamic> toJson() => _$WordAudioTimingToJson(this);
}

/// Represents a verse (Ayah) in the Quran
@JsonSerializable()
class Ayah {
  final int number;
  final int numberInSurah;
  final String text;
  @JsonKey(name: 'juz_number')
  final int juzNumber;
  @JsonKey(name: 'hizb_number')
  final int hizbNumber;
  @JsonKey(name: 'rub_number')
  final int rubNumber;
  @JsonKey(name: 'sajdah')
  final bool? sajdah;
  final int page;
  final List<Word>? words;

  Ayah({
    required this.number,
    required this.numberInSurah,
    required this.text,
    required this.juzNumber,
    required this.hizbNumber,
    required this.rubNumber,
    this.sajdah,
    required this.page,
    this.words,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) => _$AyahFromJson(json);
  Map<String, dynamic> toJson() => _$AyahToJson(this);

  /// Returns verse key in format "surah:ayah"
  String getVerseKey(int surahNumber) => '$surahNumber:$numberInSurah';
}

/// Response wrapper for Ayahs
@JsonSerializable()
class AyahResponse {
  final List<Ayah> ayahs;

  AyahResponse({required this.ayahs});

  factory AyahResponse.fromJson(Map<String, dynamic> json) =>
      _$AyahResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AyahResponseToJson(this);
}

/// Response for word-level audio timings
@JsonSerializable()
class AudioTimingResponse {
  final List<WordAudioTiming> timings;

  AudioTimingResponse({required this.timings});

  factory AudioTimingResponse.fromJson(Map<String, dynamic> json) =>
      _$AudioTimingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AudioTimingResponseToJson(this);
}
