import 'dart:io';

import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import 'verify_user_page_data.dart';

class VerifyUserPage extends StatefulWidget {
  const VerifyUserPage({super.key});

  @override
  State<VerifyUserPage> createState() => _VerifyUserPageState();
}

class _VerifyUserPageState extends State<VerifyUserPage> with VerifyUserPageDataMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify User')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F9FF), Color(0xFFEFF4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppThemeConstants.burgundy.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Face Detection',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Open the camera, capture your face, then complete verification.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFF8FAFF),
                        border: Border.all(color: const Color(0xFFDDE4F2)),
                      ),
                      child: capturedSelfiePath == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 42,
                                  color: AppThemeConstants.burgundy,
                                ),
                                SizedBox(height: 10),
                                Text('No capture yet'),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(capturedSelfiePath!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isDetected
                          ? 'Face detected successfully'
                          : isDetecting
                              ? 'Detecting face...'
                              : 'Ready for detection',
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 220,
                      child: LinearProgressIndicator(value: progress),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: isDetecting ? null : captureAndDetectFace,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppThemeConstants.burgundy,
                          side: const BorderSide(color: AppThemeConstants.burgundy),
                        ),
                        icon: const Icon(Icons.videocam),
                        label: const Text('Open Camera & Detect Face'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppThemeConstants.burgundy.withValues(alpha: 0.25)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'After the face detection is complete, tap verify to finish.',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed:
                            (capturedSelfiePath == null || !isDetected || isSubmitting)
                                ? null
                                : verify,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppThemeConstants.burgundy,
                          foregroundColor: Colors.white,
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Verify User'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
