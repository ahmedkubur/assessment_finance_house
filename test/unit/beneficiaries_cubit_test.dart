import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recharge/bloc/beneficiaries/beneficiaries_cubit.dart';
import 'package:recharge/bloc/beneficiaries/beneficiaries_state.dart';
import 'package:recharge/models/local/local_beneficiary.dart';
import 'package:recharge/repositories/local_beneficiaries_repository.dart';

class MockLocalBeneficiariesRepository extends Mock
    implements LocalBeneficiariesRepository {}

void main() {
  late MockLocalBeneficiariesRepository repository;
  late BeneficiariesCubit cubit;
  late StreamSubscription<BeneficiariesState> subscription;
  late List<BeneficiariesState> emittedStates;

  setUpAll(() {
    registerFallbackValue(
      const LocalBeneficiary(
        accountId: 1,
        nickname: 'Fallback',
        phoneNumber: '+971500000000',
        providerName: 'Etisalat',
        providerLogoUrl: 'logo.png',
      ),
    );
  });

  setUp(() {
    repository = MockLocalBeneficiariesRepository();
    cubit = BeneficiariesCubit(repository);
    emittedStates = <BeneficiariesState>[];
    subscription = cubit.stream.listen(emittedStates.add);
  });

  tearDown(() async {
    await subscription.cancel();
    await cubit.close();
  });

  test('load with null account emits loaded empty state', () async {
    await cubit.load(null);

    expect(emittedStates.length, 1);
    expect(emittedStates.first.status, BeneficiariesStatus.loaded);
    expect(emittedStates.first.items, isEmpty);
    verifyNever(() => repository.getBeneficiariesByAccountId(any()));
  });

  test('add success normalizes phone and reloads items', () async {
    const storedItem = LocalBeneficiary(
      id: 10,
      accountId: 1,
      nickname: 'Home',
      phoneNumber: '+971501234567',
      providerName: 'Etisalat',
      providerLogoUrl: 'logo.png',
    );

    when(
      () => repository.countActiveBeneficiaries(1),
    ).thenAnswer((_) async => 0);
    when(() => repository.addBeneficiary(any())).thenAnswer((_) async => 10);
    when(
      () => repository.getBeneficiariesByAccountId(1),
    ).thenAnswer((_) async => const [storedItem]);

    await cubit.add(
      accountId: 1,
      nickname: 'Home',
      phoneNumber: '0501234567',
      providerName: 'Etisalat',
      providerLogoUrl: 'logo.png',
    );

    final captured =
        verify(() => repository.addBeneficiary(captureAny())).captured.single
            as LocalBeneficiary;
    expect(captured.phoneNumber, '+971501234567');

    expect(cubit.state.status, BeneficiariesStatus.loaded);
    expect(cubit.state.items.length, 1);
    expect(cubit.state.items.first.id, 10);
  });
}
