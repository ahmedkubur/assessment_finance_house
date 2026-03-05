import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth/auth_cubit.dart';
import 'bloc/auth/auth_state.dart';
import 'core/api/mock_auth_api.dart';
import 'core/api/mock_top_up_api.dart';
import 'pages/login_screen/login_screen.dart';
import 'pages/menu_page/menu_page.dart';
import 'repositories/local_auth_repository.dart';
import 'repositories/local_beneficiaries_repository.dart';
import 'repositories/local_top_up_repository.dart';
import 'utils/constants.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => LocalAuthRepository()),
        RepositoryProvider(create: (_) => LocalBeneficiariesRepository()),
        RepositoryProvider(create: (_) => LocalTopUpRepository()),
        RepositoryProvider(
          create: (context) => MockAuthApi(context.read<LocalAuthRepository>()),
        ),
        RepositoryProvider(
          create: (context) => MockTopUpApi(context.read<LocalTopUpRepository>()),
        ),
      ],
      child: BlocProvider(
        create: (context) =>
            AuthCubit(context.read<LocalAuthRepository>(), context.read<MockAuthApi>())
              ..initialize(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppTextConstants.appTitle,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppThemeConstants.burgundy),
            useMaterial3: true,
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: AppThemeConstants.burgundy,
                foregroundColor: Colors.white,
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppThemeConstants.burgundy,
                side: const BorderSide(color: AppThemeConstants.burgundy),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppThemeConstants.burgundy,
              ),
            ),
          ),
          home: const AuthGate(),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.initial || state.status == AuthStatus.loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state.isLoggedIn) {
          return const MenuPage();
        }

        return const LoginScreen();
      },
    );
  }
}
