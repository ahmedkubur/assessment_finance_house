import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/local/local_beneficiary.dart';
import '../../repositories/local_beneficiaries_repository.dart';
import '../../utils/app_validators.dart';
import '../../utils/constants.dart';
import 'beneficiaries_state.dart';

class BeneficiariesCubit extends Cubit<BeneficiariesState> {
  BeneficiariesCubit(this._repository) : super(const BeneficiariesState());

  final LocalBeneficiariesRepository _repository;

  Future<void> load(int? accountId) async {
    if (accountId == null) {
      emit(
        state.copyWith(
          status: BeneficiariesStatus.loaded,
          items: const [],
          clearError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(status: BeneficiariesStatus.loading, clearError: true));
    final items = await _repository.getBeneficiariesByAccountId(accountId);
    emit(state.copyWith(status: BeneficiariesStatus.loaded, items: items));
  }

  Future<void> add({
    required int? accountId,
    required String nickname,
    required String phoneNumber,
    required String providerName,
    required String providerLogoUrl,
  }) async {
    if (accountId == null) {
      emit(
        state.copyWith(
          status: BeneficiariesStatus.failure,
          errorMessage: 'Login required',
        ),
      );
      emit(state.copyWith(status: BeneficiariesStatus.loaded));
      return;
    }

    if (nickname.trim().length < 4) {
      emit(
        state.copyWith(
          status: BeneficiariesStatus.failure,
          errorMessage: 'Nickname must be at least 4 characters',
        ),
      );
      emit(state.copyWith(status: BeneficiariesStatus.loaded));
      return;
    }

    if (nickname.trim().length > AppLimits.maxBeneficiaryNicknameLength) {
      emit(
        state.copyWith(
          status: BeneficiariesStatus.failure,
          errorMessage: 'Nickname must be 20 characters or less',
        ),
      );
      emit(state.copyWith(status: BeneficiariesStatus.loaded));
      return;
    }

    final activeCount = await _repository.countActiveBeneficiaries(accountId);
    if (activeCount >= AppLimits.maxActiveBeneficiaries) {
      emit(
        state.copyWith(
          status: BeneficiariesStatus.failure,
          errorMessage: 'Maximum 5 active beneficiaries allowed',
        ),
      );
      emit(state.copyWith(status: BeneficiariesStatus.loaded));
      return;
    }

    final normalizedPhone = AppValidators.toUaePhoneE164(phoneNumber.trim());

    await _repository.addBeneficiary(
      LocalBeneficiary(
        accountId: accountId,
        nickname: nickname,
        phoneNumber: normalizedPhone,
        providerName: providerName,
        providerLogoUrl: providerLogoUrl,
      ),
    );

    await load(accountId);
  }

  Future<void> remove({required int? accountId, required int beneficiaryId}) async {
    if (accountId == null) return;
    await _repository.deleteBeneficiary(beneficiaryId);
    await load(accountId);
  }
}
