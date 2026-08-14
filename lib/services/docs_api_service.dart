import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/doc_log_entry.dart';

// TODO: بدّل هذا الرابط بالـ endpoint 
const String kApiEndpoint = '';

class DocsApiException implements Exception {
  final String message;
  DocsApiException(this.message);
}

class DocsApiService {
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