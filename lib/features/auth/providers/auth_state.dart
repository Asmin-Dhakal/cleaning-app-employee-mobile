import '../models/auth_models.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final Employee? employee;
  final String? errorMessage;

  const AuthState({required this.status, this.employee, this.errorMessage});

  // Start state - app just opened, don't know if logged in yet
  const AuthState.initial()
    : status = AuthStatus.initial,
      employee = null,
      errorMessage = null;

  // Create a modified copy of the current state
  AuthState copyWith({
    AuthStatus? status,
    Employee? employee,
    bool clearEmployee = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      employee: clearEmployee ? null : (employee ?? this.employee),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}
