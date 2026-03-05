import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/app_validators.dart';
import '../../utils/constants.dart';
import 'add_balance_page_data.dart';

class AddBalancePage extends StatefulWidget {
  const AddBalancePage({super.key});

  @override
  State<AddBalancePage> createState() => _AddBalancePageState();
}

class _AddBalancePageState extends State<AddBalancePage> with AddBalancePageDataMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Balance')),
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
                      'Credit / Debit Card',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Securely add wallet balance using your card details.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppThemeConstants.burgundy.withValues(alpha: 0.25),
                  ),
                ),
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Cardholder Name',
                          helperText: ' ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          return AppValidators.cardholderName(value);
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]')),
                          LengthLimitingTextInputFormatter(20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: cardNumberController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Card Number',
                          hintText: '4111 1111 1111 1111',
                          helperText: ' ',
                          border: OutlineInputBorder(),
                        ),
                        validator: validateCardNumber,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: expiryController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.datetime,
                              decoration: const InputDecoration(
                                labelText: 'Expiry (MM/YY)',
                                helperText: ' ',
                                border: OutlineInputBorder(),
                              ),
                              validator: validateExpiry,
                              onChanged: onExpiryChanged,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: cvvController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                                helperText: ' ',
                                border: OutlineInputBorder(),
                              ),
                              validator: validateCvv,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount (AED)',
                          hintText: '100',
                          helperText: ' ',
                          border: OutlineInputBorder(),
                        ),
                        validator: validateAmount,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: isSubmitting ? null : onSubmit,
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
                              : const Text('Add Balance'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
