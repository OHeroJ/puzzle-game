// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../utils/sp_util.dart';

class HttpEngine {
  static final HttpEngine _instance = HttpEngine._internal();

  factory HttpEngine() => _instance;

  HttpEngine._internal();

  final Map<String, String> _urlTokens = <String, String>{};

  final Dio _dio = Dio();

  static HttpEngine get instance => _instance;

  Future<http.Response> get(String url) async {
    final String token = _urlTokens[url] ?? '';
    final Uri uri = Uri.parse(url);

    try {
      final http.Response response = await http.get(
        uri,
        headers: <String, String>{
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      return response;
    } on SocketException {
      return http.Response('No internet connection', 500);
    } on HttpException {
      return http.Response('HTTP error occurred', 500);
    } on FormatException {
      return http.Response('Invalid response format', 500);
    } catch (e) {
      return http.Response('Unknown error: $e', 500);
    }
  }

  Future<http.Response> post(String url, dynamic data) async {
    final String token = _urlTokens[url] ?? '';
    final Uri uri = Uri.parse(url);

    try {
      final http.Response response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: data,
      );
      return response;
    } on SocketException {
      return http.Response('No internet connection', 500);
    } on HttpException {
      return http.Response('HTTP error occurred', 500);
    } on FormatException {
      return http.Response('Invalid response format', 500);
    } catch (e) {
      return http.Response('Unknown error: $e', 500);
    }
  }

  Future<http.Response> put(String url, dynamic data) async {
    final String token = _urlTokens[url] ?? '';
    final Uri uri = Uri.parse(url);

    try {
      final http.Response response = await http.put(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: data,
      );
      return response;
    } on SocketException {
      return http.Response('No internet connection', 500);
    } on HttpException {
      return http.Response('HTTP error occurred', 500);
    } on FormatException {
      return http.Response('Invalid response format', 500);
    } catch (e) {
      return http.Response('Unknown error: $e', 500);
    }
  }

  Future<http.Response> delete(String url) async {
    final String token = _urlTokens[url] ?? '';
    final Uri uri = Uri.parse(url);

    try {
      final http.Response response = await http.delete(
        uri,
        headers: <String, String>{
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      return response;
    } on SocketException {
      return http.Response('No internet connection', 500);
    } on HttpException {
      return http.Response('HTTP error occurred', 500);
    } on FormatException {
      return http.Response('Invalid response format', 500);
    } catch (e) {
      return http.Response('Unknown error: $e', 500);
    }
  }

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

  String getFileName(String url) {
    try {
      final Uri uri = Uri.parse(url);
      final String path = uri.path;
      return p.basename(path);
    } catch (e) {
      debugPrint('Error parsing URL: $e');
      return '';
    }
  }

  void addUrlToken(String url, String token) {
    _urlTokens[url] = token;
  }

  void removeUrlToken(String url) {
    _urlTokens.remove(url);
  }

  Future<void> cancelRequest(String url) async {
    // Cancel all requests by creating a new Dio instance
    _dio.close(force: true);
  }
}