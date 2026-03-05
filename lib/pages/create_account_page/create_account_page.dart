import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../utils/constants.dart';
import 'create_account_page_data.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage>
    with CreateAccountPageDataMixin {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status || previous.errorMessage != current.errorMessage,
      listener: onAuthStateChanged,
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;

        return Scaffold(
          appBar: AppBar(title: const Text(AppTextConstants.createAccount)),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: validateName,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: AppTextConstants.phoneHint,
                        prefixText: '${AppTextConstants.phoneCountryCode} ',
                        border: OutlineInputBorder(),
                      ),
                      validator: validatePhone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: emailController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDDE4F2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Profile Image',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: CircleAvatar(
                              radius: 42,
                              backgroundColor: const Color(0xFFF0F3FA),
                              backgroundImage: capturedProfileImagePath != null
                                  ? FileImage(File(capturedProfileImagePath!))
                                  : null,
                              child: capturedProfileImagePath == null
                                  ? const Icon(Icons.person, size: 40)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: isLoading ? null : captureProfileImage,
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: Text(
                              capturedProfileImagePath == null
                                  ? 'Capture From Camera'
                                  : 'Retake Photo',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      textInputAction: TextInputAction.next,
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
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: toggleObscureConfirmPassword,
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      validator: validateConfirmPassword,
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: isLoading ? null : onCreateAccount,
                      child: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(AppTextConstants.createAccount),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
