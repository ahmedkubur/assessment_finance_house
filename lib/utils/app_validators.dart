class AppValidators {
  static const String uaeCountryCode = '+971';

  static String normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  static String normalizeUaeLocalPhone(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('971')) {
      digits = digits.substring(3);
    }
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    return digits;
  }

  static String toUaePhoneE164(String value) {
    final local = normalizeUaeLocalPhone(value);
    return '$uaeCountryCode$local';
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final local = normalizeUaeLocalPhone(value.trim());
    if (!RegExp(r'^\d{9}$').hasMatch(local)) {
      return 'Enter a valid UAE phone number';
    }
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Full name must be at least 2 characters';
    }
    if (trimmed.length > 20) {
      return 'Full name must be 20 characters or less';
    }
    if (!RegExp(r"^[A-Za-z][A-Za-z\s.\'-]*$").hasMatch(trimmed)) {
      return 'Enter a valid full name';
    }
    return null;
  }

  static String? emailOptional(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    if (trimmed.length > 254) return 'Email is too long';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    return emailOptional(value);
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (value.length > 64) {
      return 'Password must be 64 characters or less';
    }
    return null;
  }

  static String? strongPassword(String? value) {
    final basic = loginPassword(value);
    if (basic != null) return basic;
    final safeValue = value ?? '';
    if (!RegExp(r'[A-Za-z]').hasMatch(safeValue) || !RegExp(r'\d').hasMatch(safeValue)) {
      return 'Password must contain letters and numbers';
    }
    return null;
  }

  static String? amount(String? value, {double min = 1, double max = 10000}) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid amount';
    if (parsed < min) return 'Amount must be at least AED ${min.toStringAsFixed(0)}';
    if (parsed > max) return 'Amount must be AED ${max.toStringAsFixed(0)} or less';
    return null;
  }

  static String? beneficiaryNickname(String? value, {required int maxLength}) {
    if (value == null || value.trim().isEmpty) {
      return 'Nickname is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 4) {
      return 'Nickname must be at least 4 characters';
    }
    if (trimmed.length > maxLength) {
      return 'Nickname must be $maxLength characters or less';
    }
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9\s_-]*$').hasMatch(trimmed)) {
      return 'Nickname contains invalid characters';
    }
    return null;
  }

  static String digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  static bool luhnValid(String cardNumberDigits) {
    var sum = 0;
    var alternate = false;
    for (var i = cardNumberDigits.length - 1; i >= 0; i--) {
      var n = int.parse(cardNumberDigits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  static String? cardholderName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Cardholder name is required';
    final trimmed = value.trim();
    final lettersOnly = trimmed.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (lettersOnly.length < 4) return 'Cardholder name must be at least 4 letters';
    if (trimmed.length > 20) return 'Cardholder name must be 20 characters or less';
    if (!RegExp(r'^[A-Za-z ]+$').hasMatch(trimmed)) {
      return 'Cardholder name must contain only letters';
    }
    return null;
  }

  static String? cardNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Card number is required';
    final digits = digitsOnly(value);
    if (digits.length != 16) return 'Card number must be exactly 16 digits';
    return null;
  }

  static String? expiryMmYy(String? value) {
    if (value == null || value.trim().isEmpty) return 'Expiry date is required';
    final match = RegExp(r'^(0[1-9]|1[0-2])\/(\d{2})$').firstMatch(value.trim());
    if (match == null) return 'Use MM/YY format';
    final month = int.parse(match.group(1)!);
    final year = int.parse(match.group(2)!);
    final now = DateTime.now();
    final currentYear = now.year % 100;
    final currentMonth = now.month;
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Card is expired';
    }
    return null;
  }

  static String? cvv(String? value) {
    if (value == null || value.trim().isEmpty) return 'CVV is required';
    final digits = digitsOnly(value);
    if (digits.length != 3) return 'CVV must be exactly 3 digits';
    return null;
  }

  static String? selfieUrl(String? value) {
    if (value == null || value.trim().isEmpty) return 'Selfie URL is required';
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.isAbsolute || !(uri.scheme == 'https' || uri.scheme == 'http')) {
      return 'Enter a valid URL';
    }
    return null;
  }

  static String? optionalImageUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.isAbsolute || !(uri.scheme == 'https' || uri.scheme == 'http')) {
      return 'Enter a valid image URL';
    }
    return null;
  }
}
