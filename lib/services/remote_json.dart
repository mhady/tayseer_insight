import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown when a remote list cannot be fetched or parsed. [message] is safe
/// to show / announce to the user.
class RemoteDataException implements Exception {
  RemoteDataException(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() => 'RemoteDataException($message, $cause)';
}

/// Downloads a JSON array from [url].
///
/// Adds what the screens were missing: a timeout, an HTTP status check and a
/// single error type, so a failure becomes an error screen with a retry
/// button instead of an endless loading screen.
///
/// [stripPrefix] removes a `name=` prefix some of the server files carry
/// (`khedma=[...]`). [client] is injectable for tests.
Future<List<Map>> fetchJsonList(
  String url, {
  String stripPrefix = '',
  Duration timeout = const Duration(seconds: 20),
  http.Client? client,
}) async {
  final c = client ?? http.Client();
  try {
    final response = await c.get(Uri.parse(url)).timeout(timeout);
    if (response.statusCode != 200) {
      throw RemoteDataException('HTTP ${response.statusCode} for $url');
    }
    var text = utf8.decode(response.bodyBytes);
    if (stripPrefix.isNotEmpty) text = text.replaceAll(stripPrefix, '');
    final decoded = jsonDecode(text);
    if (decoded is! List) {
      throw RemoteDataException('Expected a JSON list from $url');
    }
    return List<Map>.from(decoded);
  } on RemoteDataException {
    rethrow;
  } on TimeoutException catch (e) {
    throw RemoteDataException('Timed out: $url', cause: e);
  } on FormatException catch (e) {
    // Re-thrown as-is so callers can fall back to another file (khatamat).
    throw FormatException('Invalid JSON from $url: ${e.message}');
  } catch (e) {
    throw RemoteDataException('Could not load $url', cause: e);
  } finally {
    if (client == null) c.close();
  }
}
