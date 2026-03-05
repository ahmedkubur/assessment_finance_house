enum TransactionsStatus { initial, loading, loaded, failure }

class TransactionsState {
  const TransactionsState({
    this.status = TransactionsStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final TransactionsStatus status;
  final List<TransactionRecord> items;
  final String? errorMessage;

  TransactionsState copyWith({
    TransactionsStatus? status,
    List<TransactionRecord>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

enum TransactionType { topUp, addBalance }

class TransactionRecord {
  const TransactionRecord({
    required this.id,
    required this.type,
    required this.amount,
    required this.charge,
    required this.total,
    required this.reference,
    required this.createdAt,
    this.rechargeMethod,
    this.beneficiaryName,
    this.phoneNumber,
  });

  final int id;
  final TransactionType type;
  final double amount;
  final double charge;
  final double total;
  final String reference;
  final DateTime createdAt;
  final String? rechargeMethod;
  final String? beneficiaryName;
  final String? phoneNumber;
}
