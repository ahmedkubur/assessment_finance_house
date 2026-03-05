import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recharge/bloc/transactions/transactions_cubit.dart';
import 'package:recharge/bloc/transactions/transactions_state.dart';
import 'package:recharge/repositories/local_top_up_repository.dart';

class MockLocalTopUpRepository extends Mock implements LocalTopUpRepository {}

void main() {
  late MockLocalTopUpRepository repository;
  late TransactionsCubit cubit;
  late StreamSubscription<TransactionsState> subscription;
  late List<TransactionsState> emittedStates;

  setUp(() {
    repository = MockLocalTopUpRepository();
    cubit = TransactionsCubit(repository);
    emittedStates = <TransactionsState>[];
    subscription = cubit.stream.listen(emittedStates.add);
  });

  tearDown(() async {
    await subscription.cancel();
    await cubit.close();
  });

  test('load with null account emits loaded with empty list', () async {
    await cubit.load(null);

    expect(cubit.state.status, TransactionsStatus.loaded);
    expect(cubit.state.items, isEmpty);
    verifyNever(() => repository.getAccountTransactions(any()));
  });

  test('load maps repository rows into transaction records', () async {
    when(() => repository.getAccountTransactions(1)).thenAnswer(
      (_) async => <Map<String, dynamic>>[
        {
          'id': 11,
          'type': 'add_balance',
          'amount': 100.0,
          'charge': 0.0,
          'total': 100.0,
          'reference': 'Wallet Balance',
          'created_at': '2026-03-01T10:00:00.000',
          'recharge_method': '',
          'beneficiary_name': '',
          'phone_number': '',
        },
        {
          'id': 10,
          'type': 'top_up',
          'amount': 50.0,
          'charge': 1.0,
          'total': 51.0,
          'reference': 'Etisalat',
          'created_at': '2026-03-01T09:00:00.000',
          'recharge_method': 'beneficiary',
          'beneficiary_name': 'Home',
          'phone_number': '+971501234567',
        },
      ],
    );

    await cubit.load(1);

    expect(cubit.state.status, TransactionsStatus.loaded);
    expect(cubit.state.items.length, 2);
    expect(cubit.state.items.first.type, TransactionType.addBalance);
    expect(cubit.state.items.last.type, TransactionType.topUp);
  });

  test('load emits failure when repository throws', () async {
    when(() => repository.getAccountTransactions(1)).thenThrow(Exception('db error'));

    await cubit.load(1);

    expect(cubit.state.status, TransactionsStatus.failure);
    expect(cubit.state.errorMessage, 'Could not load transactions');
  });
}
