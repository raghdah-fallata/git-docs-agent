import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/doc_log_entry.dart';

// TODO: بدّل هذا الرابط بالـ endpoint
/// الرابط الأساسي لواجهة برمجة التطبيقات (API) المستخدمة لجلب سجلات التوثيق.
const String kApiEndpoint = " ";

/// استثناء مخصص لمعالجة الأخطاء المتعلقة بخدمة [DocsApiService].
class DocsApiException implements Exception {
  /// رسالة توضح سبب الخطأ.
  final String message;
  DocsApiException(this.message);
}

/// خدمة مسؤولة عن جلب وإدارة سجلات التوثيق من الخادم.
class DocsApiService {
  /// جلب قائمة بسجلات التوثيق من الـ API المحدد في [kApiEndpoint].
  ///
  /// تقوم هذه الدالة بإرسال طلب GET، وفك تشفير الاستجابة بصيغة JSON،
  /// ثم تحويلها إلى قائمة من كائنات [DocLogEntry].
  /// يتم فرز النتائج تنازلياً حسب الطابع الزمني (الأحدث أولاً).
  ///
  /// تُلقي [DocsApiException] في الحالات التالية:
  /// * فشل الاتصال بالشبكة أو انتهاء المهلة (15 ثانية).
  /// * إذا كانت حالة الاستجابة لا تساوي 200.
  Future<List<DocLogEntry>> fetchLog() async {
    final http.Response response;
    try {
      response = await http
          .get(Uri.parse(kApiEndpoint))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw DocsApiException(
          'تعذّر الاتصال بالخادم — تحقق من الشبكة وحاول مرة أخرى');
    }

    if (response.statusCode != 200) {
      throw DocsApiException('فشل تحميل البيانات (رمز ${response.statusCode})');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    final entries = decoded
        .map((e) => DocLogEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return entries;
  }
}