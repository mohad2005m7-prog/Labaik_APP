import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

// -------------------------------------------------------------
// ApiClient — طلبات JSON محمية لسيرفر لبيك:
// كل طلب مع  Authorization: Bearer <accessToken>  — ولو رجع 401 بنجدد التوكن ونعيد الطلب مرة وحدة
// وكمان 403 (ملف السيرفر: "إن وصلك 403 غير متوقع فجدّد التوكن" — الدور بيتحدّث من التوكن الجديد)
// الرد: JSON (أو null لو فاضي) — وأي رد غير 2xx أو انقطاع → ApiException
// [accessToken] و [refreshToken] بيوصلوا من برا (طبقة الـ auth) حتى ما يعتمد الـ core على feature
// -------------------------------------------------------------
class ApiClient {
  final String baseUrl;
  final Future<String?> Function() accessToken;
  final Future<String?> Function() refreshToken;
  final Duration timeout;
  final http.Client _http;

  ApiClient({required this.baseUrl, required this.accessToken, required this.refreshToken, this.timeout = ApiConfig.timeout, http.Client? client}) : _http = client ?? http.Client();

  Uri uri(String path, [Map<String, String>? query]) {
    final url = Uri.parse('$baseUrl$path');
    return query == null || query.isEmpty ? url : url.replace(queryParameters: query);
  }

  Future<Object?> getJson(String path, {Map<String, String>? query}) {
    return _send((headers) => _http.get(uri(path, query), headers: headers));
  }

  Future<Object?> postJson(String path, {Object? body}) {
    return _send((headers) => _http.post(uri(path), headers: {...headers, 'Content-Type': 'application/json'}, body: body == null ? null : jsonEncode(body)));
  }

  Future<Object?> putJson(String path, {Object? body}) {
    return _send((headers) => _http.put(uri(path), headers: {...headers, 'Content-Type': 'application/json'}, body: body == null ? null : jsonEncode(body)));
  }

  Future<Object?> delete(String path) => _send((headers) => _http.delete(uri(path), headers: headers));

  /// multipart/form-data — [files]: اسم الحقل → مسار الملف على الجهاز
  Future<Object?> postMultipart(String path, {Map<String, String> fields = const {}, Map<String, String> files = const {}}) {
    return _send((headers) async {
      final request = http.MultipartRequest('POST', uri(path))
        ..headers.addAll(headers)
        ..fields.addAll(fields);
      for (final file in files.entries) {
        request.files.add(await http.MultipartFile.fromPath(file.key, file.value));
      }
      return http.Response.fromStream(await _http.send(request));
    });
  }

  Future<Object?> _send(Future<http.Response> Function(Map<String, String> headers) request) async {
    try {
      var response = await request(_headers(await accessToken())).timeout(timeout);
      if (response.statusCode == 401 || response.statusCode == 403) {
        final renewed = await refreshToken();
        if (renewed != null && renewed.isNotEmpty) {
          response = await request(_headers(renewed)).timeout(timeout);
        }
      }
      if (response.statusCode < 200 || response.statusCode >= 300) throw ApiException(response.statusCode);
      final body = utf8.decode(response.bodyBytes);
      return body.trim().isEmpty ? null : jsonDecode(body);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(null);
    } on SocketException {
      throw const ApiException(null);
    } on http.ClientException {
      throw const ApiException(null);
    } on HandshakeException {
      throw const ApiException(null);
    } on FormatException {
      // رد مش JSON (صفحة خطأ من الاستضافة مثلاً)
      throw const ApiException(502);
    }
  }

  Map<String, String> _headers(String? token) => {'Accept': 'application/json', if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'};
}
