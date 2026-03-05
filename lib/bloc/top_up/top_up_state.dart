import '../../models/local/local_beneficiary.dart';
import '../../utils/constants.dart';

enum TopUpStatus { initial, loading, ready, submitting, success, failure }

class TopUpState {
  const TopUpState({
    this.status = TopUpStatus.initial,
    this.beneficiaries = const [],
    this.amountOptions = AppLimits.topUpAmountOptions,
    this.selectedBeneficiaryId,
    this.selectedAmount,
    this.serviceCharge = AppLimits.topUpCharge,
    this.currentBalance = 0,
    this.isVerified = false,
    this.beneficiaryMonthlyTotal = 0,
    this.beneficiaryMonthlyLimit = AppLimits.unverifiedBeneficiaryMonthlyLimit,
    this.accountMonthlyTotal = 0,
    this.accountMonthlyLimit = AppLimits.accountMonthlyLimit,
    this.remainingBalance,
    this.errorMessage,
    this.successMessage,
  });

  final TopUpStatus status;
  final List<LocalBeneficiary> beneficiaries;
  final List<int> amountOptions;
  final int? selectedBeneficiaryId;
  final int? selectedAmount;
  final double serviceCharge;
  final double currentBalance;
  final bool isVerified;
  final double beneficiaryMonthlyTotal;
  final double beneficiaryMonthlyLimit;
  final double accountMonthlyTotal;
  final double accountMonthlyLimit;
  final double? remainingBalance;
  final String? errorMessage;
  final String? successMessage;

  double get totalCost {
    if (selectedAmount == null) return 0;
    return selectedAmount!.toDouble() + serviceCharge;
  }

  TopUpState copyWith({
    TopUpStatus? status,
    List<LocalBeneficiary>? beneficiaries,
    List<int>? amountOptions,
    int? selectedBeneficiaryId,
    bool clearSelectedBeneficiary = false,
    int? selectedAmount,
    bool clearSelectedAmount = false,
    double? serviceCharge,
    double? currentBalance,
    bool? isVerified,
    double? beneficiaryMonthlyTotal,
    double? beneficiaryMonthlyLimit,
    double? accountMonthlyTotal,
    double? accountMonthlyLimit,
    double? remainingBalance,
    bool clearRemainingBalance = false,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return TopUpState(
      status: status ?? this.status,
      beneficiaries: beneficiaries ?? this.beneficiaries,
      amountOptions: amountOptions ?? this.amountOptions,
      selectedBeneficiaryId: clearSelectedBeneficiary
          ? null
          : (selectedBeneficiaryId ?? this.selectedBeneficiaryId),
      selectedAmount: clearSelectedAmount ? null : (selectedAmount ?? this.selectedAmount),
      serviceCharge: serviceCharge ?? this.serviceCharge,
      currentBalance: currentBalance ?? this.currentBalance,
      isVerified: isVerified ?? this.isVerified,
      beneficiaryMonthlyTotal: beneficiaryMonthlyTotal ?? this.beneficiaryMonthlyTotal,
      beneficiaryMonthlyLimit: beneficiaryMonthlyLimit ?? this.beneficiaryMonthlyLimit,
      accountMonthlyTotal: accountMonthlyTotal ?? this.accountMonthlyTotal,
      accountMonthlyLimit: accountMonthlyLimit ?? this.accountMonthlyLimit,
      remainingBalance:
          clearRemainingBalance ? null : (remainingBalance ?? this.remainingBalance),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
