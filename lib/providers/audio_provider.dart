import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// State for audio player
class AudioPlayerState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final int? currentReciterId;
  final int? currentSurahNumber;
  final double playbackSpeed;
  final int currentWordId;

  AudioPlayerState({
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentReciterId,
    this.currentSurahNumber,
    this.playbackSpeed = 1.0,
    this.currentWordId = -1,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    int? currentReciterId,
    int? currentSurahNumber,
    double? playbackSpeed,
    int? currentWordId,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentReciterId: currentReciterId ?? this.currentReciterId,
      currentSurahNumber: currentSurahNumber ?? this.currentSurahNumber,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      currentWordId: currentWordId ?? this.currentWordId,
    );
  }
}

/// Audio player notifier using Riverpod
class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayerNotifier() : super(AudioPlayerState()) {
    _initListeners();
  }

  void _initListeners() {
    _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });

    _audioPlayer.playingStream.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });
  }

  /// Load audio from URL
  Future<void> loadAudio(String url, int reciterId, int surahNumber) async {
    try {
      state = state.copyWith(
        currentReciterId: reciterId,
        currentSurahNumber: surahNumber,
        isPlaying: false,
      );
      await _audioPlayer.setUrl(url);
    } catch (e) {
      print('Error loading audio: $e');
    }
  }

  /// Play audio
  Future<void> play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  /// Pause audio
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  /// Seek to specific position
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed);
      state = state.copyWith(playbackSpeed: speed);
    } catch (e) {
      print('Error setting speed: $e');
    }
  }

  /// Update current highlighted word
  void setCurrentWord(int wordId) {
    state = state.copyWith(currentWordId: wordId);
  }

  /// Seek to word timestamp
  Future<void> seekToWord(double timestamp) async {
    await seek(Duration(milliseconds: (timestamp * 1000).toInt()));
  }

  /// Dispose resources
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Audio player provider
final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  return AudioPlayerNotifier();
});

/// Mini player expanded state
final isMiniPlayerExpandedProvider = StateProvider<bool>((ref) => false);

/// Download progress
class DownloadProgressState {
  final bool isDownloading;
  final double progress;
  final int? currentSurahNumber;

  DownloadProgressState({
    this.isDownloading = false,
    this.progress = 0.0,
    this.currentSurahNumber,
  });

  DownloadProgressState copyWith({
    bool? isDownloading,
    double? progress,
    int? currentSurahNumber,
  }) {
    return DownloadProgressState(
      isDownloading: isDownloading ?? this.isDownloading,
      progress: progress ?? this.progress,
      currentSurahNumber: currentSurahNumber ?? this.currentSurahNumber,
    );
  }
}

class DownloadProgressNotifier extends StateNotifier<DownloadProgressState> {
  DownloadProgressNotifier() : super(DownloadProgressState());

  void startDownload(int surahNumber) {
    state = state.copyWith(
      isDownloading: true,
      progress: 0.0,
      currentSurahNumber: surahNumber,
    );
  }

  void updateProgress(double progress) {
    state = state.copyWith(progress: progress);
  }

  void completeDownload() {
    state = state.copyWith(isDownloading: false, progress: 0.0);
  }

  void cancelDownload() {
    state = DownloadProgressState();
  }
}

final downloadProgressProvider =
    StateNotifierProvider<DownloadProgressNotifier, DownloadProgressState>(
        (ref) {
  return DownloadProgressNotifier();
});
