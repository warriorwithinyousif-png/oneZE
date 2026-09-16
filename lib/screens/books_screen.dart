import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../models/grade.dart';
import '../models/subject.dart';
import '../providers/language_provider.dart';
import 'lesson_screen.dart';

class BooksScreen extends StatefulWidget {
  final Grade grade;
  final Subject subject;

  const BooksScreen({super.key, required this.grade, required this.subject});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<Book> _books = [];
  List<FocusNode> _focusNodes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _formatBookTitle(String folderName, bool isArabic) {
    final lower = folderName.toLowerCase().replaceAll('-', '').replaceAll(' ', '');
    if (lower == 'book1' || lower == '1') {
      return isArabic ? 'الكتاب الأول' : 'Book 1';
    } else if (lower == 'book2' || lower == '2') {
      return isArabic ? 'الكتاب الثاني' : 'Book 2';
    }
    return folderName.replaceAll('-', ' ');
  }

  Future<void> _loadBooks() async {
    final booksFound = <String, Book>{};

    try {
      // 1. Check bundled assets first (offline-first)
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assetKeys = manifest.listAssets();
      final prefix = 'assets/images/Grade-${widget.grade.number}/${widget.subject.id}/'.toLowerCase();

      for (final key in assetKeys) {
        final lowerKey = key.toLowerCase();
        if (lowerKey.startsWith(prefix)) {
          final remaining = key.substring(prefix.length);
          final segments = remaining.split('/');
          if (segments.isNotEmpty && segments[0].isNotEmpty) {
            final folder = segments[0];
            if (!booksFound.containsKey(folder.toLowerCase())) {
              booksFound[folder.toLowerCase()] = Book(
                title: folder,
                path: folder,
                isAsset: true,
              );
            }
          }
        }
      }

      // 2. Also check local application documents directory fallback
      final appDir = await getApplicationDocumentsDirectory();
      final candidateDirs = [
        Directory('${appDir.path}/Book/grade ${widget.grade.number}/${widget.subject.id}'),
        Directory('${appDir.path}/Book/Grade-${widget.grade.number}/${widget.subject.id}'),
      ];

      for (final dir in candidateDirs) {
        if (await dir.exists()) {
          final entities = dir.listSync();
          for (final entity in entities) {
            if (entity is Directory) {
              final folder = entity.uri.pathSegments.where((s) => s.isNotEmpty).last;
              if (!booksFound.containsKey(folder.toLowerCase())) {
                booksFound[folder.toLowerCase()] = Book(
                  title: folder,
                  path: entity.path,
                  isAsset: false,
                );
              }
            }
          }
        }
      }
    } catch (_) {
      // Graceful fallback
    }

    // Sort books naturally (book1 before book2)
    final sortedList = booksFound.values.toList()
      ..sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    if (!mounted) return;

    setState(() {
      _books = sortedList;
      _focusNodes = List.generate(_books.length, (_) => FocusNode());
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isArabic = lang.locale.languageCode == 'ar';
    final theme = Theme.of(context);

    final subjectTitles = {
      'math': {'en': 'Math', 'ar': 'الرياضيات'},
      'science': {'en': 'Science', 'ar': 'العلوم'},
      'English': {'en': 'English', 'ar': 'اللغة الإنكليزية'},
      'Arabic': {'en': 'Arabic', 'ar': 'اللغة العربية'},
      'islamic_education': {'en': 'Islamic Education', 'ar': 'التربية الإسلامية'},
      'social_studies': {'en': 'Social Studies', 'ar': 'الاجتماعيات'},
    };

    final subjectTitle =
        subjectTitles[widget.subject.id]?[isArabic ? 'ar' : 'en'] ?? widget.subject.title;

    return Scaffold(
      appBar: AppBar(
        title: Text(subjectTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_rounded, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        isArabic ? 'لا توجد كتب متوفرة لهذه المادة' : 'No books available for this subject',
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        isArabic ? 'اختر كتابًا' : 'Choose a Book',
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 250,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 1,
                          ),
                          itemCount: _books.length,
                          itemBuilder: (context, index) {
                            final book = _books[index];
                            final displayTitle = _formatBookTitle(book.title, isArabic);

                            return BookCard(
                              grade: widget.grade,
                              subject: widget.subject,
                              book: book,
                              displayTitle: displayTitle,
                              focusNode: _focusNodes[index],
                              autofocus: index == 0,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class BookCard extends StatefulWidget {
  const BookCard({
    super.key,
    required this.grade,
    required this.subject,
    required this.book,
    required this.displayTitle,
    required this.focusNode,
    this.autofocus = false,
  });

  final Grade grade;
  final Subject subject;
  final Book book;
  final String displayTitle;
  final FocusNode focusNode;
  final bool autofocus;

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool _isFocused = false;
  bool _isHovered = false;

  bool get _active => _isFocused || _isHovered;

  void _navigateToLessonScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LessonScreen(
          grade: widget.grade,
          subject: widget.subject,
          book: widget.book,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FocusableActionDetector(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onShowFocusHighlight: (value) => setState(() => _isFocused = value),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _navigateToLessonScreen();
            return null;
          },
        ),
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Card(
          clipBehavior: Clip.none,
          elevation: _active ? 10 : 4,
          shape: RoundedRectangleBorder(
            side: _active
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: _navigateToLessonScreen,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: AnimatedScale(
                      scale: _active ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _active
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.08),
                        ),
                        child: Icon(
                          Icons.book_outlined,
                          size: 70,
                          color: _active
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.displayTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
