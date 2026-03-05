import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recharge/bloc/auth/auth_cubit.dart';
import 'package:recharge/bloc/auth/auth_state.dart';
import 'package:recharge/core/api/mock_auth_api.dart';
import 'package:recharge/models/local/local_account.dart';
import 'package:recharge/models/local/local_login_info.dart';
import 'package:recharge/repositories/local_auth_repository.dart';

class MockLocalAuthRepository extends Mock implements LocalAuthRepository {}

class MockMockAuthApi extends Mock implements MockAuthApi {}

void main() {
  late MockLocalAuthRepository repository;
  late MockMockAuthApi mockAuthApi;
  late AuthCubit cubit;
  late StreamSubscription<AuthState> subscription;
  late List<AuthState> emittedStates;

  setUpAll(() {
    registerFallbackValue(
      const LocalAccount(
        fullName: 'Test User',
        phone: '+971500000000',
        password: 'password123',
      ),
    );
    registerFallbackValue(
      const LocalLoginInfo(
        accountId: 1,
        phone: '+971500000000',
        password: 'password123',
        isLoggedIn: true,
      ),
    );
  });

  setUp(() {
    repository = MockLocalAuthRepository();
    mockAuthApi = MockMockAuthApi();
    cubit = AuthCubit(repository, mockAuthApi);
    emittedStates = <AuthState>[];
    subscription = cubit.stream.listen(emittedStates.add);
  });

  tearDown(() async {
    await subscription.cancel();
    await cubit.close();
  });

  group('login', () {
    test('login success emits authenticated state with account', () async {
      const account = LocalAccount(
        id: 1,
        fullName: 'Test User',
        phone: '+971500000000',
        password: 'password123',
        balance: 100.0,
        isVerified: false,
      );

      when(() => mockAuthApi.login(phone: any(named: 'phone'), password: any(named: 'password')))
          .thenAnswer((_) async => account);

      await cubit.login(phone: '+971500000000', password: 'password123');

      await Future.delayed(const Duration(milliseconds: 100));

      expect(emittedStates.length, 2);
      expect(emittedStates[0].status, AuthStatus.loading);
      expect(emittedStates[1].status, AuthStatus.authenticated);
      expect(emittedStates[1].account?.id, 1);
      expect(emittedStates[1].account?.fullName, 'Test User');
    });

    test('login failure emits failure state with error message', () async {
      when(() => mockAuthApi.login(phone: any(named: 'phone'), password: any(named: 'password')))
          .thenThrow(Exception('Invalid phone or password'));

      await cubit.login(phone: '+971500000000', password: 'wrongpassword');

      await Future.delayed(const Duration(milliseconds: 100));

      expect(emittedStates.length, 2);
      expect(emittedStates[0].status, AuthStatus.loading);
      expect(emittedStates[1].status, AuthStatus.failure);
      expect(emittedStates[1].errorMessage, 'Invalid phone or password');
    });
  });

  group('logout', () {
    test('logout emits unauthenticated state and clears account', () async {
      when(() => repository.logout(clearSavedCredentials: any(named: 'clearSavedCredentials')))
          .thenAnswer((_) async {});

      await cubit.logout();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(emittedStates.length, 1);
      expect(emittedStates.first.status, AuthStatus.unauthenticated);
      expect(emittedStates.first.account, isNull);
    });
  });
}

