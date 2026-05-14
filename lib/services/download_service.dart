import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../models/local_storage_model.dart';

/// Download service for offline Quran storage
class DownloadService {
  final Dio _dio;
  final String _baseUrl = 'https://api.quran.com/api/v4';

  DownloadService({Dio? dio}) : _dio = dio ?? Dio();

  /// Get the Quran storage directory
  Future<Directory> _getQuranDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final quranDir = Directory('${appDir.path}/quran_audio');
    if (!await quranDir.exists()) {
      await quranDir.create(recursive: true);
    }
    return quranDir;
  }

  /// Download audio for a specific Surah
  /// Returns the local file path on success
  Future<String?> downloadSurahAudio({
    required int surahNumber,
    required int reciterId,
    required Function(double) onProgress,
  }) async {
    try {
      final quranDir = await _getQuranDir();
      final fileName = 'surah_${surahNumber}_reciter_$reciterId.mp3';
      final filePath = '${quranDir.path}/$fileName';

      // Build audio URL
      final audioUrl =
          '$_baseUrl/quran_audio/$surahNumber/$reciterId';

      // Download with progress tracking
      await _dio.download(
        audioUrl,
        filePath,
        onReceiveProgress: (received, total) {
          final progress = received / total;
          onProgress(progress);
        },
      );

      return filePath;
    } catch (e) {
      print('Error downloading Surah audio: $e');
      return null;
    }
  }

  /// Delete a downloaded Surah
  Future<bool> deleteSurahAudio({
    required int surahNumber,
    required int reciterId,
  }) async {
    try {
      final quranDir = await _getQuranDir();
      final fileName = 'surah_${surahNumber}_reciter_$reciterId.mp3';
      final file = File('${quranDir.path}/$fileName');

      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting Surah audio: $e');
      return false;
    }
  }

  /// Check if a Surah is downloaded
  Future<bool> isSurahDownloaded({
    required int surahNumber,
    required int reciterId,
  }) async {
    try {
      final quranDir = await _getQuranDir();
      final fileName = 'surah_${surahNumber}_reciter_$reciterId.mp3';
      final file = File('${quranDir.path}/$fileName');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get local file path for a Surah
  Future<String?> getSurahLocalPath({
    required int surahNumber,
    required int reciterId,
  }) async {
    final isDownloaded =
        await isSurahDownloaded(
      surahNumber: surahNumber,
      reciterId: reciterId,
    );

    if (isDownloaded) {
      final quranDir = await _getQuranDir();
      final fileName = 'surah_${surahNumber}_reciter_$reciterId.mp3';
      return '${quranDir.path}/$fileName';
    }
    return null;
  }

  /// Get total size of downloaded content
  Future<int> getTotalDownloadedSize() async {
    try {
      final quranDir = await _getQuranDir();
      int totalSize = 0;

      final files = quranDir.listSync();
      for (var file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Get list of downloaded Surahs
  Future<List<Map<String, int>>> getDownloadedSurahs() async {
    try {
      final quranDir = await _getQuranDir();
      final List<Map<String, int>> downloaded = [];

      final files = quranDir.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.mp3')) {
          // Extract surah and reciter IDs from filename
          final name = file.path.split('/').last;
          final parts = name.replaceAll('surah_', '').replaceAll('.mp3', '').split('_reciter_');
          
          if (parts.length == 2) {
            downloaded.add({
              'surahNumber': int.parse(parts[0]),
              'reciterId': int.parse(parts[1]),
            });
          }
        }
      }
      return downloaded;
    } catch (e) {
      return [];
    }
  }

  /// Clear all downloads
  Future<bool> clearAllDownloads() async {
    try {
      final quranDir = await _getQuranDir();
      if (await quranDir.exists()) {
        await quranDir.delete(recursive: true);
        await quranDir.create(recursive: true);
      }
      return true;
    } catch (e) {
      print('Error clearing downloads: $e');
      return false;
    }
  }
}

// ============ Riverpod Provider ============
final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService();
});

/// State for individual download
class DownloadState {
  final bool isDownloading;
  final double progress;
  final bool isDownloaded;

  DownloadState({
    this.isDownloading = false,
    this.progress = 0.0,
    this.isDownloaded = false,
  });

  DownloadState copyWith({
    bool? isDownloading,
    double? progress,
    bool? isDownloaded,
  }) {
    return DownloadState(
      isDownloading: isDownloading ?? this.isDownloading,
      progress: progress ?? this.progress,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }
}

class DownloadNotifier extends StateNotifier<DownloadState> {
  final DownloadService _service;
  final int surahNumber;
  final int reciterId;

  DownloadNotifier({
    required DownloadService service,
    required this.surahNumber,
    required this.reciterId,
  })  : _service = service,
        super(DownloadState()) {
    _initDownloadStatus();
  }

  Future<void> _initDownloadStatus() async {
    final isDownloaded = await _service.isSurahDownloaded(
      surahNumber: surahNumber,
      reciterId: reciterId,
    );
    state = state.copyWith(isDownloaded: isDownloaded);
  }

  Future<void> download() async {
    state = state.copyWith(isDownloading: true, progress: 0.0);

    final result = await _service.downloadSurahAudio(
      surahNumber: surahNumber,
      reciterId: reciterId,
      onProgress: (progress) {
        state = state.copyWith(progress: progress);
      },
    );

    if (result != null) {
      state = state.copyWith(
        isDownloading: false,
        isDownloaded: true,
        progress: 1.0,
      );
    } else {
      state = state.copyWith(
        isDownloading: false,
        progress: 0.0,
      );
    }
  }

  Future<void> delete() async {
    final success = await _service.deleteSurahAudio(
      surahNumber: surahNumber,
      reciterId: reciterId,
    );

    if (success) {
      state = state.copyWith(isDownloaded: false, progress: 0.0);
    }
  }
}

/// Provider for individual Surah download state
final surahDownloadProvider = StateNotifierProvider.family<
    DownloadNotifier,
    DownloadState,
    ({
      int surahNumber,
      int reciterId,
    })>((ref, params) {
  final service = ref.watch(downloadServiceProvider);
  return DownloadNotifier(
    service: service,
    surahNumber: params.surahNumber,
    reciterId: params.reciterId,
  );
});

/// Provider for downloaded Surahs list
final downloadedSurahsProvider =
    FutureProvider<List<Map<String, int>>>((ref) async {
  final service = ref.watch(downloadServiceProvider);
  return service.getDownloadedSurahs();
});

/// Provider for total downloaded size
final downloadedSizeProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(downloadServiceProvider);
  return service.getTotalDownloadedSize();
});

/// Check if specific Surah is downloaded
final isSurahDownloadedProvider = FutureProvider.family<
    bool,
    ({
      int surahNumber,
      int reciterId,
    })>((ref, params) async {
  final service = ref.watch(downloadServiceProvider);
  return service.isSurahDownloaded(
    surahNumber: params.surahNumber,
    reciterId: params.reciterId,
  );
});

/// Get local path for Surah (if downloaded)
final surahLocalPathProvider = FutureProvider.family<
    String?,
    ({
      int surahNumber,
      int reciterId,
    })>((ref, params) async {
  final service = ref.watch(downloadServiceProvider);
  return service.getSurahLocalPath(
    surahNumber: params.surahNumber,
    reciterId: params.reciterId,
  );
});
