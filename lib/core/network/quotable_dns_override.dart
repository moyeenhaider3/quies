import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// The Heroku CNAME target for api.quotable.io.
///
/// The DNS delegation for quotable.io is broken at the registrar level —
/// public DNS resolvers (Google 8.8.8.8, Cloudflare 1.1.1.1) return SERVFAIL,
/// but the authoritative nameserver (dnsimple) still has a CNAME record
/// pointing to this Heroku hostname, which resolves correctly on public DNS.
const _herokuCname = 'mysterious-feijoa-0raf5466fxw0fo43e63hphuv.herokudns.com';

const _quotableHost = 'api.quotable.io';

/// Dio interceptor that bypasses broken DNS for `api.quotable.io`.
///
/// `HttpClient.connectionFactory` does not properly propagate the original
/// hostname for TLS SNI, so we bypass Dart's `HttpClient` entirely for
/// this host.  Instead we:
///   1.  Resolve the Heroku CNAME via public DNS (which works).
///   2.  Open a raw TCP socket to the resolved IP.
///   3.  Upgrade to TLS with [SecureSocket.secure] using `host: api.quotable.io`
///       so the correct SNI is sent.
///   4.  Send / receive HTTP/1.1 over the secure socket.
///   5.  Parse the response and resolve the Dio handler.
///
/// Requests to any other host pass through untouched.
class QuotableDnsInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.uri.host != _quotableHost) {
      return handler.next(options);
    }

    try {
      final uri = options.uri;

      // 1. Resolve the Heroku CNAME (public DNS can do this).
      final addresses = await InternetAddress.lookup(_herokuCname);

      // 2. TCP connect to the first resolved address.
      final rawSocket = await Socket.connect(
        addresses.first,
        443,
        timeout: options.connectTimeout ?? const Duration(seconds: 10),
      );

      // 3. TLS handshake with the correct SNI.
      final secureSocket = await SecureSocket.secure(
        rawSocket,
        host: _quotableHost,
        onBadCertificate: (_) => true, // cert is expired
      );

      // 4. Send HTTP/1.1 GET request.
      final path = uri.query.isNotEmpty ? '${uri.path}?${uri.query}' : uri.path;
      final httpRequest =
          'GET $path HTTP/1.1\r\n'
          'Host: $_quotableHost\r\n'
          'Connection: close\r\n'
          'Accept: application/json\r\n'
          '\r\n';
      secureSocket.write(httpRequest);
      await secureSocket.flush();

      // 5. Read entire response (Connection: close → server closes socket).
      final bytes = <int>[];
      await for (final chunk in secureSocket) {
        bytes.addAll(chunk);
      }
      await secureSocket.close();

      // 6. Parse HTTP response.
      final rawResponse = Uint8List.fromList(bytes);
      final headerEndIndex = _findDoubleCrLf(rawResponse);
      if (headerEndIndex == -1) {
        throw Exception('Malformed HTTP response: no header/body boundary');
      }

      final headerStr = utf8.decode(rawResponse.sublist(0, headerEndIndex));
      final headerLines = headerStr.split('\r\n');

      // Status line: "HTTP/1.1 200 OK"
      final statusParts = headerLines.first.split(' ');
      final statusCode = int.parse(statusParts[1]);
      final statusMessage = statusParts.sublist(2).join(' ');

      // Response headers
      final responseHeaders = <String, List<String>>{};
      for (var i = 1; i < headerLines.length; i++) {
        final colonIdx = headerLines[i].indexOf(':');
        if (colonIdx != -1) {
          final key = headerLines[i]
              .substring(0, colonIdx)
              .trim()
              .toLowerCase();
          final value = headerLines[i].substring(colonIdx + 1).trim();
          responseHeaders.putIfAbsent(key, () => []).add(value);
        }
      }

      // Body – handle chunked transfer encoding.
      var bodyBytes = rawResponse.sublist(headerEndIndex + 4);
      final isChunked =
          responseHeaders['transfer-encoding']?.any(
            (v) => v.contains('chunked'),
          ) ??
          false;
      if (isChunked) {
        bodyBytes = _decodeChunked(bodyBytes);
      }

      // Decode body (JSON or raw string).
      final bodyStr = utf8.decode(bodyBytes);
      dynamic data;
      try {
        data = jsonDecode(bodyStr);
      } catch (_) {
        data = bodyStr;
      }

      return handler.resolve(
        Response(
          requestOptions: options,
          data: data,
          statusCode: statusCode,
          statusMessage: statusMessage,
          headers: Headers.fromMap(responseHeaders),
        ),
      );
    } catch (e) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: e,
          type: DioExceptionType.connectionError,
          message: e.toString(),
        ),
      );
    }
  }

  /// Finds the byte offset of `\r\n\r\n` in [data].
  int _findDoubleCrLf(Uint8List data) {
    for (var i = 0; i < data.length - 3; i++) {
      if (data[i] == 13 &&
          data[i + 1] == 10 &&
          data[i + 2] == 13 &&
          data[i + 3] == 10) {
        return i;
      }
    }
    return -1;
  }

  /// Decodes an HTTP chunked transfer-encoded body.
  Uint8List _decodeChunked(Uint8List data) {
    final result = <int>[];
    var offset = 0;
    while (offset < data.length) {
      final lineEnd = _findCrLf(data, offset);
      if (lineEnd == -1) break;

      final sizeStr = utf8.decode(data.sublist(offset, lineEnd)).trim();
      if (sizeStr.isEmpty) break;
      final chunkSize = int.parse(sizeStr, radix: 16);
      if (chunkSize == 0) break;

      offset = lineEnd + 2; // skip \r\n after size
      result.addAll(data.sublist(offset, offset + chunkSize));
      offset += chunkSize + 2; // skip chunk data + trailing \r\n
    }
    return Uint8List.fromList(result);
  }

  /// Finds the byte offset of `\r\n` starting from [start].
  int _findCrLf(Uint8List data, int start) {
    for (var i = start; i < data.length - 1; i++) {
      if (data[i] == 13 && data[i + 1] == 10) return i;
    }
    return -1;
  }
}
