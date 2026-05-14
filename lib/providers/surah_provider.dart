import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/surah.dart';
import '../models/ayah.dart';
import '../models/reciter.dart';
import '../services/api/quran_api.dart';

// ============ API Provider ============
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Add interceptor for logging
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
});

final quranApiProvider = Provider<QuranApi>((ref) {
  final dio = ref.watch(dioProvider);
  return QuranApi(dio);
});

// ============ Surah Providers ============
final surahListProvider = FutureProvider<List<Surah>>((ref) async {
  final api = ref.watch(quranApiProvider);
  final response = await api.getAllSurahs();
  return response.surahs;
});

final surahProvider = FutureProvider.family<Surah, int>((ref, surahNumber) async {
  final api = ref.watch(quranApiProvider);
  final response = await api.getSurah(surahNumber);
  return response.surah;
});

// ============ Ayah Providers ============
final ayahsProvider =
    FutureProvider.family<List<Ayah>, int>((ref, surahNumber) async {
  final api = ref.watch(quranApiProvider);
  final response = await api.getAyahsBySurah(surahNumber);
  return response.ayahs;
});

final ayahsWithWordsProvider =
    FutureProvider.family<List<Ayah>, int>((ref, surahNumber) async {
  final api = ref.watch(quranApiProvider);
  final response = await api.getAyahsWithWords(
    surahNumber,
    fields: 'text_uthmani',
    wordFields: 'text_uthmani,char_type_id,code',
  );
  return response.ayahs;
});

// ============ Reciter Providers ============
final recitersProvider = FutureProvider<List<Reciter>>((ref) async {
  final api = ref.watch(quranApiProvider);
  final response = await api.getReciters(language: 'en');
  return response.reciters;
});

// ============ Search Provider ============
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredSurahsProvider = Provider<AsyncValue<List<Surah>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final surahsAsync = ref.watch(surahListProvider);

  return surahsAsync.whenData((surahs) {
    if (query.isEmpty) return surahs;
    return surahs
        .where((surah) =>
            surah.englishName.toLowerCase().contains(query) ||
            surah.englishNameTranslation.toLowerCase().contains(query) ||
            surah.number.toString().contains(query))
        .toList();
  });
});

// ============ Selected Surah Provider ============
final selectedSurahProvider = StateProvider<int?>((ref) => null);

// ============ Audio Timing Provider ============
final audioTimingsProvider = FutureProvider.family<
    Map<int, double>,
    ({
      String verseKey,
      int reciterId,
    })>((ref, params) async {
  final api = ref.watch(quranApiProvider);
  try {
    final response =
        await api.getAudioTimings(params.verseKey, params.reciterId);
    // Convert to map: wordId -> timestamp
    final timingMap = <int, double>{};
    for (var timing in response.timings) {
      timingMap[timing.wordId] = timing.timestamp;
    }
    return timingMap;
  } catch (e) {
    // Return empty map if API doesn't have timings
    return {};
  }
});
