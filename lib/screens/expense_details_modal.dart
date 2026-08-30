import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_split/models/expense.dart';
import 'package:smart_split/models/group_member.dart';
import 'package:smart_split/providers/expense_provider.dart';
import 'package:smart_split/providers/group_provider.dart';
import 'package:smart_split/providers/currency_provider.dart';
import 'package:smart_split/screens/add_expense_screen.dart';

class ExpenseDetailsModal extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailsModal({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer3<GroupProvider, ExpenseProvider, CurrencyProvider>(
      builder: (_, groupProvider, expProvider, currencyProvider, __) {
        // Get latest expense from provider (handles edits)
        final latestExpense = expProvider.expenses.firstWhere(
          (e) => e.id == expense.id,
          orElse: () => expense,
        );

        return Dialog(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      latestExpense.displayCategory,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Description
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        SizedBox(height: 4),
                        Text(
                          latestExpense.description,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // Amount
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Amount',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        SizedBox(height: 4),
                        Text(
                          currencyProvider.formatAmount(latestExpense.amount),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // Paid By
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Paid By',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        SizedBox(height: 8),
                        ...latestExpense.paidBy.entries.map((e) {
                          String memberName = groupProvider.members
                              .firstWhere((m) => m.id == e.key,
                                  orElse: () => GroupMember(id: '', name: 'Unknown'))
                              .name;
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(memberName),
                                Text(
                                  currencyProvider.formatAmount(e.value),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // Split Details
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Split Among',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        SizedBox(height: 8),
                        ...latestExpense.splitAmong.entries.map((e) {
                          String memberName = groupProvider.members
                              .firstWhere((m) => m.id == e.key,
                                  orElse: () => GroupMember(id: '', name: 'Unknown'))
                              .name;
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(memberName),
                                Text(
                                  currencyProvider.formatAmount(e.value),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // Timestamps
                Card(
                  color: Colors.grey.shade100,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Added: ${DateFormat('MMM d, yyyy – HH:mm').format(latestExpense.date)}',
                          style: TextStyle(fontSize: 12),
                        ),
                        if (latestExpense.editedAt != null)
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              'Edited: ${DateFormat('MMM d, yyyy – HH:mm').format(latestExpense.editedAt!)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddExpenseScreen(expenseToEdit: latestExpense),
                            ),
                          );
                        },
                        icon: Icon(Icons.edit),
                        label: Text('Edit'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          expProvider.deleteExpense(latestExpense.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Expense deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () => expProvider.addExpense(latestExpense),
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.delete),
                        label: Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}