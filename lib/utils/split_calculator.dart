

class SplitCalculator {
  /// Equal split: distribute evenly, remainder goes to first N
  static Map<String, double> calculateEqualSplit(
    double amount,
    List<String> participants,
  ) {
    if (participants.isEmpty) return {};

    int centsTotal = (amount * 100).round();
    int perPerson = centsTotal ~/ participants.length;
    int remainder = centsTotal % participants.length;

    Map<String, double> split = {};
    for (int i = 0; i < participants.length; i++) {
      int cents = perPerson;
      if (i < remainder) cents++;
      split[participants[i]] = cents / 100.0;
    }
    return split;
  }

  /// Exact: caller specifies exact amounts
  static Map<String, double> validateExactSplit(
  Map<String, double> exactAmounts,
  double totalAmount,
) {
  double sum = exactAmounts.values.fold(0, (a, b) => a + b);
  if ((sum - totalAmount).abs() > 0.001) {  // ← CHANGED: 0.01 → 0.001
    throw Exception(
      'Split amounts (${sum.toStringAsFixed(2)}) must equal total (${totalAmount.toStringAsFixed(2)})',
    );
  }
  return exactAmounts;
}

  /// Percentage: caller specifies percentages
  static Map<String, double> calculatePercentageSplit(
    double amount,
    Map<String, double> percentages,
  ) {
    double sum = percentages.values.fold(0, (a, b) => a + b);
    if ((sum - 100).abs() > 0.05) {
      throw Exception(
        'Percentages (${sum.toStringAsFixed(1)}%) must sum to 100%',
      );
    }

    Map<String, double> split = {};
    percentages.forEach((person, pct) {
      double owed = (amount * pct / 100);
      split[person] = double.parse(owed.toStringAsFixed(2));
    });
    return split;
  }
}