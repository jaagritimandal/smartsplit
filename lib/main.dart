import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_split/services/hive_service.dart';
import 'package:smart_split/providers/expense_provider.dart';
import 'package:smart_split/providers/group_provider.dart';
import 'package:smart_split/providers/theme_provider.dart';
import 'package:smart_split/providers/currency_provider.dart';
import 'package:smart_split/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Hive.initFlutter();
    await HiveService.initHive();
    print('✅ Hive initialized successfully');
  } catch (e) {
    print('❌ Hive init error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Using cascade operators to forcefully guarantee initialization routines trigger on start
        ChangeNotifierProvider(create: (_) => GroupProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) {
          return MaterialApp(
            title: 'SmartSplit',
            theme: themeProvider.getTheme(),
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
