import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import '../errors/failures.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = (extra['retry_count'] as int?) ?? 0;

    final shouldRetry = _shouldRetry(err) && retryCount < maxRetries;

    if (shouldRetry) {
      final nextRetry = retryCount + 1;
      // Exponential backoff: 1s, 2s, 4s...
      final delay = baseDelay * (1 << (nextRetry - 1));
      await Future.delayed(delay);

      final retryOptions = Options(
        method: err.requestOptions.method,
        headers: err.requestOptions.headers,
        responseType: err.requestOptions.responseType,
        contentType: err.requestOptions.contentType,
        validateStatus: err.requestOptions.validateStatus,
        receiveTimeout: err.requestOptions.receiveTimeout,
        sendTimeout: err.requestOptions.sendTimeout,
        extra: {
          ...err.requestOptions.extra,
          'retry_count': nextRetry,
        },
      );

      try {
        final response = await dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: retryOptions,
        );
        return handler.resolve(response);
      } on DioException catch (e) {
        return super.onError(e, handler);
      } catch (e) {
        return super.onError(err, handler);
      }
    }

    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response != null && err.response!.statusCode != null && err.response!.statusCode! >= 500);
  }
}

class NetworkClient {
  late final Dio dio;

  NetworkClient({Dio? customDio}) {
    dio = customDio ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 15),
            headers: {
              'User-Agent': 'QuranMemorizationEngine/1.0.0 (Flutter; Clean-Architecture)',
              'Accept': '*/*',
            },
          ),
        );

    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        maxRetries: 3,
        baseDelay: const Duration(seconds: 1),
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        requestHeader: false,
        responseHeader: false,
        error: true,
      ),
    );
  }

  /// Downloads a remote file to [destinationPath] with progress tracking and length validation
  Future<File> downloadFile({
    required String url,
    required String destinationPath,
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final file = File(destinationPath);
      // Ensure target directory exists
      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }

      final response = await dio.download(
        url,
        destinationPath,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
      );

      if (response.statusCode != 200) {
        throw NetworkFailure('Download failed with status code: ${response.statusCode}');
      }

      // Validate file exists and is not zero bytes
      if (!file.existsSync() || file.lengthSync() == 0) {
        throw const ChecksumFailure('Downloaded file is empty or corrupted');
      }

      return file;
    } on DioException catch (e) {
      throw NetworkFailure(e.message ?? 'Network failure during download', e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw NetworkFailure('Unexpected download error', e);
    }
  }
}
