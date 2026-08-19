import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_colors.dart';
import 'screens/docs_log_page.dart';

/// نقطة الدخول الرئيسية للتطبيق، تقوم بتشغيل الـ Widget الأساسي [AutoDocsApp].
void main() {
  runApp(const AutoDocsApp());
}

/// التطبيق الأساسي (Root Widget) لمشروع Auto Docs.
///
/// يقوم هذا الكلاس بتهيئة السمات البصرية (Themes) مثل الألوان والخطوط،
/// ويحدد [DocsLogPage] كشاشة رئيسية للتطبيق مع دعم الاتجاه من اليمين لليسار.
class AutoDocsApp extends StatelessWidget {
  /// ينشئ نسخة من [AutoDocsApp].
  const AutoDocsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سجل التوثيق · Auto Docs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: DocsLogPage(),
      ),
    );
  }
}