import '../../models/local/local_top_up_transaction.dart';
import '../../models/top_up_result.dart';
import '../../repositories/local_top_up_repository.dart';
import '../../utils/constants.dart';

class MockTopUpApi {
  MockTopUpApi(this._repository);

  final LocalTopUpRepository _repository;

  static const double serviceCharge = AppLimits.topUpCharge;
  static const List<int> options = AppLimits.topUpAmountOptions;

  Future<TopUpResult> submitTopUp({
    required int accountId,
    required int beneficiaryId,
    required String simProvider,
    required int amount,
    required bool isVerifiedUser,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    if (!options.contains(amount)) {
      return TopUpResult.failure(AppTopUpTextConstants.invalidAmount);
    }

    final account = await _repository.getAccount(accountId);
    if (account == null) {
      return TopUpResult.failure(AppTopUpTextConstants.accountNotFound);
    }

    final beneficiary = await _repository.getBeneficiaryById(beneficiaryId);
    if (beneficiary == null || beneficiary.accountId != accountId) {
      return TopUpResult.failure(AppTopUpTextConstants.beneficiaryUnavailable);
    }

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);

    final perBeneficiaryMonthlyLimit = isVerifiedUser
        ? AppLimits.verifiedBeneficiaryMonthlyLimit
        : AppLimits.unverifiedBeneficiaryMonthlyLimit;
    final accountMonthlyLimit = AppLimits.accountMonthlyLimit;

    final beneficiaryMonthlyTotal = await _repository.monthlyBeneficiaryTopUpTotal(
      accountId: accountId,
      beneficiaryId: beneficiaryId,
      from: monthStart,
      to: monthEnd,
    );

    if (beneficiaryMonthlyTotal + amount > perBeneficiaryMonthlyLimit) {
      return TopUpResult.failure(
        'Monthly beneficiary limit reached (AED ${perBeneficiaryMonthlyLimit.toStringAsFixed(0)})',
      );
    }

    final accountMonthlyTotal = await _repository.monthlyAccountTopUpTotal(
      accountId: accountId,
      from: monthStart,
      to: monthEnd,
    );

    if (accountMonthlyTotal + amount > accountMonthlyLimit) {
      return TopUpResult.failure(
        'Monthly account limit reached (AED ${AppLimits.accountMonthlyLimit.toStringAsFixed(0)})',
      );
    }

    final totalWithCharge = amount + serviceCharge;
    if (amount > account.balance || totalWithCharge > account.balance) {
      return TopUpResult.failure(
        'Insufficient balance. Required AED ${totalWithCharge.toStringAsFixed(0)} including charge',
      );
    }

    final nextBalance = await _repository.createTopUpTransaction(
      transaction: LocalTopUpTransaction(
        accountId: accountId,
        beneficiaryId: beneficiaryId,
        simProviderName: simProvider,
        amount: amount.toDouble(),
        charge: serviceCharge,
        total: totalWithCharge.toDouble(),
      ),
    );

    return TopUpResult.success(
      message:
          '${AppTopUpTextConstants.topUpSuccessPrefix} $amount ${AppTopUpTextConstants.topUpSuccessFeeSuffix}',
      remainingBalance: nextBalance,
    );
  }
}
