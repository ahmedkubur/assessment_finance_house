import '../../models/local/local_account.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  accountCreated,
  failure
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.account,
    this.errorMessage,
  });

  final AuthStatus status;
  final LocalAccount? account;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoggedIn => isAuthenticated;

  AuthState copyWith({
    AuthStatus? status,
    LocalAccount? account,
    bool clearAccount = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      account: clearAccount ? null : (account ?? this.account),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
