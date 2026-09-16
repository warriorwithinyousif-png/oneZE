import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../models/grade.dart';
import '../models/subject.dart';
import '../providers/language_provider.dart';
import 'photo_view_screen.dart';

class LessonScreen extends StatefulWidget {
  final Grade grade;
  final Subject subject;
  final Book book;

  const LessonScreen({
    super.key,
    required this.grade,
    required this.subject,
    required this.book,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late PageController _pageController;
  final FocusNode _focusNode = FocusNode();

  List<String> _imagePaths = [];
  bool _isLoading = true;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadImages();
  }

  int _naturalCompare(String a, String b) {
    final nameA = a.split(RegExp(r'[/\\]')).last;
    final nameB = b.split(RegExp(r'[/\\]')).last;

    final reg = RegExp(r'\d+');
    final matchesA = reg.allMatches(nameA).toList();
    final matchesB = reg.allMatches(nameB).toList();

    if (matchesA.isNotEmpty && matchesB.isNotEmpty) {
      if (matchesA.length > 1 && matchesB.length > 1) {
        final numA1 = int.tryParse(matchesA[0].group(0)!) ?? 0;
        final numB1 = int.tryParse(matchesB[0].group(0)!) ?? 0;
        if (numA1 != numB1) return numA1.compareTo(numB1);

        final numA2 = int.tryParse(matchesA[1].group(0)!) ?? 0;
        final numB2 = int.tryParse(matchesB[1].group(0)!) ?? 0;
        return numA2.compareTo(numB2);
      }

      final numA = int.tryParse(matchesA[0].group(0)!) ?? 0;
      final numB = int.tryParse(matchesB[0].group(0)!) ?? 0;
      if (numA != numB) return numA.compareTo(numB);
    }
    return nameA.compareTo(nameB);
  }

  bool _isImageFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  Future<void> _loadImages() async {
    List<String> images = [];

    try {
      if (widget.book.isAsset) {
        // Load from assets
        final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
        final assetKeys = manifest.listAssets();
        final prefix =
            'assets/images/Grade-${widget.grade.number}/${widget.subject.id}/${widget.book.path}/'
                .toLowerCase();

        images = assetKeys.where((key) {
          final lower = key.toLowerCase();
          return lower.startsWith(prefix) && _isImageFile(key);
        }).toList();
      } else {
        // Load from local file directory
        final dir = Directory(widget.book.path);
        if (await dir.exists()) {
          images = dir
              .listSync()
              .whereType<File>()
              .map((e) => e.path)
              .where(_isImageFile)
              .toList();
        }
      }

      // Fallback: check documents directory if assets empty
      if (images.isEmpty) {
        final appDir = await getApplicationDocumentsDirectory();
        final candidateDirs = [
          Directory('${appDir.path}/Book/grade ${widget.grade.number}/${widget.subject.id}/${widget.book.path}'),
          Directory('${appDir.path}/Book/Grade-${widget.grade.number}/${widget.subject.id}/${widget.book.path}'),
        ];
        for (final bookDir in candidateDirs) {
          if (await bookDir.exists()) {
            final fileList = bookDir
                .listSync()
                .whereType<File>()
                .map((e) => e.path)
                .where(_isImageFile)
                .toList();
            if (fileList.isNotEmpty) {
              images = fileList;
              break;
            }
          }
        }
      }
    } catch (_) {
      // Graceful handling
    }

    images.sort(_naturalCompare);

    if (!mounted) return;

    setState(() {
      _imagePaths = images;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openPhotoView(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoViewScreen(imagePath: path),
      ),
    );
  }

  void _handleKeys(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final isArabic =
        context.read<LanguageProvider>().locale.languageCode == 'ar';

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      isArabic
          ? _pageController.previousPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.ease,
            )
          : _pageController.nextPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.ease,
            );
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      isArabic
          ? _pageController.nextPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.ease,
            )
          : _pageController.previousPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.ease,
            );
    }
  }

  Widget _buildImageWidget(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, size: 48, color: Colors.white54),
        ),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, size: 48, color: Colors.white54),
        ),
      );
    }
  }

  String _formatBookHeader(bool isArabic) {
    final lower = widget.book.title.toLowerCase().replaceAll('-', '').replaceAll(' ', '');
    if (lower == 'book1' || lower == '1') {
      return isArabic ? 'الكتاب الأول' : 'Book 1';
    } else if (lower == 'book2' || lower == '2') {
      return isArabic ? 'الكتاب الثاني' : 'Book 2';
    }
    return widget.book.title.replaceAll('-', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        context.watch<LanguageProvider>().locale.languageCode == 'ar';
    final bool isTV = MediaQuery.of(context).size.shortestSide >= 600;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_focusNode.hasFocus) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });

    final totalPages = _imagePaths.length;
    String pageIndicatorText = '';
    if (totalPages > 0) {
      if (!isTV) {
        final current = _currentPageIndex + 1;
        pageIndicatorText = isArabic
            ? 'صفحة $current من $totalPages'
            : 'Page $current of $totalPages';
      } else {
        final p1 = _currentPageIndex * 2 + 1;
        final p2 = (_currentPageIndex * 2 + 2).clamp(1, totalPages);
        pageIndicatorText = isArabic
            ? (p1 == p2 ? 'صفحة $p1 من $totalPages' : 'صفحات $p1-$p2 من $totalPages')
            : (p1 == p2 ? 'Page $p1 of $totalPages' : 'Pages $p1-$p2 of $totalPages');
      }
    }

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeys,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 2,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            _formatBookHeader(isArabic),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            if (pageIndicatorText.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pageIndicatorText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _imagePaths.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book, size: 60, color: Colors.white38),
                        const SizedBox(height: 16),
                        Text(
                          isArabic ? 'لم يتم العثور على صفحات لهذا الكتاب' : 'No lesson content found',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : isTV
                    ? _buildTVView(isArabic)
                    : _buildMobileView(isArabic),
      ),
    );
  }

  // 📱 MOBILE → صورة واحدة
  Widget _buildMobileView(bool isArabic) {
    return PageView.builder(
      controller: _pageController,
      reverse: isArabic,
      itemCount: _imagePaths.length,
      onPageChanged: (index) {
        setState(() {
          _currentPageIndex = index;
        });
      },
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _openPhotoView(_imagePaths[index]),
          child: Center(
            child: _buildImageWidget(_imagePaths[index]),
          ),
        );
      },
    );
  }

  // 📺 TV / Tablet → صورتان جنب بعض بتنسيق كتاب مفتوح
  Widget _buildTVView(bool isArabic) {
    final int pageCount = (_imagePaths.length / 2).ceil();

    return PageView.builder(
      controller: _pageController,
      reverse: isArabic,
      itemCount: pageCount,
      onPageChanged: (index) {
        setState(() {
          _currentPageIndex = index;
        });
      },
      itemBuilder: (context, index) {
        final int i1 = index * 2;
        final int i2 = i1 + 1;

        Widget buildSinglePage(int imgIndex) {
          if (imgIndex >= _imagePaths.length) {
            return const Expanded(child: SizedBox());
          }
          final path = _imagePaths[imgIndex];
          return Expanded(
            child: GestureDetector(
              onTap: () => _openPhotoView(path),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Center(
                  child: _buildImageWidget(path),
                ),
              ),
            ),
          );
        }

        // In Arabic (RTL book layout), right page is earlier, left page is later
        return Row(
          children: isArabic
              ? [
                  buildSinglePage(i2), // Left page
                  buildSinglePage(i1), // Right page
                ]
              : [
                  buildSinglePage(i1), // Left page
                  buildSinglePage(i2), // Right page
                ],
        );
      },
    );
  }
}
