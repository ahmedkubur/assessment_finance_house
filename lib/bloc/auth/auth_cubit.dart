import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/api/mock_auth_api.dart';
import '../../repositories/local_auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository, this._mockAuthApi) : super(const AuthState());

  final LocalAuthRepository _authRepository;
  final MockAuthApi _mockAuthApi;

  Future<void> initialize() async {
    final loginInfo = await _authRepository.getLoginInfo();
    if (loginInfo == null || !loginInfo.isLoggedIn || loginInfo.accountId == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, clearError: true));
      return;
    }

    final account = await _authRepository.getAccountById(loginInfo.accountId!);
    if (account == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, clearError: true));
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        account: account,
        clearError: true,
      ),
    );
  }

  Future<void> login({required String phone, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final account = await _mockAuthApi.login(phone: phone, password: password);
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          account: account,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
          clearAccount: true,
        ),
      );
    }
  }

  Future<void> createAccount({
    required String fullName,
    required String phone,
    required String password,
    String? email,
    String? imageUrl,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _mockAuthApi.createAccount(
        fullName: fullName,
        phone: phone,
        password: password,
        email: email,
        imageUrl: imageUrl,
      );
      emit(
        state.copyWith(
          status: AuthStatus.accountCreated,
          clearAccount: true,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> logout() async {
    await _authRepository.logout(clearSavedCredentials: false);
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        clearAccount: true,
        clearError: true,
      ),
    );
  }

  Future<void> refreshAccount() async {
    final id = state.account?.id;
    if (id == null) return;

    final refreshed = await _authRepository.getAccountById(id);
    if (refreshed == null) return;

    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        account: refreshed,
        clearError: true,
      ),
    );
  }
}
