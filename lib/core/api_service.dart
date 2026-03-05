import 'package:dio/dio.dart';

import '../models/error_object.dart';

class ApiService {
  ApiService({
    Dio? dio,
    String? baseUrl,
    Map<String, dynamic>? defaultHeaders,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? '',
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 20),
                headers: defaultHeaders ?? const {'Content-Type': 'application/json'},
              ),
            );

  final Dio _dio;

  Dio get client => _dio;

  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _parseResponse(response.data, parser);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      throw ErrorObject(errorMessage: e.toString(), errorType: ErrorType.UNKNOWN);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _parseResponse(response.data, parser);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      throw ErrorObject(errorMessage: e.toString(), errorType: ErrorType.UNKNOWN);
    }
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _parseResponse(response.data, parser);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      throw ErrorObject(errorMessage: e.toString(), errorType: ErrorType.UNKNOWN);
    }
  }

  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _parseResponse(response.data, parser);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      throw ErrorObject(errorMessage: e.toString(), errorType: ErrorType.UNKNOWN);
    }
  }

  T _parseResponse<T>(dynamic data, T Function(dynamic data)? parser) {
    if (parser != null) {
      return parser(data);
    }
    return data as T;
  }

  ErrorObject _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;
    final serverMessage = responseData is Map<String, dynamic>
        ? responseData['message']?.toString()
        : null;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return ErrorObject(
        errorMessage: serverMessage ?? 'Network error. Please try again.',
        errorType: ErrorType.NETWORK,
      );
    }

    if (statusCode != null && statusCode >= 400 && statusCode < 600) {
      return ErrorObject(
        errorMessage: serverMessage ?? 'Server error. Please try again later.',
        errorType: ErrorType.SERVER,
      );
    }

    return ErrorObject(
      errorMessage: e.message ?? 'Unexpected error.',
      errorType: ErrorType.UNKNOWN,
    );
  }
}
