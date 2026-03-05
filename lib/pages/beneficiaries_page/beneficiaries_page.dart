import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/beneficiaries/beneficiaries_cubit.dart';
import '../../bloc/beneficiaries/beneficiaries_state.dart';
import '../../utils/constants.dart';
import '../../widgets/beneficiary_card.dart';
import 'beneficiaries_page_data.dart';

class BeneficiariesPage extends StatelessWidget {
  const BeneficiariesPage({
    super.key,
    required this.isVerified,
  });

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<BeneficiariesCubit, BeneficiariesState>(
      listenWhen: (previous, current) => previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage == null || state.errorMessage!.isEmpty) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      },
      child: BlocBuilder<BeneficiariesCubit, BeneficiariesState>(
        builder: (context, state) {
          final items = state.items;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5F9FF), Color(0xFFEDF4FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Beneficiaries',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isVerified
                                      ? 'Manage saved numbers for quick top-up'
                                      : 'Verify your user to add beneficiaries',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: isVerified ? () => onAddBeneficiary(context) : null,
                            icon: const Icon(Icons.person_add_alt_1),
                            label: const Text('Add'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: state.status == BeneficiariesStatus.loading
                        ? const Center(child: CircularProgressIndicator())
                        : items.isEmpty
                            ? const Center(
                                child: Text('No beneficiaries yet'),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return BeneficiaryCard(
                                    item: item,
                                    accent: AppThemeConstants.burgundy,
                                    isVerified: isVerified,
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
