import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/beneficiaries/beneficiaries_cubit.dart';
import '../../utils/app_validators.dart';
import '../../utils/constants.dart';
import 'beneficiaries_page.dart';

extension BeneficiariesPageData on BeneficiariesPage {
  Future<void> onAddBeneficiary(BuildContext context) async {
    final pageContext = context;

    if (!isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your user to add beneficiaries')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    var nicknameValue = '';
    var numberValue = '';
    int providerIndex = 0;

    final providers = const [
      _ProviderOption(
        name: AppProviderConstants.duName,
        logoUrl: AppProviderConstants.duLogo,
      ),
      _ProviderOption(
        name: AppProviderConstants.etisalatName,
        logoUrl: AppProviderConstants.etisalatLogo,
      ),
      _ProviderOption(
        name: AppProviderConstants.virginName,
        logoUrl: AppProviderConstants.virginLogo,
      ),
    ];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setStateDialog) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              title: const Text('Add Beneficiary'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nickname',
                          hintText: 'Brother, Home, Work',
                        ),
                        onChanged: (value) {
                          nicknameValue = value;
                        },
                        validator: (value) {
                          return AppValidators.beneficiaryNickname(
                            value,
                            maxLength: AppLimits.maxBeneficiaryNicknameLength,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: AppTextConstants.phoneHint,
                          prefixText: '${AppTextConstants.phoneCountryCode} ',
                        ),
                        onChanged: (value) {
                          numberValue = value;
                        },
                        validator: (value) {
                          return AppValidators.phone(value);
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Provider',
                          style: Theme.of(builderContext).textTheme.labelLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(providers.length, (index) {
                        final provider = providers[index];
                        final isSelected = providerIndex == index;
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setStateDialog(() {
                              providerIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppThemeConstants.burgundy
                                    : const Color(0xFFDDE4F2),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: Image.network(
                                    provider.logoUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, _, _) => const Icon(
                                      Icons.network_cell,
                                      size: 20,
                                      color: AppThemeConstants.burgundy,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(child: Text(provider.name)),
                                Radio<int>(
                                  value: index,
                                  groupValue: providerIndex,
                                  activeColor: AppThemeConstants.burgundy,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setStateDialog(() {
                                      providerIndex = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final isValid = formKey.currentState?.validate() ?? false;
                    if (!isValid) return;

                    final selected = providers[providerIndex];
                    final accountId = pageContext.read<AuthCubit>().state.account?.id;
                    final normalizedPhone =
                        AppValidators.toUaePhoneE164(numberValue.trim());

                    pageContext.read<BeneficiariesCubit>().add(
                          accountId: accountId,
                          nickname: nicknameValue.trim(),
                          phoneNumber: normalizedPhone,
                          providerName: selected.name,
                          providerLogoUrl: selected.logoUrl,
                        );
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ProviderOption {
  const _ProviderOption({
    required this.name,
    required this.logoUrl,
  });

  final String name;
  final String logoUrl;
}
