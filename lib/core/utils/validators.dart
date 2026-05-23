class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  /// Strong password — min 8 chars, uppercase, lowercase, digit, special char
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) {
      return 'At least 8 characters required';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Add at least one uppercase letter (A-Z)';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Add at least one lowercase letter (a-z)';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Add at least one number (0-9)';
    }
    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/]'))) {
      return r'Add at least one special character (!@#$%...)';
    }
    return null;
  }

  /// Returns strength score 0–4 for live password strength indicator
  static int passwordStrength(String value) {
    int score = 0;
    if (value.length >= 8) score++;
    if (value.contains(RegExp(r'[A-Z]'))) score++;
    if (value.contains(RegExp(r'[0-9]'))) score++;
    if (value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/]'))) {
      score++;
    }
    return score;
  }

  static String strengthLabel(int score) {
    switch (score) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return '';
    }
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    return null;
  }

  static String? validateYear(String? value) {
    if (value == null || value.isEmpty) return 'Year is required';
    final year = int.tryParse(value);
    if (year == null || year < 1900 || year > DateTime.now().year + 5) {
      return 'Enter a valid year';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return null;
    final phoneRegex = RegExp(r'^[0-9+\-\s()]{8,20}$');
    if (!phoneRegex.hasMatch(value)) return 'Enter a valid phone number';
    return null;
  }
}
