import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/surah.dart';
import '../models/ayah.dart';
import '../models/reciter.dart';

part 'quran_api.g.dart';

@RestApi(baseUrl: 'https://api.quran.com/api/v4')
abstract class QuranApi {
  factory QuranApi(Dio dio, {String baseUrl}) = _QuranApi;

  /// Get all Surahs
  @GET('/chapters')
  Future<SurahListResponse> getAllSurahs();

  /// Get specific Surah details
  @GET('/chapters/{surahNumber}')
  Future<SurahResponse> getSurah(@Path('surahNumber') int surahNumber);

  /// Get Ayahs for a Surah
  /// [fields] can include: text_uthmani, text_indopak, translations, word_translations
  @GET('/verses/by_chapter/{surahNumber}')
  Future<AyahResponse> getAyahsBySurah(
    @Path('surahNumber') int surahNumber, {
    @Query('text_type') String? textType,
  });

  /// Get detailed Ayahs with word information
  @GET('/chapters/{surahNumber}/verses')
  Future<AyahResponse> getAyahsWithWords(
    @Path('surahNumber') int surahNumber, {
    @Query('fields') String? fields,
    @Query('word_fields') String? wordFields,
  });

  /// Get all available reciters
  @GET('/reciters')
  Future<ReciterListResponse> getReciters({
    @Query('language') String? language,
  });

  /// Get audio URL for a specific Surah
  @GET('/quran_audio/{surahNumber}/{reciterId}')
  Future<Map<String, dynamic>> getAudioUrl(
    @Path('surahNumber') int surahNumber,
    @Path('reciterId') int reciterId,
  );

  /// Get word-by-word audio timings
  @GET('/verses/{verseKey}/timings/{reciterId}')
  Future<AudioTimingResponse> getAudioTimings(
    @Path('verseKey') String verseKey,
    @Path('reciterId') int reciterId,
  );
}
