import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/api/mock_top_up_api.dart';
import '../../repositories/local_top_up_repository.dart';
import '../../utils/app_validators.dart';
import '../../utils/constants.dart';
import 'top_up_state.dart';

class TopUpCubit extends Cubit<TopUpState> {
  TopUpCubit({
    required LocalTopUpRepository topUpRepository,
    required MockTopUpApi mockTopUpApi,
  })  : _topUpRepository = topUpRepository,
        _mockTopUpApi = mockTopUpApi,
        super(const TopUpState());

  final LocalTopUpRepository _topUpRepository;
  final MockTopUpApi _mockTopUpApi;

  Future<void> load({
    required int? accountId,
    required bool isVerifiedUser,
    required String providerName,
  }) async {
    if (accountId == null) {
      emit(
        state.copyWith(
          status: TopUpStatus.failure,
          errorMessage: 'Login required',
          beneficiaries: const [],
        ),
      );
      return;
    }

    emit(state.copyWith(status: TopUpStatus.loading, clearError: true, clearSuccess: true));

    final beneficiaries = await _topUpRepository.getActiveBeneficiaries(accountId);
    final providerBeneficiaries =
        beneficiaries.where((b) => _isSameProvider(b.providerName, providerName)).toList();
    final account = await _topUpRepository.getAccount(accountId);
    final selectedBeneficiaryId =
        providerBeneficiaries.isNotEmpty ? providerBeneficiaries.first.id : null;
    final usage = await _loadUsage(
      accountId: accountId,
      beneficiaryId: selectedBeneficiaryId,
      isVerified: isVerifiedUser,
    );

    emit(
      state.copyWith(
        status: TopUpStatus.ready,
        beneficiaries: providerBeneficiaries,
        selectedBeneficiaryId: selectedBeneficiaryId,
        currentBalance: account?.balance ?? 0,
        isVerified: isVerifiedUser,
        beneficiaryMonthlyTotal: usage.beneficiaryMonthlyTotal,
        beneficiaryMonthlyLimit: usage.beneficiaryMonthlyLimit,
        accountMonthlyTotal: usage.accountMonthlyTotal,
        accountMonthlyLimit: usage.accountMonthlyLimit,
        clearError: true,
      ),
    );
  }

  bool _isSameProvider(String beneficiaryProviderName, String selectedProviderName) {
    return beneficiaryProviderName.trim().toLowerCase() ==
        selectedProviderName.trim().toLowerCase();
  }

  Future<void> selectBeneficiary(int beneficiaryId, {required int? accountId}) async {
    if (accountId == null) return;
    final usage = await _loadUsage(
      accountId: accountId,
      beneficiaryId: beneficiaryId,
      isVerified: state.isVerified,
    );

    emit(
      state.copyWith(
        selectedBeneficiaryId: beneficiaryId,
        beneficiaryMonthlyTotal: usage.beneficiaryMonthlyTotal,
        beneficiaryMonthlyLimit: usage.beneficiaryMonthlyLimit,
        accountMonthlyTotal: usage.accountMonthlyTotal,
        accountMonthlyLimit: usage.accountMonthlyLimit,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  void selectAmount(int amount) {
    emit(
      state.copyWith(
        selectedAmount: amount,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  Future<void> submit({
    required int? accountId,
    required String simProvider,
    required bool isVerifiedUser,
  }) async {
    if (accountId == null) {
      emit(
        state.copyWith(
          status: TopUpStatus.failure,
          errorMessage: 'Login required',
        ),
      );
      return;
    }

    if (state.selectedBeneficiaryId == null) {
      emit(
        state.copyWith(
          status: TopUpStatus.failure,
          errorMessage: 'Select a beneficiary first',
        ),
      );
      return;
    }

    if (state.selectedAmount == null) {
      emit(
        state.copyWith(
          status: TopUpStatus.failure,
          errorMessage: 'Select a top-up amount',
        ),
      );
      return;
    }

    final selectedAmount = state.selectedAmount!.toDouble();
    final monthlyTotalAfterTopUp = state.accountMonthlyTotal + selectedAmount;
    if (monthlyTotalAfterTopUp > state.accountMonthlyLimit) {
      emit(
        state.copyWith(
          status: TopUpStatus.failure,
          errorMessage:
              'Monthly account limit reached (AED ${state.accountMonthlyLimit.toStringAsFixed(0)})',
        ),
      );
      return;
    }

    emit(state.copyWith(status: TopUpStatus.submitting, clearError: true, clearSuccess: true));

    final result = await _mockTopUpApi.submitTopUp(
      accountId: accountId,
      beneficiaryId: state.selectedBeneficiaryId!,
      simProvider: simProvider,
      amount: state.selectedAmount!,
      isVerifiedUser: isVerifiedUser,
    );

    if (!result.isSuccess) {
      emit(
        state.copyWith(
          status: TopUpStatus.failure,
          errorMessage: result.message,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: TopUpStatus.success,
        successMessage: result.message,
        remainingBalance: result.remainingBalance,
      ),
    );

    await load(
      accountId: accountId,
      isVerifiedUser: isVerifiedUser,
      providerName: simProvider,
    );
    emit(
      state.copyWith(
        status: TopUpStatus.ready,
        clearSelectedAmount: true,
      ),
    );
  }

  Future<void> selectDirectRechargePhone({
    required int? accountId,
    required String phoneNumber,
    required String providerName,
    required String providerLogoUrl,
  }) async {
    if (accountId == null) return;

    final normalizedPhone = AppValidators.toUaePhoneE164(phoneNumber);
    if (normalizedPhone.isEmpty) return;

    final beneficiaryId = await _topUpRepository.getOrCreateDirectRechargeBeneficiary(
      accountId: accountId,
      phoneNumber: normalizedPhone,
      providerName: providerName,
      providerLogoUrl: providerLogoUrl,
    );

    await selectBeneficiary(beneficiaryId, accountId: accountId);
  }

  Future<_MonthlyUsage> _loadUsage({
    required int accountId,
    required int? beneficiaryId,
    required bool isVerified,
  }) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);

    final accountMonthlyTotal = await _topUpRepository.monthlyAccountTopUpTotal(
      accountId: accountId,
      from: monthStart,
      to: monthEnd,
    );

    var beneficiaryMonthlyTotal = 0.0;
    if (beneficiaryId != null) {
      beneficiaryMonthlyTotal = await _topUpRepository.monthlyBeneficiaryTopUpTotal(
        accountId: accountId,
        beneficiaryId: beneficiaryId,
        from: monthStart,
        to: monthEnd,
      );
    }

    return _MonthlyUsage(
      beneficiaryMonthlyTotal: beneficiaryMonthlyTotal,
      beneficiaryMonthlyLimit: isVerified
          ? AppLimits.verifiedBeneficiaryMonthlyLimit
          : AppLimits.unverifiedBeneficiaryMonthlyLimit,
      accountMonthlyTotal: accountMonthlyTotal,
      accountMonthlyLimit: AppLimits.accountMonthlyLimit,
    );
  }
}

class _MonthlyUsage {
  const _MonthlyUsage({
    required this.beneficiaryMonthlyTotal,
    required this.beneficiaryMonthlyLimit,
    required this.accountMonthlyTotal,
    required this.accountMonthlyLimit,
  });

  final double beneficiaryMonthlyTotal;
  final double beneficiaryMonthlyLimit;
  final double accountMonthlyTotal;
  final double accountMonthlyLimit;
}
