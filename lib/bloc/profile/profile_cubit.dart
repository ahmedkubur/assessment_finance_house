import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/local_auth_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._authRepository) : super(const ProfileState());

  final LocalAuthRepository _authRepository;

  Future<void> load(int? accountId) async {
    if (accountId == null) {
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          clearAccount: true,
          clearError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
    final account = await _authRepository.getAccountById(accountId);
    emit(state.copyWith(status: ProfileStatus.loaded, account: account));
  }

  Future<bool> changePassword({
    required int? accountId,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (accountId == null) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Login required',
        ),
      );
      return false;
    }

    if (currentPassword == newPassword) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'New password must be different',
        ),
      );
      return false;
    }

    final success = await _authRepository.changePassword(
      accountId: accountId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    if (!success) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Current password is incorrect',
        ),
      );
      return false;
    }

    await load(accountId);
    return true;
  }

  Future<bool> addBalance({required int? accountId, required double amount}) async {
    if (accountId == null) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Login required',
        ),
      );
      return false;
    }

    final success = await _authRepository.addBalance(accountId: accountId, amount: amount);
    if (!success) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Could not update balance',
        ),
      );
      return false;
    }

    await load(accountId);
    return true;
  }

  Future<bool> verifyUser({
    required int? accountId,
    required String selfieImageUrl,
  }) async {
    if (accountId == null) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Login required',
        ),
      );
      return false;
    }

    final success = await _authRepository.verifyUser(
      accountId: accountId,
      selfieImageUrl: selfieImageUrl,
    );
    if (!success) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Could not verify user',
        ),
      );
      return false;
    }

    await load(accountId);
    return true;
  }

  Future<bool> updateProfileImage({
    required int? accountId,
    required String imagePath,
  }) async {
    if (accountId == null) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Login required',
        ),
      );
      return false;
    }

    final success = await _authRepository.updateProfileImage(
      accountId: accountId,
      imagePath: imagePath,
    );
    if (!success) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Could not update profile image',
        ),
      );
      return false;
    }

    await load(accountId);
    return true;
  }
}
