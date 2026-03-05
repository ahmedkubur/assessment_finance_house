import 'package:flutter/material.dart';

class AppThemeConstants {
  static const Color burgundy = Color(0xFF800020);
}

class AppTextConstants {
  static const String appTitle = 'assessment';
  static const String phoneCountryCode = '+971';
  static const String phoneHint = '501234567';
  static const String welcomeBack = 'Login';
  static const String loginSubtitle = 'Login with your phone number and password';
  static const String createAccount = 'Create Account';
}

class AppLimits {
  static const List<int> topUpAmountOptions = [5, 10, 20, 30, 50, 75, 100];
  static const double topUpCharge = 3;
  static const double unverifiedBeneficiaryMonthlyLimit = 500;
  static const double verifiedBeneficiaryMonthlyLimit = 1000;
  static const double accountMonthlyLimit = 3000;
  static const double addBalanceMonthlyLimit = 5000;
  static const int maxActiveBeneficiaries = 5;
  static const int maxBeneficiaryNicknameLength = 20;
}

class AppTopUpTextConstants {
  static const String invalidAmount = 'Invalid top-up amount selected';
  static const String accountNotFound = 'Account not found';
  static const String beneficiaryUnavailable = 'Beneficiary not available';
  static const String topUpSuccessPrefix = 'Top-up successful: AED';
  static const String topUpSuccessFeeSuffix = '+ AED 3 fee';
}

class AppProviderConstants {
  static const String duName = 'du UAE';
  static const String duSubtitle = 'Fast prepaid top-up for du numbers';
  static const String duLogo = 'https://images.seeklogo.com/logo-png/18/1/du-logo-png_seeklogo-189322.png';
  static const Color duAccent = Color(0xFF008A7A);

  static const String etisalatName = 'Etisalat e&';
  static const String etisalatSubtitle = 'Recharge e& lines in seconds';
  static const String etisalatLogo = 'https://images.seeklogo.com/logo-png/47/1/etisalat-new-logo-png_seeklogo-470069.png';
  static const Color etisalatAccent = Color(0xFF0F5B3C);

  static const String virginName = 'Virgin Mobile';
  static const String virginSubtitle = 'Top-up and stay connected your way';
  static const String virginLogo = 'https://images.seeklogo.com/logo-png/44/1/virgin-mobile-logo-png_seeklogo-440153.png';
  static const Color virginAccent = Color(0xFFE30613);
}
