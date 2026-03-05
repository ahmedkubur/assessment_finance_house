import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/local_top_up_repository.dart';
import 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit(this._repository) : super(const TransactionsState());

  final LocalTopUpRepository _repository;

  Future<void> load(int? accountId) async {
    if (accountId == null) {
      emit(
        state.copyWith(
          status: TransactionsStatus.loaded,
          items: const [],
          clearError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(status: TransactionsStatus.loading, clearError: true));

    try {
      final rows = await _repository.getAccountTransactions(accountId);
      final items = rows.map(_mapRowToRecord).toList();
      emit(
        state.copyWith(
          status: TransactionsStatus.loaded,
          items: items,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TransactionsStatus.failure,
          errorMessage: 'Could not load transactions',
        ),
      );
    }
  }

  TransactionRecord _mapRowToRecord(Map<String, dynamic> row) {
    final typeString = row['type'] as String? ?? '';
    final type = typeString == 'add_balance' ? TransactionType.addBalance : TransactionType.topUp;
    return TransactionRecord(
      id: row['id'] as int? ?? 0,
      type: type,
      amount: (row['amount'] as num?)?.toDouble() ?? 0,
      charge: (row['charge'] as num?)?.toDouble() ?? 0,
      total: (row['total'] as num?)?.toDouble() ?? 0,
      reference: row['reference'] as String? ?? '',
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
      rechargeMethod: row['recharge_method'] as String?,
      beneficiaryName: row['beneficiary_name'] as String?,
      phoneNumber: row['phone_number'] as String?,
    );
  }
}
