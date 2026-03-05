class LocalLoginInfo {
  const LocalLoginInfo({
    required this.accountId,
    required this.phone,
    required this.password,
    required this.isLoggedIn,
    this.updatedAt,
  });

  final int? accountId;
  final String? phone;
  final String? password;
  final bool isLoggedIn;
  final DateTime? updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'account_id': accountId,
      'phone': phone,
      'password': password,
      'is_logged_in': isLoggedIn ? 1 : 0,
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory LocalLoginInfo.fromMap(Map<String, dynamic> map) {
    return LocalLoginInfo(
      accountId: map['account_id'] as int?,
      phone: map['phone'] as String?,
      password: map['password'] as String?,
      isLoggedIn: (map['is_logged_in'] as int? ?? 0) == 1,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }
}
