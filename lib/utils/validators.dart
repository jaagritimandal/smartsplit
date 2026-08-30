class ExpenseValidator {
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) return 'Amount required';
    final parsed = double.tryParse(value);
    if (parsed == null) return 'Enter a valid number';
    if (parsed <= 0) return 'Amount must be > 0';
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) return 'Description required';
    if (value.length < 2) return 'Description too short';
    return null;
  }

  static String? validateMemberName(String? value) {
    if (value == null || value.isEmpty) return 'Name required';
    if (value.length < 1) return 'Name too short';
    return null;
  }

  static String? validateGroupSize(int size) {
    if (size < 2) return 'Need at least 2 members';
    return null;
  }
}