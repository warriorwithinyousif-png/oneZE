
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/grade.dart';
import '../providers/language_provider.dart';
import 'subjects_screen.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  late List<FocusNode> _focusNodes;
  late Future<List<Grade>> _gradesFuture;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gradesFuture = _loadGrades();
  }

  Future<List<Grade>> _loadGrades() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final isArabic = lang.locale.languageCode == 'ar';

    return List.generate(
      6,
      (index) => Grade(
        number: index + 1,
        title: isArabic ? 'الصف ${index + 1}' : 'Grade ${index + 1}',
        image: 'assets/images/grades/grade_${index + 1}.png',
      ),
    );
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isArabic = lang.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/icon/icon.png', height: 40),
            const SizedBox(width: 8),
            Text(
              isArabic
                  ? 'الزقورة للقراءة الإلكترونية'
                  : 'Al-Zaqura e-Reader',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<LanguageProvider>(context, listen: false)
                  .toggleLocale();
            },
            child: Text(
              isArabic ? 'English' : 'العربية',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              isArabic
                  ? 'مرحباً بك في الزقورة للقراءة الإلكترونية'
                  : 'Welcome to Al-Zaqura e-Reader',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'مكتبتك الرقمية للصفوف من الأول إلى السادس'
                  : 'Your digital library from Grade 1 to 6',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<Grade>>(
                future: _gradesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No grades found.'));
                  } else {
                    final grades = snapshot.data!;
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 350,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: grades.length,
                      itemBuilder: (context, index) {
                        return GradeCard(
                          grade: grades[index],
                          focusNode: _focusNodes[index],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradeCard extends StatefulWidget {
  const GradeCard({
    super.key,
    required this.grade,
    required this.focusNode,
  });

  final Grade grade;
  final FocusNode focusNode;

  @override
  State<GradeCard> createState() => _GradeCardState();
}

class _GradeCardState extends State<GradeCard> {
  bool _isFocused = false;
  bool _isHovered = false;

  bool get _active => _isFocused || _isHovered;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isArabic = lang.locale.languageCode == 'ar';

    return FocusableActionDetector(
      focusNode: widget.focusNode,
      autofocus: widget.grade.number == 1,
      onShowFocusHighlight: (value) {
        setState(() => _isFocused = value);
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SubjectsScreen(grade: widget.grade),
              ),
            );
            return null;
          },
        ),
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _active ? 1.07 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Card(
            elevation: _active ? 10 : 3,
            shape: RoundedRectangleBorder(
              side: _active
                  ? BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubjectsScreen(grade: widget.grade),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Image.asset(
                      widget.grade.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image, size: 40),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: isArabic
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.grade.title,
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign:
                                isArabic ? TextAlign.right : TextAlign.left,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isArabic
                                ? 'استكشف مواد الصف ${widget.grade.number}'
                                : 'Explore Grade ${widget.grade.number} subjects',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign:
                                isArabic ? TextAlign.right : TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
