import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/top_up/top_up_cubit.dart';
import '../../core/api/mock_top_up_api.dart';
import '../../repositories/local_top_up_repository.dart';
import '../../widgets/top_up_flow_view.dart';
import 'top_up_flow_page_data.dart';

class TopUpFlowPage extends StatelessWidget {
  const TopUpFlowPage({
    super.key,
    required this.simProviderName,
    required this.simProviderLogoUrl,
    required this.isDirectRecharge,
  });

  final String simProviderName;
  final String simProviderLogoUrl;
  final bool isDirectRecharge;

  @override
  Widget build(BuildContext context) {
    final accountId = accountIdFromContext(context);
    final isVerifiedUser = isVerifiedUserFromContext(context);

    return BlocProvider(
      create: (context) => TopUpCubit(
        topUpRepository: context.read<LocalTopUpRepository>(),
        mockTopUpApi: context.read<MockTopUpApi>(),
      )..load(
          accountId: accountId,
          isVerifiedUser: isVerifiedUser,
          providerName: simProviderName,
        ),
      child: TopUpFlowView(
        simProviderName: simProviderName,
        simProviderLogoUrl: simProviderLogoUrl,
        isDirectRecharge: isDirectRecharge,
      ),
    );
  }
}
