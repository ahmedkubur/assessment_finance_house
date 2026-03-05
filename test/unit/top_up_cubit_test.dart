import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recharge/bloc/top_up/top_up_cubit.dart';
import 'package:recharge/bloc/top_up/top_up_state.dart';
import 'package:recharge/core/api/mock_top_up_api.dart';
import 'package:recharge/models/local/local_account.dart';
import 'package:recharge/models/local/local_beneficiary.dart';
import 'package:recharge/models/top_up_result.dart';
import 'package:recharge/repositories/local_top_up_repository.dart';

class MockLocalTopUpRepository extends Mock implements LocalTopUpRepository {}

class MockMockTopUpApi extends Mock implements MockTopUpApi {}

void main() {
  late MockLocalTopUpRepository repository;
  late MockMockTopUpApi topUpApi;
  late TopUpCubit cubit;
  late StreamSubscription<TopUpState> subscription;
  late List<TopUpState> emittedStates;

  setUpAll(() {
    registerFallbackValue(DateTime(2026, 1, 1));
  });

  setUp(() {
    repository = MockLocalTopUpRepository();
    topUpApi = MockMockTopUpApi();
    cubit = TopUpCubit(topUpRepository: repository, mockTopUpApi: topUpApi);
    emittedStates = <TopUpState>[];
    subscription = cubit.stream.listen(emittedStates.add);
  });

  tearDown(() async {
    await subscription.cancel();
    await cubit.close();
  });

  test('load with null account emits login required failure', () async {
    await cubit.load(
      accountId: null,
      isVerifiedUser: false,
      providerName: 'Etisalat',
    );

    expect(cubit.state.status, TopUpStatus.failure);
    expect(cubit.state.errorMessage, 'Login required');
    expect(cubit.state.beneficiaries, isEmpty);
  });

  test('submit fails when no beneficiary is selected', () async {
    await cubit.submit(
      accountId: 1,
      simProvider: 'Etisalat',
      isVerifiedUser: true,
    );

    expect(cubit.state.status, TopUpStatus.failure);
    expect(cubit.state.errorMessage, 'Select a beneficiary first');
    verifyNever(
      () => topUpApi.submitTopUp(
        accountId: any(named: 'accountId'),
        beneficiaryId: any(named: 'beneficiaryId'),
        simProvider: any(named: 'simProvider'),
        amount: any(named: 'amount'),
        isVerifiedUser: any(named: 'isVerifiedUser'),
      ),
    );
  });

  test('submit success returns to ready and clears selected amount', () async {
    const beneficiary = LocalBeneficiary(
      id: 5,
      accountId: 1,
      nickname: 'Home',
      phoneNumber: '+971501234567',
      providerName: 'Etisalat',
      providerLogoUrl: 'logo.png',
    );

    const account = LocalAccount(
      id: 1,
      fullName: 'Test',
      phone: '+971501111111',
      password: 'abc123',
      balance: 400,
      isVerified: true,
    );

    when(
      () => repository.getActiveBeneficiaries(1),
    ).thenAnswer((_) async => const [beneficiary]);
    when(() => repository.getAccount(1)).thenAnswer((_) async => account);
    when(
      () => repository.monthlyAccountTopUpTotal(
        accountId: 1,
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => 0);
    when(
      () => repository.monthlyBeneficiaryTopUpTotal(
        accountId: 1,
        beneficiaryId: 5,
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => 0);

    when(
      () => topUpApi.submitTopUp(
        accountId: 1,
        beneficiaryId: 5,
        simProvider: 'Etisalat',
        amount: 10,
        isVerifiedUser: true,
      ),
    ).thenAnswer(
      (_) async => TopUpResult.success(
        message: 'Top up successful',
        remainingBalance: 389,
      ),
    );

    await cubit.load(
      accountId: 1,
      isVerifiedUser: true,
      providerName: 'Etisalat',
    );
    cubit.selectAmount(10);
    await cubit.submit(
      accountId: 1,
      simProvider: 'Etisalat',
      isVerifiedUser: true,
    );

    expect(cubit.state.status, TopUpStatus.ready);
    expect(cubit.state.selectedAmount, isNull);

    verify(
      () => topUpApi.submitTopUp(
        accountId: 1,
        beneficiaryId: 5,
        simProvider: 'Etisalat',
        amount: 10,
        isVerifiedUser: true,
      ),
    ).called(1);
  });
}
