class TopUpResult {
  const TopUpResult({
    required this.isSuccess,
    required this.message,
    this.remainingBalance,
  });

  final bool isSuccess;
  final String message;
  final double? remainingBalance;

  factory TopUpResult.success({required String message, required double remainingBalance}) {
    return TopUpResult(
      isSuccess: true,
      message: message,
      remainingBalance: remainingBalance,
    );
  }

  factory TopUpResult.failure(String message) {
    return TopUpResult(
      isSuccess: false,
      message: message,
    );
  }
}
