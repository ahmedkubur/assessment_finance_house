import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import 'menu_page_data.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with MenuPageDataMixin {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isVerified = authState.account?.isVerified ?? false;
    final accountId = authState.account?.id;
    final pages = buildPages(isVerified);

    final snapshot = authSnapshot(authState);
    if (lastAccountSnapshot != snapshot) {
      lastAccountSnapshot = snapshot;
      beneficiariesCubit.load(accountId);
      profileCubit.load(accountId);
      transactionsCubit.load(accountId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(MenuPageDataMixin.pageTitles[selectedIndex]),
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt),
            label: 'Beneficiaries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_android_outlined),
            activeIcon: Icon(Icons.phone_android),
            label: 'Top Up',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
