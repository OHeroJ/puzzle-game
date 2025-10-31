import 'package:puzzle/src/http/http_engine.dart';

import 'dio_engine.dart';

class DioClient {
  static DioClient? _instance;
  late HttpEngine _engine;

  static DioClient getInstance() {
    if (_instance == null) {
      _instance = DioClient._();
    }
    return _instance!;
  }

  DioClient._() {
    _engine = DioEngine();
  }

  Future<dynamic> get(String url, {Map<String, dynamic>? params}) async {
    try {
      final response = await _engine.get(url);
      return Future.value(response);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<dynamic> post(String url, {Map<String, dynamic>? params}) async {
    try {
      final response = await _engine.post(url, params);
      return Future.value(response);
    } catch (e) {
      return Future.error(e);
    }
  }
}
