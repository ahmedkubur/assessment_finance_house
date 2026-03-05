class LocalAccount {
  const LocalAccount({
    this.id,
    required this.fullName,
    required this.phone,
    required this.password,
    this.email,
    this.imageUrl,
    this.balance = 0,
    this.isVerified = false,
    this.createdAt,
  });

  final int? id;
  final String fullName;
  final String phone;
  final String password;
  final String? email;
  final String? imageUrl;
  final double balance;
  final bool isVerified;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'password': password,
      'email': email,
      'image_url': imageUrl,
      'balance': balance,
      'is_verified': isVerified ? 1 : 0,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory LocalAccount.fromMap(Map<String, dynamic> map) {
    return LocalAccount(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      phone: map['phone'] as String,
      password: map['password'] as String,
      email: map['email'] as String?,
      imageUrl: map['image_url'] as String?,
      balance: (map['balance'] as num?)?.toDouble() ?? 0,
      isVerified: (map['is_verified'] as int? ?? 0) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }
}
