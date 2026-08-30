import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_split/providers/expense_provider.dart';
import 'package:smart_split/providers/group_provider.dart';
import 'package:smart_split/screens/add_expense_screen.dart';
import 'package:smart_split/screens/manage_group_screen.dart';
import 'package:smart_split/screens/analytics_screen.dart';
import 'package:smart_split/screens/settings_screen.dart';
import 'package:smart_split/widgets/dashboard_tab.dart';
import 'package:smart_split/widgets/activity_tab.dart';
import 'package:smart_split/widgets/settlement_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    // FIX 1: PERSISTENCE - Proper initialization with await
    Future.microtask(() async {
      try {
        await context.read<GroupProvider>().initialize();
        await context.read<ExpenseProvider>().initialize();
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        print('Error initializing: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 💡 Added your name structure right here beneath the app title!
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'SmartSplit',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Developed by: Jaagriti', // 👤 Your name added here
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AnalyticsScreen()),
            ),
            icon: Icon(Icons.bar_chart),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            ),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Consumer2<GroupProvider, ExpenseProvider>(
        builder: (_, groupProvider, expProvider, __) {
          if (groupProvider.isLoading || expProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return IndexedStack(
            index: _selectedTab,
            children: [
              DashboardTab(),
              ActivityTab(),
              SettlementTab(),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (i) => setState(() => _selectedTab = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.handshake), label: 'Settle'),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'add_member',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ManageGroupScreen()),
            ),
            child: Icon(Icons.person_add),
          ),
          SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add_expense',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AddExpenseScreen()),
            ),
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
