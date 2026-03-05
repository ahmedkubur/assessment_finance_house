import '../../models/local/local_beneficiary.dart';

enum BeneficiariesStatus { initial, loading, loaded, failure }

class BeneficiariesState {
  const BeneficiariesState({
    this.status = BeneficiariesStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final BeneficiariesStatus status;
  final List<LocalBeneficiary> items;
  final String? errorMessage;

  BeneficiariesState copyWith({
    BeneficiariesStatus? status,
    List<LocalBeneficiary>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BeneficiariesState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
