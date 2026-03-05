import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/beneficiaries/beneficiaries_cubit.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/transactions/transactions_cubit.dart';
import '../../repositories/local_auth_repository.dart';
import '../../repositories/local_beneficiaries_repository.dart';
import '../../repositories/local_top_up_repository.dart';
import '../beneficiaries_page/beneficiaries_page.dart';
import '../top_up_page/top_up_page.dart';
import '../transactions_page/transactions_page.dart';
import '../user_profile_page/user_profile_page.dart';
import 'menu_page.dart';

mixin MenuPageDataMixin on State<MenuPage> {
  int selectedIndex = 1;
  late final BeneficiariesCubit beneficiariesCubit;
  late final ProfileCubit profileCubit;
  late final TransactionsCubit transactionsCubit;
  String lastAccountSnapshot = '';

  static const List<String> pageTitles = <String>[
    'Beneficiaries',
    'Top Up',
    'Transactions',
    'User Profile',
  ];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    final accountId = authState.account?.id;
    lastAccountSnapshot = authSnapshot(authState);

    beneficiariesCubit =
        BeneficiariesCubit(context.read<LocalBeneficiariesRepository>())..load(accountId);
    profileCubit = ProfileCubit(context.read<LocalAuthRepository>())..load(accountId);
    transactionsCubit = TransactionsCubit(context.read<LocalTopUpRepository>())..load(accountId);
  }

  @override
  void dispose() {
    beneficiariesCubit.close();
    profileCubit.close();
    transactionsCubit.close();
    super.dispose();
  }

  List<Widget> buildPages(bool isVerified) {
    return [
      BlocProvider.value(
        value: beneficiariesCubit,
        child: BeneficiariesPage(isVerified: isVerified),
      ),
      const TopUpPage(),
      BlocProvider.value(
        value: transactionsCubit,
        child: const TransactionsPage(),
      ),
      BlocProvider.value(
        value: profileCubit,
        child: UserProfilePage(isVerified: isVerified),
      ),
    ];
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  String authSnapshot(AuthState state) {
    final account = state.account;
    if (account == null) {
      return '${state.status.name}-none';
    }
    return '${state.status.name}-${account.id}-${account.balance}-${account.isVerified}';
  }
}
