import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../add_balance_page/add_balance_page.dart';
import '../top_up_flow_page/top_up_flow_page.dart';
import 'top_up_page.dart';

mixin TopUpPageDataMixin on State<TopUpPage> {
  int selectedProviderIndex = 0;
}

extension TopUpPageData on TopUpPage {
  List<CarrierProvider> get providers => const [
        CarrierProvider(
          name: AppProviderConstants.duName,
          subtitle: AppProviderConstants.duSubtitle,
          logoUrl: AppProviderConstants.duLogo,
        ),
        CarrierProvider(
          name: AppProviderConstants.etisalatName,
          subtitle: AppProviderConstants.etisalatSubtitle,
          logoUrl: AppProviderConstants.etisalatLogo,
        ),
        CarrierProvider(
          name: AppProviderConstants.virginName,
          subtitle: AppProviderConstants.virginSubtitle,
          logoUrl: AppProviderConstants.virginLogo,
        ),
      ];

  void openProvider(BuildContext context, CarrierProvider provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TopUpFlowPage(
          simProviderName: provider.name,
          simProviderLogoUrl: provider.logoUrl,
          isDirectRecharge: false,
        ),
      ),
    );
  }

  void openDirectRechargeProvider(BuildContext context, CarrierProvider provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TopUpFlowPage(
          simProviderName: provider.name,
          simProviderLogoUrl: provider.logoUrl,
          isDirectRecharge: true,
        ),
      ),
    );
  }

  Future<void> openAddBalancePage(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddBalancePage()),
    );
  }
}

class CarrierProvider {
  const CarrierProvider({
    required this.name,
    required this.subtitle,
    required this.logoUrl,
  });

  final String name;
  final String subtitle;
  final String logoUrl;
}
