import 'package:dio/dio.dart';

class DioHttpRequestRetrier {
  final Dio dio;

  DioHttpRequestRetrier({required this.dio});

  Future<Response> requestRetry(RequestOptions requestOptions) async {
    return dio.request(requestOptions.path,
        data: requestOptions.data,
        cancelToken: requestOptions.cancelToken,
        onSendProgress: requestOptions.onSendProgress,
        queryParameters: requestOptions.queryParameters,
        onReceiveProgress: requestOptions.onReceiveProgress,
        options: Options(
            extra: requestOptions.extra,
            method: requestOptions.method,
            headers: requestOptions.headers,
            listFormat: requestOptions.listFormat,
            sendTimeout: requestOptions.sendTimeout,
            contentType: requestOptions.contentType,
            maxRedirects: requestOptions.maxRedirects,
            responseType: requestOptions.responseType,
            receiveTimeout: requestOptions.receiveTimeout,
            validateStatus: requestOptions.validateStatus,
            requestEncoder: requestOptions.requestEncoder,
            responseDecoder: requestOptions.responseDecoder,
            followRedirects: requestOptions.followRedirects,
            receiveDataWhenStatusError:
                requestOptions.receiveDataWhenStatusError));
  }

  Future<Response> retryGet(String path,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      void Function(int, int)? onReceiveProgress}) {
    return dio.get(path,
        options: options,
        cancelToken: cancelToken,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress);
  }

  Future<Response> retryPost(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParameters,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return dio.post(path,
        data: data,
        options: options,
        cancelToken: cancelToken,
        queryParameters: queryParameters,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
  }

  Future<Response> retryRequestUrl(Uri uri,
      {dynamic data,
      Options? options,
      CancelToken? cancelToken,
      void Function(int, int)? onSendProgress,
      void Function(int, int)? onReceiveProgress}) {
    return dio.requestUri(uri,
        data: data,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
  }

  Future<Response> retryGetURL(Uri uri,
      {Options? options,
      CancelToken? cancelToken,
      void Function(int, int)? onReceiveProgress}) {
    return dio.getUri(uri,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress);
  }

  Future<Response> retryPostURL(Uri uri,
      {Options? options,
      CancelToken? cancelToken,
      void Function(int, int)? onSendProgress,
      void Function(int, int)? onReceiveProgress}) {
    return dio.postUri(uri,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
  }
}
