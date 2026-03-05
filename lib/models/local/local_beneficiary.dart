class LocalBeneficiary {
  const LocalBeneficiary({
    this.id,
    required this.accountId,
    required this.nickname,
    required this.phoneNumber,
    required this.providerName,
    required this.providerLogoUrl,
    this.isActive = true,
    this.createdAt,
  });

  final int? id;
  final int accountId;
  final String nickname;
  final String phoneNumber;
  final String providerName;
  final String providerLogoUrl;
  final bool isActive;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'nickname': nickname,
      'phone_number': phoneNumber,
      'provider_name': providerName,
      'provider_logo_url': providerLogoUrl,
      'is_active': isActive ? 1 : 0,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory LocalBeneficiary.fromMap(Map<String, dynamic> map) {
    return LocalBeneficiary(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      nickname: map['nickname'] as String,
      phoneNumber: map['phone_number'] as String,
      providerName: map['provider_name'] as String,
      providerLogoUrl: map['provider_logo_url'] as String,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
