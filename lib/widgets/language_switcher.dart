
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isArabic = lang.locale.languageCode == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: OutlinedButton(
        onPressed: () {
          lang.setLocale(Locale(isArabic ? 'en' : 'ar'));
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade400),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        child: Text(
          isArabic ? 'English' : 'العربية',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
