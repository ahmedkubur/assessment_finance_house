import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../utils/constants.dart';
import 'login_screen_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with LoginScreenDataMixin {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.errorMessage != current.errorMessage,
      listener: onAuthStateChanged,
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppTextConstants.welcomeBack,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppTextConstants.loginSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: validatePhone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            hintText: AppTextConstants.phoneHint,
                            prefixText: '${AppTextConstants.phoneCountryCode} ',
                            border: OutlineInputBorder(),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          textInputAction: TextInputAction.done,
                          validator: validatePassword,
                          onFieldSubmitted: (_) => onLogin(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: toggleObscurePassword,
                              icon: Icon(
                                obscurePassword ? Icons.visibility_off : Icons.visibility,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: isLoading ? null : onLogin,
                          child: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Login'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: isLoading ? null : () => onCreateAccount(context),
                          child: const Text('Create New Account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
