import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_split/providers/expense_provider.dart';
import 'package:smart_split/providers/currency_provider.dart';
import 'package:smart_split/models/enums.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Analytics')),
      body: Consumer2<ExpenseProvider, CurrencyProvider>(
        builder: (_, provider, currencyProvider, __) {
          var monthly = provider.getMonthlySpending();
          var byCategory = provider.getCategorySpending();

          if (provider.expenses.isEmpty) {
            return Center(child: Text('No expense data yet'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Spending
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Spending',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 8),
                        Text(
                          currencyProvider.formatAmount(provider.getTotalSpent()),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Pie Chart
                Text(
                  'Spending by Category',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: byCategory.entries.map((e) {
                        double pct = (e.value / provider.getTotalSpent() * 100);
                        return PieChartSectionData(
                          value: e.value,
                          title: '${pct.toStringAsFixed(1)}%',
                          radius: 100,
                          color: _getCategoryColor(e.key),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Category Breakdown (List)
                Text(
                  'Category Breakdown',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 12),
                ...byCategory.entries.map((e) {
                  double pct = (e.value / provider.getTotalSpent() * 100);
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${e.key.emoji} ${e.key.label}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                currencyProvider.formatAmount(e.value),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct / 100,
                              minHeight: 8,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${pct.toStringAsFixed(1)}% of total',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(ExpenseCategory cat) {
    const colors = {
      ExpenseCategory.food: Color(0xFFFF6B6B),
      ExpenseCategory.transport: Color(0xFF4ECDC4),
      ExpenseCategory.stay: Color(0xFF45B7D1),
      ExpenseCategory.entertainment: Color(0xFFFFA07A),
      ExpenseCategory.subscription: Color(0xFF98D8C8),
      ExpenseCategory.academic: Color(0xFFF7DC6F),
      ExpenseCategory.travel: Color(0xFFBB8FCE),
      ExpenseCategory.custom: Color(0xFF85C1E2),
    };
    return colors[cat] ?? Color(0xFF95E1D3);
  }
}