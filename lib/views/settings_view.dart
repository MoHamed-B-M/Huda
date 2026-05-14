import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';
import '../services/download_service.dart';

/// Settings view for app customization
class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({Key? key})
      : super(key: key);

  @override
  ConsumerState<SettingsView>
      createState() =>
      _SettingsViewState();
}

class _SettingsViewState
    extends ConsumerState<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final themeConfig =
        ref.watch(themeConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.amiri(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Display settings
            _SettingsSection(
              title: 'Display',
              children: [
                _FontSizeSlider(
                  label: 'Arabic Text Size',
                  value: themeConfig
                      .arabicFontSize,
                  min: 18.0,
                  max: 32.0,
                  onChanged:
                      (value) {
                    ref
                        .read(
                          themeConfigProvider
                              .notifier,
                        )
                        .setArabicFontSize(
                          value,
                        );
                  },
                ),
                _FontSizeSlider(
                  label:
                      'English Text Size',
                  value: themeConfig
                      .englishFontSize,
                  min: 12.0,
                  max: 20.0,
                  onChanged:
                      (value) {
                    ref
                        .read(
                          themeConfigProvider
                              .notifier,
                        )
                        .setEnglishFontSize(
                          value,
                        );
                  },
                ),
                ListTile(
                  title:
                      const Text(
                        'Dynamic Color',
                      ),
                  subtitle: const Text(
                    'Use system colors',
                  ),
                  trailing:
                      Switch(
                    value: themeConfig
                        .enableDynamicColor,
                    onChanged:
                        (value) {
                      ref
                          .read(
                            themeConfigProvider
                                .notifier,
                          )
                          .setDynamicColor(
                            value,
                          );
                    },
                  ),
                ),
                _ThemeModeSelector(
                  currentMode:
                      themeConfig
                          .themeMode,
                  onChanged:
                      (mode) {
                    ref
                        .read(
                          themeConfigProvider
                              .notifier,
                        )
                        .setThemeMode(
                          mode,
                        );
                  },
                ),
              ],
            ),
            // Downloads settings
            _DownloadsSection(),
            // About section
            _SettingsSection(
              title: 'About',
              children: [
                ListTile(
                  title:
                      const Text(
                        'App Version',
                      ),
                  trailing: const Text(
                    '1.0.0',
                  ),
                ),
                ListTile(
                  title:
                      const Text(
                        'Data Source',
                      ),
                  subtitle: const Text(
                    'Quran.com API v4',
                  ),
                  trailing: Icon(
                    Icons
                        .open_in_new,
                    size: 20,
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .primary,
                  ),
                  onTap: () {
                    // Open Quran.com
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Settings section header
class _SettingsSection
    extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.fromLTRB(
            16,
            20,
            16,
            8,
          ),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(
                  color: Theme.of(
                    context,
                  )
                      .colorScheme
                      .primary,
                  fontWeight:
                      FontWeight.w600,
                ),
          ),
        ),
        ...children,
      ],
    );
  }
}

/// Font size slider widget
class _FontSizeSlider
    extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final Function(double)
      onChanged;

  const _FontSizeSlider({
    Key? key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              Text(label),
              Text(
                value
                    .toStringAsFixed(0),
                style: Theme.of(
                  context,
                )
                    .textTheme
                    .labelMedium
                    ?.copyWith(
                  color: Theme.of(
                    context,
                  )
                      .colorScheme
                      .primary,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged:
                onChanged,
          ),
        ],
      ),
    );
  }
}

/// Theme mode selector
class _ThemeModeSelector
    extends StatelessWidget {
  final ThemeMode currentMode;
  final Function(ThemeMode)
      onChanged;

  const _ThemeModeSelector({
    Key? key,
    required this.currentMode,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.light,
                label: Row(
                  children: [
                    const Icon(
                      Icons.light_mode,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    const Text(
                      'Light',
                    ),
                  ],
                ),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Row(
                  children: [
                    const Icon(
                      Icons.dark_mode,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    const Text(
                      'Dark',
                    ),
                  ],
                ),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                label: Row(
                  children: [
                    const Icon(
                      Icons.settings,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    const Text(
                      'System',
                    ),
                  ],
                ),
              ),
            ],
            selected: {currentMode},
            onSelectionChanged:
                (newSelection) {
              onChanged(
                newSelection.first,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Downloads management section
class _DownloadsSection
    extends ConsumerWidget {
  const _DownloadsSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref) {
    final downloadedSizeAsync =
        ref.watch(
          downloadedSizeProvider,
        );
    final downloadedSurahsAsync =
        ref.watch(
          downloadedSurahsProvider,
        );

    return _SettingsSection(
      title: 'Downloads',
      children: [
        downloadedSizeAsync.when(
          loading: () => const Padding(
            padding:
                EdgeInsets.all(16),
            child:
                CircularProgressIndicator(),
          ),
          error: (err, stack) =>
              const Padding(
            padding:
                EdgeInsets.all(16),
            child: Text(
              'Error loading downloads',
            ),
          ),
          data: (size) => ListTile(
            title: const Text(
              'Total Downloaded',
            ),
            trailing: Text(
              _formatBytes(size),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium,
            ),
          ),
        ),
        downloadedSurahsAsync.when(
          loading: () => const SizedBox(),
          error: (err, stack) =>
              const SizedBox(),
          data: (surahs) =>
              surahs.isNotEmpty
                  ? ListTile(
                title: const Text(
                  'Downloaded Surahs',
                ),
                subtitle: Text(
                  '${surahs.length} Surahs',
                ),
                trailing:
                    const Icon(
                  Icons
                      .chevron_right,
                ),
                onTap: () {
                  _showDownloadedList(
                    context,
                    surahs,
                    ref,
                  );
                },
              )
                  : const ListTile(
                title: Text(
                  'No downloads yet',
                ),
              ),
        ),
        ListTile(
          title: const Text(
            'Clear All',
          ),
          subtitle: const Text(
            'Delete all downloads',
          ),
          trailing: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onTap: () {
            _showClearDialog(
              context,
              ref,
            );
          },
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes <
        1024 *
            1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  void _showDownloadedList(
    BuildContext context,
    List<Map<String, int>> surahs,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        children: surahs
            .map(
              (surah) =>
                  ListTile(
                title: Text(
                  'Surah ${surah['surahNumber']}',
                ),
                subtitle: Text(
                  'Reciter: ${surah['reciterId']}',
                ),
                trailing:
                    IconButton(
                  icon: const Icon(
                    Icons.delete,
                  ),
                  onPressed: () {
                    // Delete download
                    Navigator.pop(
                      context,
                    );
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _showClearDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
        title: const Text(
          'Clear all downloads?',
        ),
        content: const Text(
          'This will free up storage space.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
              context,
            ),
            child: const Text(
              'Cancel',
            ),
          ),
          FilledButton(
            onPressed: () {
              // Clear all
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
            ),
          ),
        ],
      ),
    );
  }
}
