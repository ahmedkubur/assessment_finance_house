import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import 'top_up_flow_page.dart';

extension TopUpFlowPageData on TopUpFlowPage {
  int? accountIdFromContext(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    return authState.account?.id;
  }

  bool isVerifiedUserFromContext(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    return authState.account?.isVerified ?? false;
  }
}
