import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../repositories/local_auth_repository.dart';
import '../../utils/app_validators.dart';
import '../../utils/constants.dart';
import 'add_balance_page.dart';

mixin AddBalancePageDataMixin on State<AddBalancePage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();
  final amountController = TextEditingController();
  bool isSubmitting = false;
  bool _isFormattingExpiry = false;

  @override
  void dispose() {
    nameController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    amountController.dispose();
    super.dispose();
  }

  String? validateCardNumber(String? value) {
    return AppValidators.cardNumber(value);
  }

  String? validateExpiry(String? value) {
    return AppValidators.expiryMmYy(value);
  }

  String? validateCvv(String? value) {
    return AppValidators.cvv(value);
  }

  String? validateAmount(String? value) {
    return AppValidators.amount(value, max: 5000);
  }

  void onExpiryChanged(String value) {
    if (_isFormattingExpiry) return;

    final digits = value.replaceAll(RegExp(r'\D'), '');
    final limitedDigits = digits.length > 4 ? digits.substring(0, 4) : digits;
    String nextValue;

    if (limitedDigits.length <= 2) {
      nextValue = limitedDigits;
    } else {
      nextValue = '${limitedDigits.substring(0, 2)}/${limitedDigits.substring(2)}';
    }

    if (nextValue == value) return;

    _isFormattingExpiry = true;
    expiryController.value = TextEditingValue(
      text: nextValue,
      selection: TextSelection.collapsed(offset: nextValue.length),
    );
    _isFormattingExpiry = false;
  }

  Future<void> onSubmit() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid || isSubmitting) return;

    final accountId = context.read<AuthCubit>().state.account?.id;
    if (accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add balance')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null) {
      if (!mounted) return;
      setState(() {
        isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);
    final authRepository = context.read<LocalAuthRepository>();
    final monthlyAdded = await authRepository.monthlyAddBalanceTotal(
          accountId: accountId,
          from: monthStart,
          to: monthEnd,
        );
    final remaining = (AppLimits.addBalanceMonthlyLimit - monthlyAdded).clamp(0, 999999);
    if (amount > remaining) {
      if (!mounted) return;
      setState(() {
        isSubmitting = false;
      });
      final exceededBy = amount - remaining;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You can add up to AED ${remaining.toStringAsFixed(2)} more this month.',
          ),
        ),
      );
      return;
    }

    final success = await authRepository.addBalance(
          accountId: accountId,
          amount: amount,
        );

    if (!mounted) return;
    setState(() {
      isSubmitting = false;
    });

    if (!success) {
      final latestMonthlyAdded = await authRepository.monthlyAddBalanceTotal(
            accountId: accountId,
            from: monthStart,
            to: monthEnd,
          );
      final latestRemaining =
          (AppLimits.addBalanceMonthlyLimit - latestMonthlyAdded).clamp(0, 999999);
      if (latestRemaining <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Monthly add-balance limit reached: AED ${AppLimits.addBalanceMonthlyLimit.toStringAsFixed(0)}. '
              'You can add balance again next month.',
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add balance')),
      );
      return;
    }

    await context.read<AuthCubit>().refreshAccount();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('AED ${amount.toStringAsFixed(2)} added successfully')),
    );
    Navigator.of(context).pop();
  }
}
