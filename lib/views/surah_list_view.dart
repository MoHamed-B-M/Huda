import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import '../models/surah.dart';
import '../providers/surah_provider.dart';
import 'quran_reader_view.dart';

/// Home page showing list of Surahs with search functionality
class SurahListView extends ConsumerWidget {
  const SurahListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(filteredSurahsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quran',
          style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // Search bar using SearchAnchor
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchAnchor(
              builder: (context, controller) {
                return SearchBar(
                  controller: controller,
                  hintText: 'Search Surah...',
                  leading: const Icon(Icons.search),
                  onTap: () => controller.openView(),
                  onChanged: (value) {
                    ref
                        .read(searchQueryProvider.notifier)
                        .state = value;
                  },
                  trailing: searchQuery.isNotEmpty
                      ? [
                          IconButton(
                            onPressed: () {
                              controller.clear();
                              ref
                                  .read(searchQueryProvider
                                      .notifier)
                                  .state = '';
                            },
                            icon: const Icon(Icons.clear),
                          ),
                        ]
                      : null,
                );
              },
              suggestionsBuilder: (context, controller) {
                return surahsAsync.when(
                  loading: () => [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ],
                  error: (err, stack) => [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error: $err'),
                    ),
                  ],
                  data: (surahs) {
                    return surahs
                        .map(
                          (surah) =>
                              _SurahSearchResult(surah: surah),
                        )
                        .toList();
                  },
                );
              },
            ),
          ),
          // Surah list
          Expanded(
            child: surahsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, stack) => Center(
                child: Text('Error: $err'),
              ),
              data: (surahs) => ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: surahs.length,
                itemBuilder: (context, index) {
                  return _SurahListItem(
                    surah: surahs[index],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual Surah list item with M3 styling
class _SurahListItem extends ConsumerWidget {
  final Surah surah;

  const _SurahListItem({
    Key? key,
    required this.surah,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: OpenContainer(
        transitionType: ContainerTransitionType.fadeThrough,
        closedBuilder: (context, action) {
          return Card(
            variant: CardVariant.outlined,
            margin: EdgeInsets.zero,
            child: InkWell(
              onTap: action,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Surah number badge
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${surah.number}',
                          style:
                              GoogleFonts.amiri(
                            fontSize: 20,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Surah info
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            surah.englishName,
                            style: Theme.of(
                              context,
                            )
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            '${surah.numberOfAyahs} verses • ${surah.revelationType}',
                            style: Theme.of(
                              context,
                            )
                                .textTheme
                                .labelSmall,
                          ),
                        ],
                      ),
                    ),
                    // Arabic name
                    Text(
                      surah.name,
                      style: GoogleFonts
                          .amiri(
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                      textDirection:
                          TextDirection
                              .rtl,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        openBuilder: (context, action) {
          return QuranReaderPage(
            surah: surah,
          );
        },
      ),
    );
  }
}

/// Surah search result item
class _SurahSearchResult extends StatelessWidget {
  final Surah surah;

  const _SurahSearchResult({
    Key? key,
    required this.surah,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(surah.englishName),
      subtitle: Text('Surah ${surah.number}'),
      trailing: Text(surah.name),
      onTap: () {
        // Navigate to reader
        Navigator.of(context).pop();
      },
    );
  }
}

/// Quran reader page with header and footer
class QuranReaderPage extends ConsumerWidget {
  final Surah surah;

  const QuranReaderPage({
    Key? key,
    required this.surah,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          // Reader view
          QuranReaderView(surahNumber: surah.number),
          // Reading/Listening mode toggle
          Positioned(
            top: 16,
            right: 16,
            child: _ReadingModeToggle(surah: surah),
          ),
        ],
      ),
    );
  }
}

/// Toggle between Reading and Listening modes
class _ReadingModeToggle extends ConsumerWidget {
  final Surah surah;

  const _ReadingModeToggle({
    Key? key,
    required this.surah,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modes = ['Reading', 'Listening'];
    final selectedMode =
        ref.watch(
          StateProvider<String>(
            (ref) => 'Reading',
          ),
        );

    return SegmentedButton<String>(
      segments: modes
          .map(
            (mode) => ButtonSegment(
              value: mode,
              label: Text(mode),
            ),
          )
          .toList(),
      selected: {selectedMode},
      onSelectionChanged: (newSelection) {
        // Handle mode switch
      },
    );
  }
}
