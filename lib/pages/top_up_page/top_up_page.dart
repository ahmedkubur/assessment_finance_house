import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../utils/constants.dart';
import 'top_up_page_data.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> with TopUpPageDataMixin {
  void _showVerifyDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Verify User Required'),
          content: const Text('Please verify your user from the Profile page to continue.'),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthCubit>().state;
    final currentBalance = authState.account?.balance ?? 0;
    final isVerifiedUser = authState.account?.isVerified ?? false;
    final providers = widget.providers;
    final selectedProvider = providers[selectedProviderIndex];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF6FAFF), Color(0xFFEEF4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                constraints: const BoxConstraints(minHeight: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF005C97), Color(0xFF363795)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mobile Top Up',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your network, complete payment, and recharge instantly.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Wallet Balance: AED ${currentBalance.toStringAsFixed(2)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: () => widget.openAddBalancePage(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppThemeConstants.burgundy,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 14,
                        ),
                      ),
                      icon: const Icon(Icons.credit_card),
                      label: const Text('Add Balance'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Direct Recharge',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppThemeConstants.burgundy.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: providers.map((provider) {
                    return Expanded(
                      child: InkWell(
                        onTap: () => widget.openDirectRechargeProvider(context, provider),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F9FE),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppThemeConstants.burgundy.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Image.network(
                                  provider.logoUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, _, _) => const Icon(
                                    Icons.network_cell,
                                    color: AppThemeConstants.burgundy,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                provider.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Beneficiary Recharge',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose a provider to see the beneficiaries inside it',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppThemeConstants.burgundy,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'then select a beneficiary to recharge it.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppThemeConstants.burgundy,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: isVerifiedUser ? null : _showVerifyDialog,
                behavior: HitTestBehavior.opaque,
                child: AbsorbPointer(
                  absorbing: !isVerifiedUser,
                  child: Opacity(
                    opacity: isVerifiedUser ? 1 : 0.45,
                    child: Column(
                      children: [
                        ...List.generate(providers.length, (index) {
                          final provider = providers[index];
                          final isSelected = index == selectedProviderIndex;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                setState(() {
                                  selectedProviderIndex = index;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppThemeConstants.burgundy
                                        : const Color(0xFFDDE4F2),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 58,
                                      height: 58,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF7F9FE),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Image.network(
                                        provider.logoUrl,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, _, _) {
                                          return const Icon(
                                            Icons.network_cell,
                                            color: AppThemeConstants.burgundy,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            provider.name,
                                            style: theme.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            provider.subtitle,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Radio<int>(
                                      value: index,
                                      groupValue: selectedProviderIndex,
                                      activeColor: AppThemeConstants.burgundy,
                                      onChanged: (value) {
                                        if (value == null) return;
                                        setState(() {
                                          selectedProviderIndex = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: isVerifiedUser
                    ? () {
                        widget.openProvider(context, selectedProvider);
                      }
                    : _showVerifyDialog,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Continue'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
