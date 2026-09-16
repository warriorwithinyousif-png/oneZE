import 'package:flutter/material.dart';
import 'grades_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final String _status = 'جاري تحضير المحتوى التعليمي...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Brief splash delay to ensure assets are primed and smooth visual presentation
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    _navigateToHome();
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const GradesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icon/icon.png', height: 110),
            const SizedBox(height: 20),
            Text(
              'الزقورة للقراءة الإلكترونية',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0077B6),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Al-Zaqura e-Reader',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF0077B6),
                  ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0077B6)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _status,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF4F4F4F),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
