class DebtSettlement {
  final String from;
  final String to;
  final double amount;

  DebtSettlement({
    required this.from,
    required this.to,
    required this.amount,
  });
}

class SettlementCalculator {
  /// Greedy algorithm: match largest debtor with largest creditor
  static List<DebtSettlement> simplifyDebts(
    Map<String, double> balances,
  ) {
    List<DebtSettlement> settlements = [];
    Map<String, double> balance = Map.from(balances);

    // Remove zero balances
    balance.removeWhere((_, v) => v.abs() < 0.01);

    while (true) {
      // Find max debtor (most negative) and max creditor (most positive)
      String? maxDebtor, maxCreditor;
      double minBal = 0, maxBal = 0;

      balance.forEach((person, bal) {
        if (bal < minBal) {
          minBal = bal;
          maxDebtor = person;
        }
        if (bal > maxBal) {
          maxBal = bal;
          maxCreditor = person;
        }
      });

      if (maxDebtor == null || maxCreditor == null) break;
      if (minBal >= 0 || maxBal <= 0) break; // All settled

      // Settle as much as possible
      double amount = minBal.abs().clamp(0, maxBal);
      amount = double.parse(amount.toStringAsFixed(2)); // Round to 2 decimals

      settlements.add(
        DebtSettlement(
          from: maxDebtor!,
          to: maxCreditor!,
          amount: amount,
        ),
      );

      balance[maxDebtor!] = double.parse((balance[maxDebtor]! + amount).toStringAsFixed(2));
      balance[maxCreditor!] = double.parse((balance[maxCreditor]! - amount).toStringAsFixed(2));

      // Clean up near-zero values
      balance.removeWhere((_, v) => v.abs() < 0.001);
    }

    return settlements;
  }
}