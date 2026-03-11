import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../api/auth_api.dart';
import '../models/auth_models.dart';
import '../../../core/storage/secure_storage.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial());

  // Called once at app startup
  Future<void> init() async {
    final accessToken = await SecureStorage.getAccessToken();
    final refreshToken = await SecureStorage.getRefreshToken();

    if (accessToken == null || refreshToken == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    // Token exists - decode it to get employee info
    final employee = _decodeToken(accessToken);
    if (employee != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        employee: employee,
      );
    } else {
      // Token is invalid/ expired - clear and go to login
      await SecureStorage.clearTokens();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final response = await AuthApi.login(email: email, password: password);

      await SecureStorage.saveTokens(
        accessToken: response.data.accessToken,
        refreshToken: response.data.refreshToken,
      );

      final employee = _decodeToken(response.data.accessToken);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        employee: employee,
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] as String? ??
          'Login failed. Please try again';

      state = state.copyWith(status: AuthStatus.error, errorMessage: message);
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      await AuthApi.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
      );
      // After register, user is not logged in - pending admin approval
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] as String? ??
          'Registration failed. Please try again';
      state = state.copyWith(status: AuthStatus.error, errorMessage: message);
    }
  }

  Future<void> logout() async {
    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await AuthApi.logout(refreshToken);
      } on DioException {
        // Even if logout API fails, clear local tokens
      }
    }

    await SecureStorage.clearTokens();
    state = state.copyWith(status: AuthStatus.unauthenticated, employee: null);
  }

  // Decode JWT to extract employee info without calling the server
  Employee? _decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(decoded) as Map<String, dynamic>;

      return Employee(
        id: data['sub'] as String,
        email: data['email'] as String,
        userType: data['userType'] as String,
        roles: List<String>.from(data['roles'] as List),
        permissions: List<String>.from(data['permissions'] as List),
      );
    } catch (_) {
      return null;
    }
  }
}

// The global provider - this is what the UI will watch
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
