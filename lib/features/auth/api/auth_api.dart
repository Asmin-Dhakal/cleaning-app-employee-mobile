import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../models/auth_models.dart';

class AuthApi {
  AuthApi._();

  static const String _base = '/auth/employee';

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.instance.post(
      '$_base/login',
      data: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<String> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await ApiClient.instance.post(
      '$_base/register',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phone': ?phone,
      },
    );

    return response.data['message'] as String;
  }

  static Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await ApiClient.instance.post(
      '$_base/refresh',
      data: {'refreshToken': refreshToken},
    );

    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<void> logout(String refreshToken) async {
    await ApiClient.instance.post(
      '$_base/logout',
      data: {'refreshToken': refreshToken},
    );
  }

  static Future<void> logoutAllDevices() async {
    await ApiClient.instance.post('$_base/logout-all');
  }

  static Future<SessionsResponse> getSessions() async {
    final response = await ApiClient.instance.get('$_base/sessions');
    return SessionsResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
