import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/src/http/http_engine.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';

class MockDio extends Mock implements Dio {}

class TestHttpEngine extends HttpEngine {
  final Dio dio;

  TestHttpEngine(this.dio);

  @override
  dynamic getEngine() => dio;

  @override
  void setProxy(String proxy) {
    // Not implemented for test
  }

  @override
  Future get(String url, {Map<String, dynamic>? params}) async {
    try {
      await checkRequest(url);
      final response = await dio.get(url, queryParameters: params);
      return response.data;
    } catch (error) {
      catchError(error);
      return null;
    }
  }

  @override
  Future post(String url, {Map<String, dynamic>? params}) async {
    try {
      await checkRequest(url);
      final response = await dio.post(url, data: params);
      return response.data;
    } catch (error) {
      catchError(error);
      return null;
    }
  }

  @override
  Future download(String url, String filePath, HttpProgressBack progressBack) async {
    // Not implemented for test
    return null;
  }
}

void main() {
  group('HttpEngine', () {
    late TestHttpEngine httpEngine;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      httpEngine = TestHttpEngine(mockDio);
    });

    test('should get engine', () {
      final engine = httpEngine.getEngine();
      expect(engine, mockDio);
    });

    test('should extract file name from path', () {
      final fileName = httpEngine.getFileName('/path/to/file.txt');
      expect(fileName, 'file.txt');
    });

    test('should add and remove URL token', () {
      final token = httpEngine.addUrlToken('test_url');
      expect(token, isA<CancelToken>());

      httpEngine.removeUrlToken('test_url');
      // Just testing that it doesn't throw an exception
      expect(true, isTrue);
    });

    test('should cancel request', () {
      httpEngine.addUrlToken('test_url');
      // Just testing that it doesn't throw an exception
      httpEngine.cancelRequest('test_url');
      expect(true, isTrue);
    });
  });
}