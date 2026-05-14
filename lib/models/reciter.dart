import 'package:json_annotation/json_annotation.dart';

part 'reciter.g.dart';

/// Represents an audio reciter
@JsonSerializable()
class Reciter {
  final int id;
  final String name;
  @JsonKey(name: 'translated_name')
  final TranslatedName? translatedName;
  @JsonKey(name: 'rewayahs')
  final List<Rewayah>? rewayahs;

  Reciter({
    required this.id,
    required this.name,
    this.translatedName,
    this.rewayahs,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) =>
      _$ReciterFromJson(json);
  Map<String, dynamic> toJson() => _$ReciterToJson(this);
}

@JsonSerializable()
class TranslatedName {
  final String name;
  final String languageName;

  TranslatedName({
    required this.name,
    required this.languageName,
  });

  factory TranslatedName.fromJson(Map<String, dynamic> json) =>
      _$TranslatedNameFromJson(json);
  Map<String, dynamic> toJson() => _$TranslatedNameToJson(this);
}

@JsonSerializable()
class Rewayah {
  final int id;
  final String name;

  Rewayah({
    required this.id,
    required this.name,
  });

  factory Rewayah.fromJson(Map<String, dynamic> json) =>
      _$RewayahFromJson(json);
  Map<String, dynamic> toJson() => _$RewayahToJson(this);
}

/// Response wrapper for reciters
@JsonSerializable()
class ReciterListResponse {
  final List<Reciter> reciters;

  ReciterListResponse({required this.reciters});

  factory ReciterListResponse.fromJson(Map<String, dynamic> json) =>
      _$ReciterListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ReciterListResponseToJson(this);
}
