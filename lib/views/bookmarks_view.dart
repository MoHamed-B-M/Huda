import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/local_storage_model.dart';
import '../services/storage_service.dart';
import 'quran_reader_view.dart';

/// Bookmarks and Favorites view
class BookmarksView extends ConsumerStatefulWidget {
  const BookmarksView({Key? key}) : super(key: key);

  @override
  ConsumerState<BookmarksView> createState() => _BookmarksViewState();
}

class _BookmarksViewState extends ConsumerState<BookmarksView> {
  @override
  Widget build(BuildContext context) {
    final bookmarksAsync = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarks',
          style: GoogleFonts.amiri(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          bookmarksAsync.maybeWhen(
            data: (bookmarks) => bookmarks.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    onPressed: () => _showClearDialog(context),
                  )
                : null,
            orElse: () => null,
          ),
        ],
      ),
      body: bookmarksAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
        data: (bookmarks) {
          if (bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 64,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarks yet',
                    style:
                        Theme.of(context)
                            .textTheme
                            .bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create bookmarks while reading',
                    style:
                        Theme.of(context)
                            .textTheme
                            .bodySmall,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];
              return _BookmarkListItem(
                bookmark: bookmark,
                onDelete: () =>
                    ref
                        .read(
                          removeBookmarkProvider(
                            bookmark.id,
                          ).future,
                        )
                        .then((_) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content:
                                  Text(
                                'Bookmark removed',
                              ),
                              duration:
                                  Duration(
                                    seconds:
                                        2,
                                  ),
                            ),
                          );
                        }),
              );
            },
          );
        },
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all bookmarks?'),
        content: const Text(
            'This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Clear all bookmarks logic
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Individual bookmark list item
class _BookmarkListItem extends ConsumerWidget {
  final Bookmark bookmark;
  final VoidCallback onDelete;

  const _BookmarkListItem({
    Key? key,
    required this.bookmark,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormatter =
        DateFormat('MMM d, yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        variant: CardVariant.outlined,
        child: InkWell(
          onTap: () {
            // Navigate to that location
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    QuranReaderPage(
                  surah: null,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(
              16,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            bookmark.label,
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
                            'Surah ${bookmark.surahNumber}${bookmark.ayahNumber != null ? ':${bookmark.ayahNumber}' : ''}',
                            style: Theme.of(
                              context,
                            )
                                .textTheme
                                .labelSmall,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder:
                          (context) => [
                        PopupMenuItem(
                          child:
                              const Text(
                            'Edit',
                          ),
                          onTap: () {
                            _showEditDialog(
                              context,
                              ref,
                            );
                          },
                        ),
                        PopupMenuItem(
                          child:
                              const Text(
                            'Delete',
                          ),
                          onTap:
                              onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
                if (bookmark.notes != null)
                  Padding(
                    padding:
                        const EdgeInsets
                            .only(
                          top: 12,
                        ),
                    child: Text(
                      bookmark.notes!,
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style: Theme.of(
                        context,
                      )
                          .textTheme
                          .bodySmall,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Saved ${dateFormatter.format(bookmark.createdAt)}',
                  style:
                      Theme.of(context)
                          .textTheme
                          .labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(
      BuildContext context,
      WidgetRef ref) {
    final labelController =
        TextEditingController(
          text: bookmark.label,
        );
    final notesController =
        TextEditingController(
          text: bookmark.notes ?? '',
        );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Bookmark'),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            TextField(
              controller:
                  labelController,
              decoration:
                  const InputDecoration(
                hintText:
                    'Bookmark label',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller:
                  notesController,
              decoration:
                  const InputDecoration(
                hintText: 'Notes',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Update bookmark
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

/// Add bookmark dialog
class AddBookmarkDialog extends StatefulWidget {
  final int surahNumber;
  final int? ayahNumber;

  const AddBookmarkDialog({
    Key? key,
    required this.surahNumber,
    this.ayahNumber,
  }) : super(key: key);

  @override
  State<AddBookmarkDialog>
      createState() =>
      _AddBookmarkDialogState();
}

class _AddBookmarkDialogState
    extends State<AddBookmarkDialog> {
  late TextEditingController
      _labelController;
  late TextEditingController
      _notesController;

  @override
  void initState() {
    super.initState();
    _labelController =
        TextEditingController(
      text:
          'Surah ${widget.surahNumber}${widget.ayahNumber != null ? ':${widget.ayahNumber}' : ''}',
    );
    _notesController =
        TextEditingController();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Bookmark'),
      content: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          TextField(
            controller:
                _labelController,
            decoration:
                const InputDecoration(
              labelText:
                  'Bookmark name',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller:
                _notesController,
            decoration:
                const InputDecoration(
              labelText: 'Notes',
              hintText:
                  'Add optional notes...',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            // Add bookmark
            Navigator.pop(context);
            ScaffoldMessenger.of(context)
                .showSnackBar(
              const SnackBar(
                content: Text(
                  'Bookmark added',
                ),
                duration:
                    Duration(
                      seconds: 2,
                    ),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
