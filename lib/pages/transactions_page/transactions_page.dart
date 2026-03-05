import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/transactions/transactions_cubit.dart';
import '../../bloc/transactions/transactions_state.dart';
import '../../utils/constants.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, state) {
        if (state.status == TransactionsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == TransactionsStatus.failure) {
          return Center(
            child: Text(state.errorMessage ?? 'Could not load transactions'),
          );
        }

        if (state.items.isEmpty) {
          return const Center(
            child: Text('No transactions yet'),
          );
        }

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF6F9FF), Color(0xFFEFF3FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            itemCount: state.items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = state.items[index];
              final isAddBalance = item.type == TransactionType.addBalance;
              final title = isAddBalance ? 'Add Balance' : 'Top Up';
              final amountColor = isAddBalance ? Colors.green.shade700 : AppThemeConstants.burgundy;
              final amountPrefix = isAddBalance ? '+' : '-';
              final methodText = (item.rechargeMethod ?? '').trim().toLowerCase();
              final isDirectRecharge = methodText == 'direct';
              final topUpMethodLine = isAddBalance
                  ? 'Wallet credit'
                  : (isDirectRecharge
                      ? 'Direct'
                      : 'Beneficiry : ${(item.beneficiaryName ?? '').trim()}');
              final phoneLine = isAddBalance
                  ? null
                  : (item.phoneNumber ?? '').trim();
              final providerAndFeeLine =
                  isAddBalance ? null : '${item.reference} • fee AED ${item.charge.toStringAsFixed(0)}';

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          isAddBalance ? Colors.green.withValues(alpha: 0.12) : const Color(0xFFFDEEEF),
                      child: Icon(
                        isAddBalance ? Icons.add : Icons.phone_android,
                        color: amountColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            topUpMethodLine,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                          if (phoneLine != null && phoneLine.trim().isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              phoneLine,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                          if (providerAndFeeLine != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              providerAndFeeLine,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                          const SizedBox(height: 3),
                          Text(
                            _formatDate(item.createdAt),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$amountPrefix AED ${item.total.toStringAsFixed(0)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}
