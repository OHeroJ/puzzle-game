import 'dart:io';

import 'package:dio/dio.dart';
import 'package:puzzle/src/http/api.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'http_engine.dart';

class DioEngine implements HttpEngine {
  late Dio _dio;
  final Map<String, String> _urlTokens = <String, String>{};

  DioEngine() {
    var options = BaseOptions(
      connectTimeout: const Duration(seconds: 5000),
      headers: Api.header,
      contentType: Headers.jsonContentType,
    );
    _dio = Dio(options);
    // _dio.options.headers.addAll(AppConfig.headerMap);
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        requestBody: true,
        responseBody: true,
        request: false,
      ),
    ); //开启请求日志
  }

  @override
  Future<http.Response> get(String url) async {
    try {
      final response = await _dio.get(url);
      return http.Response(response.toString(), 200);
    } catch (e) {
      return http.Response('Error: $e', 500);
    }
  }

  @override
  Future<http.Response> post(String url, dynamic data) async {
    try {
      final response = await _dio.post(url, data: data);
      return http.Response(response.toString(), 200);
    } catch (e) {
      return http.Response('Error: $e', 500);
    }
  }

  @override
  Future<http.Response> put(String url, dynamic data) async {
    try {
      final response = await _dio.put(url, data: data);
      return http.Response(response.toString(), 200);
    } catch (e) {
      return http.Response('Error: $e', 500);
    }
  }

  @override
  Future<http.Response> delete(String url) async {
    try {
      final response = await _dio.delete(url);
      return http.Response(response.toString(), 200);
    } catch (e) {
      return http.Response('Error: $e', 500);
    }
  }

  @override
  void setProxy(String proxy) {
    if (proxy.isNotEmpty) {}
  }

  @override
  Future download(String url, String filePath, progressBack) async {
    try {
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (count, total) {
          progressBack(count / total);
        },
      );
      return true;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<String> uploadFile(String url, File file) async {
    try {
      final String fileName = p.basename(file.path);
      final FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final Response response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data.toString();
      } else {
        throw HttpException('Failed to upload file: ${response.statusMessage}');
      }
    } catch (e) {
      throw HttpException('Failed to upload file: $e');
    }
  }

  @override
  getEngine() {
    return _dio;
  }

  @override
  String getFileName(String url) {
    try {
      final Uri uri = Uri.parse(url);
      final String path = uri.path;
      return p.basename(path);
    } catch (e) {
      // ignore: avoid_print
      print('Error parsing URL: $e');
      return '';
    }
  }

  @override
  void addUrlToken(String url, String token) {
    _urlTokens[url] = token;
  }

  @override
  void removeUrlToken(String url) {
    _urlTokens.remove(url);
  }

  @override
  Future<void> cancelRequest(String url) async {
    // Cancel all requests by creating a new Dio instance
    _dio.close(force: true);
  }
}