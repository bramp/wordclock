import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// A custom [http.Client] that logs font fetch requests.
class LoggingHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (kDebugMode) {
      print('Fetching font from network: ${request.url}');
    }
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
