import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../providers/audio_provider.dart';

/// Mini player widget at the bottom of the app
class MiniPlayer extends ConsumerWidget {
  final VoidCallback onExpand;

  const MiniPlayer({
    Key? key,
    required this.onExpand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerProvider);

    // Don't show if no audio loaded
    if (audioState.currentReciterId == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surface
                  .withOpacity(0.7),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withOpacity(0.2),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onExpand,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      // Play/Pause button
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: RawMaterialButton(
                          shape: const CircleBorder(),
                          fillColor:
                              Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            if (audioState.isPlaying) {
                              ref
                                  .read(audioPlayerProvider.notifier)
                                  .pause();
                            } else {
                              ref.read(audioPlayerProvider.notifier).play();
                            }
                          },
                          child: Icon(
                            audioState.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Progress info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Surah ${audioState.currentSurahNumber}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium,
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: audioState.duration.inMilliseconds > 0
                                  ? audioState
                                          .position
                                          .inMilliseconds /
                                      audioState.duration.inMilliseconds
                                  : 0,
                              minHeight: 3,
                              borderRadius:
                                  BorderRadius.circular(2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Expand button
                      Icon(
                        Icons.expand_less,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen audio player using DraggableScrollableSheet
class FullAudioPlayer extends ConsumerWidget {
  const FullAudioPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerProvider);
    final audioNotifier = ref.read(audioPlayerProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              automaticallyImplyLeading: true,
              title: Text(
                'Now Playing',
                style: GoogleFonts.amiri(fontSize: 18),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor:
                  Theme.of(context).colorScheme.surface,
            ),
            body: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Large album art / visual indicator
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.library_music,
                          size: 80,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title and info
                    Text(
                      'Surah ${audioState.currentSurahNumber}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reciter: ${audioState.currentReciterId}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 32),
                    // Progress bar
                    _PlayerProgressBar(audioState: audioState),
                    const SizedBox(height: 32),
                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Speed control
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline,
                            ),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              for (var speed in [0.75, 1.0, 1.25, 1.5])
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: ChoiceChip(
                                    label: Text('${speed}x'),
                                    selected: audioState
                                        .playbackSpeed ==
                                        speed,
                                    onSelected: (_) {
                                      audioNotifier
                                          .setPlaybackSpeed(
                                        speed,
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Main playback controls
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        // Skip back
                        IconButton.filled(
                          onPressed: () {
                            final newPos = audioState
                                .position -
                                const Duration(
                                  seconds:
                                      10,
                                );
                            audioNotifier.seek(
                              newPos.isNegative
                                  ? Duration
                                      .zero
                                  : newPos,
                            );
                          },
                          icon: const Icon(
                            Icons
                                .replay_10,
                          ),
                        ),
                        const SizedBox(
                          width:
                              16,
                        ),
                        // Play/Pause
                        IconButton.filled(
                          iconSize: 32,
                          onPressed: () {
                            if (audioState
                                .isPlaying) {
                              audioNotifier
                                  .pause();
                            } else {
                              audioNotifier
                                  .play();
                            }
                          },
                          icon: Icon(
                            audioState
                                .isPlaying
                                ? Icons
                                    .pause_circle
                                : Icons
                                    .play_circle,
                          ),
                        ),
                        const SizedBox(
                          width:
                              16,
                        ),
                        // Skip forward
                        IconButton.filled(
                          onPressed: () {
                            final newPos = audioState
                                .position +
                                const Duration(
                                  seconds:
                                      10,
                                );
                            audioNotifier.seek(
                              newPos >
                                      audioState
                                          .duration
                                  ? audioState
                                      .duration
                                  : newPos,
                            );
                          },
                          icon: const Icon(
                            Icons
                                .forward_10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Progress bar with time display
class _PlayerProgressBar extends StatelessWidget {
  final AudioPlayerState audioState;

  const _PlayerProgressBar({
    Key? key,
    required this.audioState,
  }) : super(key: key);

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8,
            ),
          ),
          child: Slider(
            value: audioState.duration.inMilliseconds > 0
                ? audioState.position.inMilliseconds /
                    audioState
                        .duration
                        .inMilliseconds
                : 0,
            onChanged: (value) {
              // Seek implementation
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(
                audioState.position,
              ),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall,
            ),
            Text(
              _formatDuration(
                audioState.duration,
              ),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall,
            ),
          ],
        ),
      ],
    );
  }
}
