import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../utils/app_validators.dart';
import '../create_account_page/create_account_page.dart';
import 'login_screen.dart';

mixin LoginScreenDataMixin on State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? validatePhone(String? value) {
    return AppValidators.phone(value);
  }

  String? validatePassword(String? value) {
    return AppValidators.loginPassword(value);
  }

  void toggleObscurePassword() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  void onLogin() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final normalizedPhone = AppValidators.toUaePhoneE164(phoneController.text.trim());
    context.read<AuthCubit>().login(
          phone: normalizedPhone,
          password: passwordController.text,
        );
  }

  Future<void> onCreateAccount(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateAccountPage()),
    );
  }

  void onAuthStateChanged(BuildContext context, AuthState state) {
    if (state.errorMessage == null || state.errorMessage!.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.errorMessage!)),
    );
  }
}
