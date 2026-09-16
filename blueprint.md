# Project Blueprint

## Overview

This project is a Flutter application that provides a platform for students from grade 1 to grade 6 to access their lessons. Each grade has a set of subjects (ARABIC, ENGLISH, religion, MATHS, socials, science), and each subject can have multiple books. The application supports both English and Arabic languages with a language switcher.

## Style, Design, and Features

### Implemented

*   **Dynamic Content Loading:**
    *   **Dynamic Book Loading:** The `BooksScreen` dynamically scans the project's asset directory to find and display available books for each subject.
    *   **Book-Specific Lessons:** The `LessonScreen` loads and displays content (images) from the specific book selected by the user.
*   **Enhanced Reading Experience:**
    *   **Two-Page View:** The lesson screen features a two-page, side-by-side layout that simulates an open book.
    *   **RTL & LTR Reading:** The page flow automatically adjusts for right-to-left (RTL) or left-to-right (LTR) reading based on the selected language.
    *   **Multi-Modal Navigation:** Supports page turning via touch gestures (swipe) and keyboard/TV remote (arrow keys).
*   **Polished and Consistent UI:**
    *   **Grades & Subjects Screens:** Both screens feature a responsive grid layout, smooth hover animations, and theme-based styling for a unified look and feel.
    *   **RTL Text Correction:** Ensured correct right-to-left (RTL) display for Arabic text across the application.
    *   **UI Alignment:** Centered the welcome message on the `GradesScreen` for better visual balance.
    *   **Mobile View Fix:** Resolved layout and overflow issues on mobile devices.
*   **Core Functionality:**
    *   **Localization:** Support for English and Arabic languages with a language switcher. The default language is set to Arabic.
    *   **State Management:** Uses the `provider` package for state management.
    *   **Image Handling:** Includes functionality to pick an image from the gallery and uses local assets for grade images.
    *   **Icon Display Fix:** Corrected an issue where the application icon was not displaying properly.

### Bug Fixes

*   **Localization Path Correction:** Fixed a bug where books would not appear when the language was set to Arabic. The asset path now uses a language-independent ID instead of the translated subject title, ensuring content is always found correctly.
*   **Lesson Screen Compilation Error:** Fixed a compilation error in the `LessonScreen` caused by an invalid parameter.
*   **Grade Image Display:** Fixed a critical issue where grade images were not appearing on the main screen. This was resolved by:
    *   Correcting the image path in `grades_screen.dart` to load from the project's assets folder instead of the local file system.
    *   Updating `pubspec.yaml` to properly declare all necessary image asset directories.

## Current Plan

The application now has a solid foundation with a consistent and polished user interface. The next steps will focus on expanding the content, adding more features, and further refining the user experience.
