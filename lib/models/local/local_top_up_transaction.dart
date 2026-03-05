class LocalTopUpTransaction {
  const LocalTopUpTransaction({
    this.id,
    required this.accountId,
    required this.beneficiaryId,
    required this.simProviderName,
    required this.amount,
    required this.charge,
    required this.total,
    this.createdAt,
  });

  final int? id;
  final int accountId;
  final int beneficiaryId;
  final String simProviderName;
  final double amount;
  final double charge;
  final double total;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'beneficiary_id': beneficiaryId,
      'sim_provider_name': simProviderName,
      'amount': amount,
      'charge': charge,
      'total': total,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory LocalTopUpTransaction.fromMap(Map<String, dynamic> map) {
    return LocalTopUpTransaction(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      beneficiaryId: map['beneficiary_id'] as int,
      simProviderName: map['sim_provider_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      charge: (map['charge'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
