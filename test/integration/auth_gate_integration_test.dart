import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recharge/bloc/auth/auth_cubit.dart';
import 'package:recharge/bloc/auth/auth_state.dart';
import 'package:recharge/core/api/mock_auth_api.dart';
import 'package:recharge/main.dart';
import 'package:recharge/models/local/local_login_info.dart';
import 'package:recharge/repositories/local_auth_repository.dart';

class MockLocalAuthRepository extends Mock implements LocalAuthRepository {}

class MockMockAuthApi extends Mock implements MockAuthApi {}

void main() {
  testWidgets(
    'AuthGate shows loader first, then LoginScreen when user is unauthenticated',
    (tester) async {
      final authRepository = MockLocalAuthRepository();
      final authApi = MockMockAuthApi();

      when(() => authRepository.getLoginInfo()).thenAnswer((_) async =>
          const LocalLoginInfo(
            accountId: null,
            phone: null,
            password: null,
            isLoggedIn: false,
          ));

      final cubit = AuthCubit(authRepository, authApi);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: cubit,
            child: const AuthGate(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(cubit.state.status, AuthStatus.initial);

      await cubit.initialize();
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Create New Account'), findsOneWidget);
      expect(cubit.state.status, AuthStatus.unauthenticated);

      await cubit.close();
    },
  );
}
