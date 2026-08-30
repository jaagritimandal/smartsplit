import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_split/providers/expense_provider.dart';
import 'package:smart_split/providers/group_provider.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseProvider, GroupProvider>(
      builder: (_, expProvider, groupProvider, __) {
        double total = expProvider.getTotalSpent();
        var balances = expProvider.getAllBalances(
          groupProvider.members.map((m) => m.id).toList(),
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Spent Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Total Spent',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '₹${total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Member Balances
              Text(
                'Member Balances',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 12),
              if (groupProvider.members.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text('No members added yet'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: groupProvider.members.length,
                  itemBuilder: (_, i) {
                    var member = groupProvider.members[i];
                    double balance = balances[member.id] ?? 0;
                    bool isPositive = balance > 0;

                    return Card(
                      child: ListTile(
                        title: Text(member.name),
                        trailing: Text(
                          '${isPositive ? '+' : ''}₹${balance.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}