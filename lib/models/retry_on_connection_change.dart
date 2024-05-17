import 'dart:io';
import 'request_retrier.dart';
import 'package:dio/dio.dart';
import '../helpers/helper.dart';

class RetryOnConnectionChangeInterceptor extends Interceptor {
  final Dio dio;

  RetryOnConnectionChangeInterceptor({required this.dio});

  bool _shouldRetryOnHttpException(DioError err) {
    return err.type == DioErrorType.other &&
        ((err.error is HttpException &&
            err.message.contains(
                'Connection closed before full header was received')));
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler,
      {String? method}) async {
    final io = DioHttpRequestRetrier(dio: dio);
    if (_shouldRetryOnHttpException(err)) {
      try {
        handler.resolve(await (method?.toLowerCase() == 'get'
                ? io.retryGetURL(err.requestOptions.uri)
                : (method?.toLowerCase() == 'post'
                    ? io.retryPostURL(err.requestOptions.uri)
                    : io.requestRetry(err.requestOptions)))
            .catchError((e) {
          sendAppLog(e);
          handler.next(err);
        }));
      } catch (e) {
        sendAppLog(e);
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}
