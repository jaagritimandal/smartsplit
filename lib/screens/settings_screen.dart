import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_split/providers/theme_provider.dart';
import 'package:smart_split/providers/expense_provider.dart';
import 'package:smart_split/providers/group_provider.dart';
import 'package:smart_split/providers/currency_provider.dart';
import 'package:smart_split/models/currency.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Settings')),
    body: SingleChildScrollView(
      child: Column(
        children: [
          // Currency Selector ← ADD THIS SECTION
          Consumer<CurrencyProvider>(
            builder: (_, currencyProvider, __) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Currency',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 8),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: currencyProvider.currencyCode,
                          items: CurrencyManager.getAllSorted()
                              .map((c) => DropdownMenuItem(
                                    value: c.code,
                                    child: Text('${c.symbol} ${c.name}'),
                                  ))
                              .toList(),
                          onChanged: (code) {
                            if (code != null) {
                              currencyProvider.setCurrency(code);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Dark Mode
          Consumer<ThemeProvider>(
            builder: (_, themeProvider, __) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: Card(
                  child: ListTile(
                    title: Text('Dark Mode'),
                    trailing: Switch(
                      value: themeProvider.isDark,
                      onChanged: (_) => themeProvider.toggleTheme(),
                    ),
                  ),
                ),
              );
            },
          ),

            // About
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campus QuickSplit',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text('v1.0.0'),
                      SizedBox(height: 12),
                      Text(
                        'A frictionless expense tracker for student groups.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            // Danger Zone
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danger Zone',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showClearDialog(context),
                      icon: Icon(Icons.delete),
                      label: Text('Clear All Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Clear All Data?'),
          content: Text(
            'This will delete all members and expenses. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await context.read<ExpenseProvider>().clearAll();
                await context.read<GroupProvider>().clearAll();
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All data cleared')),
                );
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              
            ),
          ],
        );
      },
    );
  }
}