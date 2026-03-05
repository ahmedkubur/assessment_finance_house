import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../utils/app_validators.dart';
import '../add_balance_page/add_balance_page.dart';
import '../verify_user_page/verify_user_page.dart';
import 'user_profile_page.dart';

extension UserProfilePageData on UserProfilePage {
  ImageProvider<Object>? imageProviderFromPath(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final trimmed = path.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }

    final imageFile = File(trimmed);
    if (!imageFile.existsSync()) return null;
    return FileImage(imageFile);
  }

  Future<bool> _ensureCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;

    final requested = await Permission.camera.request();
    if (requested.isGranted) return true;

    if (!context.mounted) return false;
    if (requested.isPermanentlyDenied || requested.isRestricted) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Camera Permission Needed'),
            content: const Text(
              'Camera permission is required to update your profile image. Enable it from app settings.',
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

  Future<void> updateProfileImageFromCamera(BuildContext context) async {
    final accountId = context.read<AuthCubit>().state.account?.id;
    if (accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login required')),
      );
      return;
    }

    final allowed = await _ensureCameraPermission(context);
    if (!allowed) return;

    final picker = ImagePicker();
    final captured = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 75,
    );

    if (captured == null || !context.mounted) return;

    final success = await context.read<ProfileCubit>().updateProfileImage(
          accountId: accountId,
          imagePath: captured.path,
        );
    if (!context.mounted) return;

    if (success) {
      await context.read<AuthCubit>().refreshAccount();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated')),
      );
    }
  }

  Future<void> showAddBalanceDialog(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddBalancePage()),
    );
  }

  Future<void> showChangePasswordDialog(BuildContext context) async {
    final authCubit = context.read<AuthCubit>();
    final profileCubit = context.read<ProfileCubit>();
    final formKey = GlobalKey<FormState>();
    var currentPassword = '';
    var newPassword = '';
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              title: const Text('Change Password'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      obscureText: obscureCurrent,
                      onChanged: (value) {
                        currentPassword = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureCurrent = !obscureCurrent;
                            });
                          },
                          icon: Icon(
                            obscureCurrent ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ),
                      validator: (value) {
                        return AppValidators.loginPassword(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      onChanged: (value) {
                        newPassword = value;
                      },
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureNew = !obscureNew;
                            });
                          },
                          icon: Icon(
                            obscureNew ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == currentPassword) {
                          return 'New password must be different';
                        }
                        return AppValidators.strongPassword(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureConfirm = !obscureConfirm;
                            });
                          },
                          icon: Icon(
                            obscureConfirm ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm password';
                        }
                        final strongPasswordValidation =
                            AppValidators.strongPassword(value);
                        if (strongPasswordValidation != null) {
                          return strongPasswordValidation;
                        }
                        if (value != newPassword) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final isValid = formKey.currentState?.validate() ?? false;
                    if (!isValid) return;
                    final accountId = authCubit.state.account?.id;
                    final success = await profileCubit.changePassword(
                          accountId: accountId,
                          currentPassword: currentPassword,
                          newPassword: newPassword,
                        );
                    if (!dialogContext.mounted) return;
                    Navigator.of(dialogContext).pop();
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password changed successfully')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldLogout || !context.mounted) return;
    await context.read<AuthCubit>().logout();
  }

  Future<void> openVerifyPage(BuildContext context) async {
    final profileCubit = context.read<ProfileCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: profileCubit,
          child: const VerifyUserPage(),
        ),
      ),
    );
  }
}
