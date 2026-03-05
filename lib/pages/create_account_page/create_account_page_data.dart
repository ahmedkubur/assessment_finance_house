import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../utils/app_validators.dart';
import 'create_account_page.dart';

mixin CreateAccountPageDataMixin on State<CreateAccountPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final imagePicker = ImagePicker();
  String? capturedProfileImagePath;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? validateName(String? value) {
    return AppValidators.fullName(value);
  }

  String? validatePhone(String? value) {
    return AppValidators.phone(value);
  }

  String? validatePassword(String? value) {
    return AppValidators.strongPassword(value);
  }

  String? validateEmail(String? value) {
    return AppValidators.email(value);
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    final strongPasswordValidation = AppValidators.strongPassword(value);
    if (strongPasswordValidation != null) return strongPasswordValidation;
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validateProfileImage() {
    if (capturedProfileImagePath == null || capturedProfileImagePath!.isEmpty) {
      return 'Profile image is required';
    }
    return null;
  }

  void toggleObscurePassword() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  void toggleObscureConfirmPassword() {
    setState(() {
      obscureConfirmPassword = !obscureConfirmPassword;
    });
  }

  Future<bool> _ensureCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;

    final requested = await Permission.camera.request();
    if (requested.isGranted) return true;

    if (!mounted) return false;
    if (requested.isPermanentlyDenied || requested.isRestricted) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Camera Permission Needed'),
            content: const Text(
              'Camera permission is required to capture your profile image. Enable it from app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          );
        },
      );
    }
    return false;
  }

  Future<void> captureProfileImage() async {
    final allowed = await _ensureCameraPermission();
    if (!allowed) return;

    final captured = await imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 75,
    );
    if (captured == null || !mounted) return;

    setState(() {
      capturedProfileImagePath = captured.path;
    });
  }

  void onCreateAccount() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    final imageValidationError = validateProfileImage();
    if (imageValidationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(imageValidationError)),
      );
      return;
    }

    final normalizedPhone = AppValidators.toUaePhoneE164(phoneController.text.trim());
    context.read<AuthCubit>().createAccount(
          fullName: nameController.text.trim(),
          phone: normalizedPhone,
          password: passwordController.text,
          email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
          imageUrl: capturedProfileImagePath,
        );
  }

  void onAuthStateChanged(BuildContext context, AuthState state) {
    if (state.status == AuthStatus.accountCreated) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully. Please login.')),
      );
      return;
    }

    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
    }
  }
}
