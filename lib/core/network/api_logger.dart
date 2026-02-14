import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

/// HTTP client wrapper that logs all API requests, responses, and errors.
///
/// Wraps the standard [http.Client] and logs structured information
/// for every network call including method, URL, status code, timing,
/// request/response bodies, and any errors that occur.
class LoggingHttpClient extends http.BaseClient {
  final http.Client _inner;

  LoggingHttpClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stopwatch = Stopwatch()..start();
    final requestId = _generateRequestId();

    _logRequest(requestId, request);

    try {
      final response = await _inner.send(request);
      stopwatch.stop();

      // Read the response body so we can log it, then reconstruct
      final bytes = await response.stream.toBytes();
      final body = String.fromCharCodes(bytes);

      _logResponse(requestId, request, response, body, stopwatch.elapsed);

      // Return a new StreamedResponse with the already-read bytes
      return http.StreamedResponse(
        Stream.value(bytes),
        response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (error, stackTrace) {
      stopwatch.stop();
      _logError(requestId, request, error, stackTrace, stopwatch.elapsed);
      rethrow;
    }
  }

  void _logRequest(String id, http.BaseRequest request) {
    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════════')
      ..writeln('║ API REQUEST [$id]')
      ..writeln('╟──────────────────────────────────────────')
      ..writeln('║ ${request.method} ${request.url}')
      ..writeln('║ Headers: ${_sanitizeHeaders(request.headers)}');

    if (request is http.Request && request.body.isNotEmpty) {
      buffer.writeln('║ Body: ${_truncate(request.body, 500)}');
    }

    buffer.writeln('╚══════════════════════════════════════════');

    developer.log(
      buffer.toString(),
      name: 'API',
      level: 800, // INFO
    );
  }

  void _logResponse(
    String id,
    http.BaseRequest request,
    http.StreamedResponse response,
    String body,
    Duration elapsed,
  ) {
    final isError = response.statusCode >= 400;
    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════════')
      ..writeln('║ API RESPONSE [$id] ${isError ? "⚠️ ERROR" : "✓ OK"}')
      ..writeln('╟──────────────────────────────────────────')
      ..writeln('║ ${request.method} ${request.url}')
      ..writeln('║ Status: ${response.statusCode} ${response.reasonPhrase}')
      ..writeln('║ Duration: ${elapsed.inMilliseconds}ms')
      ..writeln('║ Content-Length: ${response.contentLength ?? body.length}')
      ..writeln('║ Body: ${_truncate(body, 800)}')
      ..writeln('╚══════════════════════════════════════════');

    developer.log(
      buffer.toString(),
      name: 'API',
      level: isError ? 1000 : 800, // WARNING for errors, INFO for success
    );
  }

  void _logError(
    String id,
    http.BaseRequest request,
    Object error,
    StackTrace stackTrace,
    Duration elapsed,
  ) {
    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════════')
      ..writeln('║ API ERROR [$id]')
      ..writeln('╟──────────────────────────────────────────')
      ..writeln('║ ${request.method} ${request.url}')
      ..writeln('║ Duration: ${elapsed.inMilliseconds}ms')
      ..writeln('║ Error: $error')
      ..writeln('║ Type: ${error.runtimeType}')
      ..writeln('╚══════════════════════════════════════════');

    developer.log(
      buffer.toString(),
      name: 'API',
      level: 1200, // SEVERE
      error: error,
      stackTrace: stackTrace,
    );
  }

  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    // Redact sensitive headers
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
      return MapEntry(key, value);
    });
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}… [truncated ${text.length - maxLength} chars]';
  }

  int _counter = 0;

  String _generateRequestId() {
    _counter++;
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}'
        '.${now.millisecond.toString().padLeft(3, '0')}'
        '#$_counter';
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
