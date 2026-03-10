import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  ApiClient._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Dio get instance => _dio;

  static void init() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach access token to every request
          final token = await SecureStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer$token';
          }

          // Attach device info header
          options.headers[AppConstants.deviceInfoHeader] =
              'CleanFlow/${const String.fromEnvironment('PLATFORM', defaultValue: 'Mobile')}';
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 - clear tokens and let the app redirect to login
          if (error.response?.statusCode == 401) {
            await SecureStorage.clearTokens();
          }
          return handler.next(error);
        },
      ),
    );
  }
}
