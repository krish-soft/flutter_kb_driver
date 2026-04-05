import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:kb_driver/constants/app_constants.dart';
import 'package:kb_driver/core/lang/translations.dart';
import 'package:kb_driver/core/services/api_exception.dart';
import 'package:kb_driver/utils/message_manager.dart';
import 'package:kb_driver/utils/preference_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum ApiMethod { get, post, put, delete }

enum BodyType { json, formUrlEncoded, multipart }

class APIClient {
  static final APIClient _instance = APIClient._internal();
  factory APIClient() => _instance;

  late final Dio _dio;

  /// ===== TOKEN CACHE (avoid async storage read every call) =====
  String? _cachedToken;

  APIClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.BASE_URL, // 🔥 IMPORTANT
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
      ),
    );

    /// ===== INTERCEPTORS =====
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requireAuth = options.extra['auth'] == true;

          /// build headers once
          final headers = await _buildHeaders(requireAuth: requireAuth);
          options.headers.addAll(headers);

          handler.next(options);
        },
        onError: (e, handler) async {
          /// central unauthorized handler
          if (e.response?.statusCode == 401) {
            await _handleSessionExpired();
          }
          handler.next(e);
        },
      ),
    );

    /// DEBUG LOGGING ONLY
    // if (kDebugMode) {
    //   _dio.interceptors.add(
    //     LogInterceptor(requestBody: true, responseBody: true),
    //   );
    // }
  }

  // ===============================================================
  // ======================== MAIN REQUEST =========================
  // ===============================================================

  Future<dynamic> request({
    required String url,
    required ApiMethod method,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? body,
    BodyType bodyType = BodyType.json,
    Map<String, File>? files,
    bool requireAuth = false,
  }) async {
    try {
      final options = Options(
        method: method.name.toUpperCase(),
        extra: {'auth': requireAuth},
        contentType: _resolveContentType(bodyType),
      );

      final data = method == ApiMethod.get
          ? null
          : await _prepareRequestBody(
              body: body,
              bodyType: bodyType,
              files: files,
            );

      final response = await _dio.request(
        url,
        options: options,
        queryParameters: queryParams,
        data: data,
      );

      final res = response.data;

      /// ===== YOUR CUSTOM BACKEND RESPONSE CHECK =====
      if (res is Map && res['isSuccess'] == false) {
        final msg = res['message']?.toString() ?? '';

        if (msg.contains('Unauthenticated')) {
          await _handleSessionExpired();
        }
      }

      return res;
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (_) {
      throw FetchDataException('Unexpected error occurred');
    }
  }

  // ===============================================================
  // =========================== HEADERS ===========================
  // ===============================================================

  Future<Map<String, String>> _buildHeaders({required bool requireAuth}) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final headers = <String, String>{
      'Accept-Language': AppWebTranslations.apiLanguage, // e.g. 'en', 'hi', 'gu'
      'X-API-KEY': AppConstants.API_KEY,
      'X-App-Version': packageInfo.version,
      'X-Platform': kIsWeb
          ? 'web'
          : Platform.isAndroid
          ? 'android'
          : Platform.isIOS
          ? 'ios'
          : 'unknown',
    };

    if (requireAuth) {
      _cachedToken ??= await PreferenceManager.getAccessToken();

      if (_cachedToken != null && _cachedToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $_cachedToken';
      }
    }

    return headers;
  }

  /// 🔥 Call this after login success
  void updateToken(String token) {
    _cachedToken = token;
  }

  /// 🔥 Call this after logout
  void clearToken() {
    _cachedToken = null;
  }

  // ===============================================================
  // ============================ BODY =============================
  // ===============================================================

  String _resolveContentType(BodyType type) {
    switch (type) {
      case BodyType.formUrlEncoded:
        return Headers.formUrlEncodedContentType;
      case BodyType.multipart:
        return Headers.multipartFormDataContentType;
      case BodyType.json:
        return Headers.jsonContentType;
    }
  }

  Future<dynamic> _prepareRequestBody({
    Map<String, dynamic>? body,
    required BodyType bodyType,
    Map<String, File>? files,
  }) async {
    switch (bodyType) {
      case BodyType.json:
        return body;

      case BodyType.formUrlEncoded:
        return body;

      case BodyType.multipart:
        return await _buildMultipart(body ?? {}, files ?? {});
    }
  }

  Future<FormData> _buildMultipart(
    Map<String, dynamic> fields,
    Map<String, File> files,
  ) async {
    final formData = FormData();

    /// fields
    fields.forEach((key, value) {
      formData.fields.add(MapEntry(key, value.toString()));
    });

    /// files (ASYNC — no UI freeze)
    for (final entry in files.entries) {
      formData.files.add(
        MapEntry(
          entry.key,
          await MultipartFile.fromFile(
            entry.value.path,
            filename: entry.value.path.split('/').last,
          ),
        ),
      );
    }

    return formData;
  }

  // ===============================================================
  // =========================== SESSION ===========================
  // ===============================================================

  Future<void> _handleSessionExpired() async {
    _cachedToken = null;
    await PreferenceManager.clearAllPreferences();
    MessageManager.showWarning('Session expired. Please login again.');
    Get.offAllNamed('/signin');
  }

  // ===============================================================
  // ============================ ERROR ============================
  // ===============================================================

  FetchDataException _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return FetchDataException('No internet connection');
    }

    if (e.response != null) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        return FetchDataException(data['message']);
      }

      return FetchDataException(
        'Server error (${e.response?.statusCode ?? ''})',
      );
    }

    return FetchDataException('Network error occurred');
  }
}
