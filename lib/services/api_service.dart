import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const storage = FlutterSecureStorage();

final dio =
    Dio(
        BaseOptions(
          baseUrl:
              (dotenv.env['API_URL'] != null &&
                  dotenv.env['API_URL']!.trim().isNotEmpty)
              ? dotenv.env['API_URL']!.trim()
              : 'https://cultura-api-mobile.onrender.com',
          headers: {'Content-Type': 'application/json'},
        ),
      )
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await storage.read(key: 'auth_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
              debugPrint('🔐 Token found: ${token.substring(0, 20)}...');
            } else {
              debugPrint('🔓 No token found');
            }
            debugPrint('📤 Request: ${options.method} ${options.path}');
            return handler.next(options);
          },
          onError: (DioException e, handler) {
            debugPrint('❌ DIO Error: ${e.message}');
            debugPrint('❌ Status Code: ${e.response?.statusCode}');
            debugPrint('❌ Response: ${e.response?.data}');
            return handler.next(e);
          },
        ),
      );

// ==================== ApiResponse ====================

class ApiResponse {
  final bool success;
  final dynamic data;
  final String? message;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
  });

  factory ApiResponse.fromResponse(Response response) {
    final responseData = response.data;
    return ApiResponse(
      success: true,
      data: responseData,
      message: responseData is Map ? responseData['message'] : null,
      statusCode: response.statusCode ?? 200,
    );
  }

  factory ApiResponse.fromError(DioException e) {
    final data = e.response?.data;
    return ApiResponse(
      success: false,
      data: data,
      message: (data is Map)
          ? data['message'] ?? 'เกิดข้อผิดพลาด (${e.response?.statusCode})'
          : 'เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์',
      statusCode: e.response?.statusCode ?? 0,
    );
  }
}

// ==================== Auth ====================

Future<ApiResponse> login(String username, String password) async {
  try {
    final response = await dio.post(
      '/login',
      data: {'username': username, 'password': password},
    );
    return ApiResponse.fromResponse(response);
  } on DioException catch (e) {
    return ApiResponse.fromError(e);
  }
}

Future<ApiResponse> getMe() async {
  try {
    final response = await dio.get('/me');
    return ApiResponse.fromResponse(response);
  } on DioException catch (e) {
    return ApiResponse.fromError(e);
  }
}

Future<ApiResponse> getHome() async {
  try {
    final response = await dio.get('/home');
    return ApiResponse.fromResponse(response);
  } on DioException catch (e) {
    return ApiResponse.fromError(e);
  }
}

// ==================== Packages ====================

Future<ApiResponse> getPackageById(int packageId) async {
  try {
    debugPrint('📡 Requesting package detail for ID: $packageId');
    final response = await dio.get('/package/$packageId');
    debugPrint('✅ Response Status: ${response.statusCode}');
    debugPrint('📦 Response Data: ${response.data}');
    return ApiResponse.fromResponse(response);
  } on DioException catch (e) {
    debugPrint('❌ DioException in getPackageById: ${e.message}');
    debugPrint('❌ Status Code: ${e.response?.statusCode}');
    debugPrint('❌ Response: ${e.response?.data}');
    return ApiResponse.fromError(e);
  }
}

Future<ApiResponse> getPackages({String? filter}) async {
  try {
    final response = await dio.get(
      '/packages',
      queryParameters: filter != null ? {'filter': filter} : null,
    );
    return ApiResponse.fromResponse(response);
  } on DioException catch (e) {
    return ApiResponse.fromError(e);
  }
}

Future<ApiResponse> searchPackages(String keyword) async {
  try {
    final response = await dio.get(
      '/search',
      queryParameters: {'keyword': keyword},
    );
    return ApiResponse.fromResponse(response);
  } on DioException catch (e) {
    return ApiResponse.fromError(e);
  }
}

Future<ApiResponse> getBookingHistory() async {
  try {
    final response = await dio.get('/booking-history/own');
    return ApiResponse.fromResponse(response);
  } on DioException catch (e) {
    return ApiResponse.fromError(e);
  }
}
