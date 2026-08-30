import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_split/models/enums.dart';
import 'package:smart_split/providers/expense_provider.dart';
import 'package:smart_split/providers/group_provider.dart';
import 'package:smart_split/screens/expense_details_modal.dart';

class ActivityTab extends StatelessWidget {
  const ActivityTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseProvider, GroupProvider>(
      builder: (_, expProvider, groupProvider, __) {
        var sorted = List.of(expProvider.expenses)
          ..sort((a, b) => b.date.compareTo(a.date));

        if (sorted.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No expenses yet'),
            ),
          );
        }

        return ListView.builder(
          itemCount: sorted.length,
          itemBuilder: (_, i) {
            var exp = sorted[i];
            
            String paidByName = groupProvider.members
                .where((m) => exp.paidBy.containsKey(m.id))
                .map((m) => m.name)
                .firstOrNull ?? 'Unknown';

            return Dismissible(
  key: Key(exp.id),
  direction: DismissDirection.endToStart,
  background: Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 16),
    child: Icon(Icons.delete, color: Colors.white),
  ),
  onDismissed: (_) {
    expProvider.deleteExpense(exp.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Expense deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => expProvider.addExpense(exp),
        ),
      ),
    );
  },
  child: GestureDetector(  // ← ADD THIS
    onTap: () {
      showDialog(
        context: context,
        builder: (_) => ExpenseDetailsModal(expense: exp),
      );
    },
    child: Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Text(
          exp.category.emoji,
          style: TextStyle(fontSize: 28),
        ),
        title: Text(exp.description),
        subtitle: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'By $paidByName',
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[300]
            : Colors.grey[700],
      ),
    ),
    Text(
      DateFormat('MMM d, yyyy – HH:mm').format(exp.date),
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[400]
            : Colors.grey[600],
      ),
    ),
  ],
),
        trailing: Text(
          '₹${exp.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    ),
  ),
);
          },
        );
      },
    );
  }
}