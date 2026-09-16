
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/grade.dart';
import '../models/subject.dart';
import '../providers/language_provider.dart';
import 'books_screen.dart';

class SubjectsScreen extends StatefulWidget {
  final Grade grade;

  const SubjectsScreen({super.key, required this.grade});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  late List<FocusNode> _focusNodes;
  
  final List<Subject> _subjects = [
    Subject(id: 'islamic_education', title: 'Islamic Education', icon: Icons.mosque_outlined),
    Subject(id: 'Arabic', title: 'Arabic', icon: Icons.translate),
    Subject(id: 'English', title: 'English', icon: Icons.book_outlined),
    Subject(id: 'math', title: 'Math', icon: Icons.calculate),
    Subject(id: 'science', title: 'Science', icon: Icons.science_outlined),
    Subject(id: 'social_studies', title: 'Social Studies', icon: Icons.group_outlined),
  ];

  final Map<String, Map<String, String>> _subjectTitles = {
    'math': {'en': 'Math', 'ar': 'الرياضيات'},
    'science': {'en': 'Science', 'ar': 'العلوم'},
    'English': {'en': 'English', 'ar': 'اللغة الإنكليزية'},
    'Arabic': {'en': 'Arabic', 'ar': 'اللغة العربية'},
    'islamic_education': {'en': 'Islamic Education', 'ar': 'التربية الإسلامية'},
    'social_studies': {'en': 'Social Studies', 'ar': 'ألإجتماعيات'},
  };

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(_subjects.length, (_) => FocusNode());
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'مواد ${widget.grade.title}' : '${widget.grade.title} Subjects'),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<LanguageProvider>(context, listen: false).toggleLocale();
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
              isArabic ? 'اختر مادة' : 'Choose a Subject',
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
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  final subject = _subjects[index];
                  final subjectTitle = _subjectTitles[subject.id]?[isArabic ? 'ar' : 'en'] ?? subject.title;
                  return SubjectCard(
                    subject: subject,
                    grade: widget.grade,
                    focusNode: _focusNodes[index],
                    autofocus: index == 0,
                    title: subjectTitle,
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

/* -------------------------------------------------------------------------- */
/*                                Subject Card                                */
/* -------------------------------------------------------------------------- */

class SubjectCard extends StatefulWidget {
  const SubjectCard({
    super.key,
    required this.subject,
    required this.grade,
    required this.focusNode,
    this.autofocus = false,
    required this.title,
  });

  final Subject subject;
  final Grade grade;
  final FocusNode focusNode;
  final bool autofocus;
  final String title;

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  bool _isFocused = false;
  bool _isHovered = false;

  bool get _active => _isFocused || _isHovered;

  void _navigateToBooksScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BooksScreen(
          grade: widget.grade,
          subject: widget.subject,
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
            _navigateToBooksScreen();
            return null;
          },
        ),
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Card(
          clipBehavior: Clip.none, // Allow the icon to pop out
          elevation: _active ? 10 : 4,
          shape: RoundedRectangleBorder(
            side: _active
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: _navigateToBooksScreen,
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
                          widget.subject.icon,
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
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
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
