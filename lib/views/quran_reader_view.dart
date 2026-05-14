import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import '../models/ayah.dart';
import '../providers/surah_provider.dart';
import '../providers/audio_provider.dart';

/// Main Quran reading view with word-by-word synchronization
class QuranReaderView extends ConsumerWidget {
  final int surahNumber;

  const QuranReaderView({
    Key? key,
    required this.surahNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahsAsync = ref.watch(ayahsWithWordsProvider(surahNumber));
    final audioState = ref.watch(audioPlayerProvider);
    final isMiniPlayerExpanded =
        ref.watch(isMiniPlayerExpandedProvider);

    return ayahsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (ayahs) => CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Surah Reading',
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final ayah = ayahs[index];
                return _AyahCard(
                  ayah: ayah,
                  surahNumber: surahNumber,
                  currentWordId: audioState.currentWordId,
                );
              },
              childCount: ayahs.length,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual Ayah card with word-by-word highlighting
class _AyahCard extends ConsumerWidget {
  final Ayah ayah;
  final int surahNumber;
  final int currentWordId;

  const _AyahCard({
    Key? key,
    required this.ayah,
    required this.surahNumber,
    required this.currentWordId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        variant: CardVariant.outlined,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Arabic Text with word-by-word highlighting
              _ArabicTextWithWords(
                ayah: ayah,
                surahNumber: surahNumber,
                currentWordId: currentWordId,
              ),
              const SizedBox(height: 12),
              // Verse number and metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Juz ${ayah.juzNumber}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${ayah.numberInSurah}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Arabic text with clickable words and real-time highlighting
class _ArabicTextWithWords extends ConsumerWidget {
  final Ayah ayah;
  final int surahNumber;
  final int currentWordId;

  const _ArabicTextWithWords({
    Key? key,
    required this.ayah,
    required this.surahNumber,
    required this.currentWordId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verseKey = ayah.getVerseKey(surahNumber);
    final audioState = ref.watch(audioPlayerProvider);
    final timingsAsync = ref.watch(audioTimingsProvider((
      verseKey: verseKey,
      reciterId: audioState.currentReciterId ?? 5,
    )));

    if (ayah.words == null || ayah.words!.isEmpty) {
      // Fallback to full text if words not available
      return Text(
        ayah.text,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.amiri(
          fontSize: 24,
          height: 2.2,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
    }

    return timingsAsync.when(
      loading: () => _WordWrapBuilder(
        words: ayah.words!,
        currentWordId: currentWordId,
        onWordTap: (word) =>
            _handleWordTap(context, ref, word, null),
        timings: {},
      ),
      error: (err, stack) => _WordWrapBuilder(
        words: ayah.words!,
        currentWordId: currentWordId,
        onWordTap: (word) =>
            _handleWordTap(context, ref, word, null),
        timings: {},
      ),
      data: (timings) => _WordWrapBuilder(
        words: ayah.words!,
        currentWordId: currentWordId,
        onWordTap: (word) =>
            _handleWordTap(context, ref, word, timings[word.id]),
        timings: timings,
      ),
    );
  }

  void _handleWordTap(BuildContext context, WidgetRef ref, Word word,
      double? timestamp) {
    final audioNotifier = ref.read(audioPlayerProvider.notifier);

    if (timestamp != null) {
      // Seek to word timestamp
      audioNotifier.seekToWord(timestamp);
      audioNotifier.setCurrentWord(word.id);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Word: ${word.text}'),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }
}

/// Builder for word wrap with highlighting
class _WordWrapBuilder extends StatelessWidget {
  final List<Word> words;
  final int currentWordId;
  final Function(Word) onWordTap;
  final Map<int, double> timings;

  const _WordWrapBuilder({
    Key? key,
    required this.words,
    required this.currentWordId,
    required this.onWordTap,
    required this.timings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      runAlignment: WrapRunAlignment.end,
      textDirection: TextDirection.rtl,
      spacing: 4,
      runSpacing: 8,
      children: words.map((word) {
        final isCurrentWord = word.id == currentWordId;
        final hasAudioTiming = timings.containsKey(word.id);

        return ScaleTransition(
          scale: isCurrentWord
              ? AlwaysStoppedAnimation(1.1)
              : AlwaysStoppedAnimation(1.0),
          child: _WordChip(
            word: word,
            isHighlighted: isCurrentWord,
            isClickable: hasAudioTiming,
            onTap: () => onWordTap(word),
          ),
        );
      }).toList(),
    );
  }
}

/// Individual word chip with highlight effect
class _WordChip extends StatelessWidget {
  final Word word;
  final bool isHighlighted;
  final bool isClickable;
  final VoidCallback onTap;

  const _WordChip({
    Key? key,
    required this.word,
    required this.isHighlighted,
    required this.isClickable,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: isClickable ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isHighlighted
                ? Theme.of(context).colorScheme.secondary
                : (isClickable
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHighlighted
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.outline,
              width: isHighlighted ? 2 : 1,
            ),
          ),
          child: Text(
            word.text,
            style: GoogleFonts.amiri(
              fontSize: 18,
              fontWeight:
                  isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted
                  ? Theme.of(context).colorScheme.onSecondary
                  : Theme.of(context).colorScheme.onSurface,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
