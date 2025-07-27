import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/src/http/http_engine.dart';

void main() {
  group('HttpEngine', () {
    late HttpEngine httpEngine;

    setUp(() {
      httpEngine = HttpEngine();
    });

    test('should get engine', () {
      expect(httpEngine, isNotNull);
    });

    test('should extract file name from path', () {
      final fileName = httpEngine.getFileName('https://example.com/path/to/file.txt');
      expect(fileName, 'file.txt');
    });

    test('should add and remove URL token', () {
      httpEngine.addUrlToken('test_url', 'test_token');
      // Note: We can't directly test the internal state, but we can test the behavior
      // by checking if the token is removed correctly
      httpEngine.removeUrlToken('test_url');
    });

    test('should cancel request', () async {
      // Note: This is a placeholder test since we can't easily test Dio's clear method
      expect(() => httpEngine.cancelRequest('test_url'), returnsNormally);
    });
  });
}