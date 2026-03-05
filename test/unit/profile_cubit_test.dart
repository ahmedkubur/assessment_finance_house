import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recharge/bloc/profile/profile_cubit.dart';
import 'package:recharge/bloc/profile/profile_state.dart';
import 'package:recharge/models/local/local_account.dart';
import 'package:recharge/repositories/local_auth_repository.dart';

class MockLocalAuthRepository extends Mock implements LocalAuthRepository {}

void main() {
  late MockLocalAuthRepository repository;
  late ProfileCubit cubit;
  late StreamSubscription<ProfileState> subscription;
  late List<ProfileState> emittedStates;

  setUp(() {
    repository = MockLocalAuthRepository();
    cubit = ProfileCubit(repository);
    emittedStates = <ProfileState>[];
    subscription = cubit.stream.listen(emittedStates.add);
  });

  tearDown(() async {
    await subscription.cancel();
    await cubit.close();
  });

  test('load with null account emits loaded state with no account', () async {
    await cubit.load(null);

    expect(cubit.state.status, ProfileStatus.loaded);
    expect(cubit.state.account, isNull);
    verifyNever(() => repository.getAccountById(any()));
  });

  test('changePassword fails for same current and new password', () async {
    final success = await cubit.changePassword(
      accountId: 1,
      currentPassword: 'abc123',
      newPassword: 'abc123',
    );

    expect(success, isFalse);
    expect(cubit.state.status, ProfileStatus.failure);
    expect(cubit.state.errorMessage, 'New password must be different');
    verifyNever(
      () => repository.changePassword(
        accountId: any(named: 'accountId'),
        currentPassword: any(named: 'currentPassword'),
        newPassword: any(named: 'newPassword'),
      ),
    );
  });

  test('changePassword success reloads profile', () async {
    const updatedAccount = LocalAccount(
      id: 1,
      fullName: 'Updated User',
      phone: '+971501111111',
      password: 'new1234',
      balance: 200,
      isVerified: false,
    );

    when(
      () => repository.changePassword(
        accountId: 1,
        currentPassword: 'old1234',
        newPassword: 'new1234',
      ),
    ).thenAnswer((_) async => true);
    when(() => repository.getAccountById(1)).thenAnswer((_) async => updatedAccount);

    final success = await cubit.changePassword(
      accountId: 1,
      currentPassword: 'old1234',
      newPassword: 'new1234',
    );

    expect(success, isTrue);
    expect(cubit.state.status, ProfileStatus.loaded);
    expect(cubit.state.account?.fullName, 'Updated User');
  });
}
