import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';
import '../../utils/constants.dart';
import '../../widgets/action_tile.dart';
import 'user_profile_page_data.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key, required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) => previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage == null || state.errorMessage!.isEmpty) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final account = state.account;
          final name = account?.fullName ?? 'User';
          final phone = account?.phone ?? '-';
          final email = account?.email ?? 'No email';
          final imageUrl = account?.imageUrl;
          final profileImage = imageProviderFromPath(imageUrl);
          final balance = account?.balance ?? 0;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF6F9FF), Color(0xFFEFF3FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 34,
                                backgroundColor: const Color(0xFFF0F3FA),
                                backgroundImage: profileImage,
                                child: profileImage == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 34,
                                        color: AppThemeConstants.burgundy,
                                      )
                                    : null,
                              ),
                              IconButton(
                                onPressed: () => updateProfileImageFromCamera(context),
                                icon: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: AppThemeConstants.burgundy,
                                ),
                                tooltip: 'Edit profile image',
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  phone,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isVerified ? 'Status: Verified' : 'Status: Unverified',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isVerified
                                        ? Colors.green.shade700
                                        : AppThemeConstants.burgundy,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8F2445), Color(0xFF6B0F2B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Balance',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'AED ${balance.toStringAsFixed(2)}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.tonal(
                              onPressed: () => showAddBalanceDialog(context),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF6B0F2B),
                              ),
                              child: const Text('Add Balance'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (!isVerified) ...[
                      ActionTile(
                        icon: Icons.verified_user_outlined,
                        title: 'Verify User',
                        subtitle: 'Complete live face detection to verify',
                        iconColor: AppThemeConstants.burgundy,
                        onTap: () => openVerifyPage(context),
                      ),
                      const SizedBox(height: 10),
                    ],
                    ActionTile(
                      icon: Icons.lock_reset,
                      title: 'Change Password',
                      subtitle: 'Update your account password securely',
                      onTap: () => showChangePasswordDialog(context),
                    ),
                    const SizedBox(height: 10),
                    ActionTile(
                      icon: Icons.logout,
                      title: 'Logout',
                      subtitle: 'Sign out from your current session',
                      iconColor: const Color(0xFFB82222),
                      onTap: () => logout(context),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
