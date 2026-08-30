import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_split/providers/expense_provider.dart';
import 'package:smart_split/providers/group_provider.dart';
import 'package:smart_split/services/settlement_calculator.dart';

class SettlementTab extends StatelessWidget {
  const SettlementTab({Key? key}) : super(key: key);

  String _getMemberName(String id, GroupProvider groupProvider) {
    try {
      return groupProvider.members.firstWhere((m) => m.id == id).name;
    } catch (_) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseProvider, GroupProvider>(
      builder: (_, expProvider, groupProvider, __) {
        var balances = expProvider.getAllBalances(
          groupProvider.members.map((m) => m.id).toList(),
        );

        var settlements = SettlementCalculator.simplifyDebts(balances);

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              if (settlements.isEmpty)
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 48),
                        SizedBox(height: 12),
                        Text(
                          'All Settled! ✅',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settlement Plan',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    ...settlements.map((settlement) {
                      String fromName =
                          _getMemberName(settlement.from, groupProvider);
                      String toName =
                          _getMemberName(settlement.to, groupProvider);

                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$fromName → $toName',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Payment',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '₹${settlement.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}