import 'package:dio/dio.dart';

/// Lightweight image lookup that scrapes DuckDuckGo image API (no key needed).
class ImageLookupService {
  ImageLookupService(this._dio);

  final Dio _dio;

  static const Map<String, String> _headers = <String, String>{
    'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
  };

  /// Returns the first image url for the given query.
  Future<String?> search(String query) async {
    final String sanitized = query.trim();
    if (sanitized.isEmpty) {
      return null;
    }
    try {
      final Response<String> tokenRes = await _dio.get<String>(
        'https://duckduckgo.com/',
        queryParameters: <String, String>{'q': sanitized},
        options: Options(responseType: ResponseType.plain, headers: _headers),
      );
      final String? token = _extractToken(tokenRes.data ?? '');
      if (token == null) {
        return null;
      }

      final Response<dynamic> res = await _dio.get<dynamic>(
        'https://duckduckgo.com/i.js',
        queryParameters: <String, String>{
          'l': 'tr-tr',
          'o': 'json',
          'q': sanitized,
          'vqd': token,
        },
        options: Options(headers: _headers),
      );
      final List<dynamic>? results = res.data?['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) {
        return null;
      }
      final Map<String, dynamic> first = results.first as Map<String, dynamic>;
      return first['image'] as String?;
    } catch (_) {
      return null;
    }
  }

  String? _extractToken(String body) {
    final RegExpMatch? match = RegExp(r"vqd='([^']+)'").firstMatch(body);
    return match?.group(1);
  }
}
