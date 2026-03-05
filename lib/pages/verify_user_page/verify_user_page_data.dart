import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/profile/profile_cubit.dart';
import 'verify_user_page.dart';

mixin VerifyUserPageDataMixin on State<VerifyUserPage> {
  final imagePicker = ImagePicker();

  String? capturedSelfiePath;
  bool isDetecting = false;
  bool isDetected = false;
  bool isSubmitting = false;
  double progress = 0;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<bool> ensureCameraPermission() async {
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
              'Camera permission is required for live face detection. Enable it from app settings.',
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission denied. Please allow it to verify.')),
      );
    }
    return false;
  }

  Future<void> captureAndDetectFace() async {
    if (isDetecting) return;
    final allowed = await ensureCameraPermission();
    if (!allowed) return;

    final captured = await imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 75,
    );
    if (captured == null || !mounted) return;

    setState(() {
      capturedSelfiePath = captured.path;
      isDetecting = true;
      isDetected = false;
      progress = 0;
    });

    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 250), (activeTimer) {
      setState(() {
        progress += 0.1;
      });

      if (progress >= 1) {
        activeTimer.cancel();
        setState(() {
          progress = 1;
          isDetecting = false;
          isDetected = true;
        });
      }
    });
  }

  Future<void> verify() async {
    if (capturedSelfiePath == null || !isDetected || isSubmitting) return;

    final accountId = context.read<AuthCubit>().state.account?.id;
    if (accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login required')),
      );
      return;
    }

    ProfileCubit? profileCubit;
    try {
      profileCubit = context.read<ProfileCubit>();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification service is unavailable. Please reopen page.')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    final success = await profileCubit.verifyUser(
          accountId: accountId,
          selfieImageUrl: capturedSelfiePath!,
        );

    if (!mounted) return;
    setState(() {
      isSubmitting = false;
    });

    if (!success) return;

    await context.read<AuthCubit>().refreshAccount();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User verified successfully')),
    );
    Navigator.of(context).pop(true);
  }
}
