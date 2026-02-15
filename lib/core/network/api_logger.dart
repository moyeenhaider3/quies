import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Dio interceptor that logs all API requests, responses, and errors.
///
/// Logs structured information for every network call including method,
/// URL, status code, timing, request/response bodies, and any errors.
class ApiLoggerInterceptor extends Interceptor {
  int _counter = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestId = _generateRequestId();
    options.extra['_requestId'] = requestId;
    options.extra['_startTime'] = DateTime.now().millisecondsSinceEpoch;

    _logRequest(requestId, options);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestId =
        response.requestOptions.extra['_requestId'] as String? ?? '???';
    final startTime = response.requestOptions.extra['_startTime'] as int? ?? 0;
    final elapsed = Duration(
      milliseconds: DateTime.now().millisecondsSinceEpoch - startTime,
    );

    _logResponse(requestId, response, elapsed);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestId =
        err.requestOptions.extra['_requestId'] as String? ?? '???';
    final startTime = err.requestOptions.extra['_startTime'] as int? ?? 0;
    final elapsed = Duration(
      milliseconds: DateTime.now().millisecondsSinceEpoch - startTime,
    );

    _logError(requestId, err, elapsed);
    handler.next(err);
  }

  void _logRequest(String id, RequestOptions options) {
    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════════')
      ..writeln('║ API REQUEST [$id]')
      ..writeln('╟──────────────────────────────────────────')
      ..writeln('║ ${options.method} ${options.uri}')
      ..writeln('║ Headers: ${_sanitizeHeaders(options.headers)}');

    if (options.data != null) {
      final body = options.data is String
          ? options.data as String
          : json.encode(options.data);
      buffer.writeln('║ Body: ${_truncate(body, 500)}');
    }

    buffer.writeln('╚══════════════════════════════════════════');

    developer.log(
      buffer.toString(),
      name: 'API',
      level: 800, // INFO
    );
  }

  void _logResponse(String id, Response response, Duration elapsed) {
    final isError = (response.statusCode ?? 0) >= 400;
    final body = response.data is String
        ? response.data as String
        : json.encode(response.data);

    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════════')
      ..writeln('║ API RESPONSE [$id] ${isError ? "⚠️ ERROR" : "✓ OK"}')
      ..writeln('╟──────────────────────────────────────────')
      ..writeln(
        '║ ${response.requestOptions.method} ${response.requestOptions.uri}',
      )
      ..writeln('║ Status: ${response.statusCode} ${response.statusMessage}')
      ..writeln('║ Duration: ${elapsed.inMilliseconds}ms')
      ..writeln('║ Body: ${_truncate(body, 800)}')
      ..writeln('╚══════════════════════════════════════════');

    developer.log(
      buffer.toString(),
      name: 'API',
      level: isError ? 1000 : 800, // WARNING for errors, INFO for success
    );
  }

  void _logError(String id, DioException err, Duration elapsed) {
    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════════')
      ..writeln('║ API ERROR [$id]')
      ..writeln('╟──────────────────────────────────────────')
      ..writeln('║ ${err.requestOptions.method} ${err.requestOptions.uri}')
      ..writeln('║ Duration: ${elapsed.inMilliseconds}ms')
      ..writeln('║ Error: ${err.message}')
      ..writeln('║ Type: ${err.type}')
      ..writeln('╚══════════════════════════════════════════');

    developer.log(
      buffer.toString(),
      name: 'API',
      level: 1200, // SEVERE
      error: err,
      stackTrace: err.stackTrace,
    );
  }

  Map<String, String> _sanitizeHeaders(Map<String, dynamic> headers) {
    const sensitiveKeys = {
      'authorization',
      'cookie',
      'set-cookie',
      'x-api-key',
    };
    return headers.map((key, value) {
      if (sensitiveKeys.contains(key.toLowerCase())) {
        return MapEntry(key, '***REDACTED***');
      }
      return MapEntry(key, value.toString());
    });
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}… [truncated ${text.length - maxLength} chars]';
  }

  String _generateRequestId() {
    _counter++;
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}'
        '.${now.millisecond.toString().padLeft(3, '0')}'
        '#$_counter';
  }
}
