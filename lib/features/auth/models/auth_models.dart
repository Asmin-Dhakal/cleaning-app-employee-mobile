class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int,
    );
  }
}

class AuthResponse {
  final String message;
  final AuthTokens data;

  const AuthResponse({required this.message, required this.data});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] as String,
      data: AuthTokens.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class Employee {
  final String id;
  final String email;
  final String userType;
  final List<String> roles;
  final List<String> permissions;

  const Employee({
    required this.id,
    required this.email,
    required this.userType,
    required this.roles,
    required this.permissions,
  });
}

class Session {
  final String id;
  final String deviceInfo;
  final String ipAddress;
  final String userAgent;
  final DateTime createdAt;

  const Session({
    required this.id,
    required this.deviceInfo,
    required this.ipAddress,
    required this.userAgent,
    required this.createdAt,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      deviceInfo: json['deviceInfo'] as String,
      ipAddress: json['ipAddress'] as String,
      userAgent: json['userAgent'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class SessionsResponse {
  final String message;
  final List<Session> data;

  const SessionsResponse({required this.message, required this.data});

  factory SessionsResponse.fromJson(Map<String, dynamic> json) {
    return SessionsResponse(
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((item) => Session.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
