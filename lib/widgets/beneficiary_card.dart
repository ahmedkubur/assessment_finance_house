import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_cubit.dart';
import '../bloc/beneficiaries/beneficiaries_cubit.dart';
import '../models/local/local_beneficiary.dart';

class BeneficiaryCard extends StatelessWidget {
  const BeneficiaryCard({
    super.key,
    required this.item,
    required this.accent,
    required this.isVerified,
  });

  final LocalBeneficiary item;
  final Color accent;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
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
            width: 54,
            height: 54,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.network(
              item.providerLogoUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, _, _) => Icon(
                Icons.network_cell,
                color: accent,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nickname,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.phoneNumber,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.providerName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          if (isVerified && item.id != null)
            IconButton(
              onPressed: () async {
                final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          title: const Text('Delete Beneficiary'),
                          content: Text(
                            'Are you sure you want to delete "${item.nickname}" from your beneficiaries?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(dialogContext).pop(true),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Delete Beneficiary'),
                            ),
                          ],
                        );
                      },
                    ) ??
                    false;

                if (!shouldDelete || !context.mounted) return;
                final accountId = context.read<AuthCubit>().state.account?.id;
                context.read<BeneficiariesCubit>().remove(
                      accountId: accountId,
                      beneficiaryId: item.id!,
                    );
              },
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
    );
  }
}
