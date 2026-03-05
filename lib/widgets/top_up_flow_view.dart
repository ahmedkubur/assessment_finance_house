import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_cubit.dart';
import '../bloc/top_up/top_up_cubit.dart';
import '../bloc/top_up/top_up_state.dart';
import '../utils/app_validators.dart';
import '../utils/constants.dart';

class TopUpFlowView extends StatefulWidget {
  const TopUpFlowView({
    super.key,
    required this.simProviderName,
    required this.simProviderLogoUrl,
    required this.isDirectRecharge,
  });

  final String simProviderName;
  final String simProviderLogoUrl;
  final bool isDirectRecharge;

  @override
  State<TopUpFlowView> createState() => _TopUpFlowViewState();
}

class _TopUpFlowViewState extends State<TopUpFlowView> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    setState(() {});
  }

  bool _isValidPhone(String value) {
    return AppValidators.phone(value) == null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final accountId = authState.account?.id;
    final isVerifiedUser = authState.account?.isVerified ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isDirectRecharge
              ? '${widget.simProviderName} Direct Recharge'
              : '${widget.simProviderName} Top Up',
        ),
      ),
      body: BlocConsumer<TopUpCubit, TopUpState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage,
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          if (state.successMessage != null && state.successMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            context.read<AuthCubit>().refreshAccount();
          }
        },
        builder: (context, state) {
          if (state.status == TopUpStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TopUpStatus.failure && state.beneficiaries.isEmpty) {
            return const Center(child: Text('Top-up is unavailable until you login'));
          }

          final beneficiaries = state.beneficiaries;
          final directPhone = _phoneController.text.trim();
          final directPhoneHasError = directPhone.isNotEmpty && !_isValidPhone(directPhone);
          final hasValidDirectPhone = _isValidPhone(_phoneController.text);
          final canSubmit = state.selectedAmount != null &&
              (widget.isDirectRecharge
                  ? hasValidDirectPhone
                  : state.selectedBeneficiaryId != null);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
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
                    Container(
                      width: 56,
                      height: 56,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8FC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.network(
                        widget.simProviderLogoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, _, _) =>
                            const Icon(Icons.network_cell, size: 26),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.simProviderName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Balance: AED ${state.currentBalance.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (!state.isVerified) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEBCCD3)),
                  ),
                  child: Text(
                    'Unverified account: AED ${AppLimits.unverifiedBeneficiaryMonthlyLimit.toStringAsFixed(0)} monthly per beneficiary',
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                'Beneficiary used this month: AED ${state.beneficiaryMonthlyTotal.toStringAsFixed(0)} / ${state.beneficiaryMonthlyLimit.toStringAsFixed(0)}',
              ),
              Text(
                'Account used this month: AED ${state.accountMonthlyTotal.toStringAsFixed(0)} / ${state.accountMonthlyLimit.toStringAsFixed(0)}',
              ),
              Text(
                'Transaction fee: AED ${AppLimits.topUpCharge.toStringAsFixed(0)} per top-up',
              ),
              const SizedBox(height: 20),
              Text(
                widget.isDirectRecharge ? 'Phone Number' : 'Select Beneficiary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              if (widget.isDirectRecharge)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: AppTextConstants.phoneHint,
                    prefixText: '${AppTextConstants.phoneCountryCode} ',
                    labelText: 'Phone Number',
                    errorText: directPhoneHasError ? 'Enter a valid phone number' : null,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                )
              else if (beneficiaries.isEmpty)
                Text(
                  'No beneficiaries found for ${widget.simProviderName}. Add one first.',
                )
              else
                DropdownButtonFormField<int>(
                  value: state.selectedBeneficiaryId,
                  items: beneficiaries
                      .where((b) => b.id != null)
                      .map(
                        (b) => DropdownMenuItem<int>(
                          value: b.id,
                          child: Text('${b.nickname} - ${b.phoneNumber}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    context.read<TopUpCubit>().selectBeneficiary(
                          value,
                          accountId: accountId,
                        );
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 20),
              if (!widget.isDirectRecharge || hasValidDirectPhone) ...[
                Text(
                  'Select Amount',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.amountOptions.map((amount) {
                    return ChoiceChip(
                      label: Text('AED $amount'),
                      selected: state.selectedAmount == amount,
                      onSelected: (_) => context.read<TopUpCubit>().selectAmount(amount),
                    );
                  }).toList(),
                ),
              ] else ...[
                Text(
                  'Enter a valid phone number to see available amounts.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ],
              const SizedBox(height: 20),
              if (state.selectedAmount != null)
                Text(
                  'Total deduction: AED ${state.totalCost.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              if (state.remainingBalance != null)
                Text(
                  'Remaining balance: AED ${state.remainingBalance!.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: !canSubmit || state.status == TopUpStatus.submitting
                    ? null
                    : () async {
                        if (widget.isDirectRecharge) {
                          if (!_isValidPhone(_phoneController.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Enter a valid phone number')),
                            );
                            return;
                          }
                          await context.read<TopUpCubit>().selectDirectRechargePhone(
                                accountId: accountId,
                                phoneNumber:
                                    AppValidators.toUaePhoneE164(_phoneController.text.trim()),
                                providerName: widget.simProviderName,
                                providerLogoUrl: widget.simProviderLogoUrl,
                              );
                        }

                        if (!context.mounted) return;
                        context.read<TopUpCubit>().submit(
                              accountId: accountId,
                              simProvider: widget.simProviderName,
                              isVerifiedUser: isVerifiedUser,
                            );
                      },
                child: state.status == TopUpStatus.submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirm Top Up'),
              ),
            ],
          );
        },
      ),
    );
  }
}
