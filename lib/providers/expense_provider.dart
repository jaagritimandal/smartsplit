import 'package:flutter/material.dart';
import 'package:smart_split/models/expense.dart';
import 'package:smart_split/models/enums.dart';
import 'package:smart_split/services/hive_service.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> expenses = [];
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  ExpenseProvider() {
    expenses = HiveService.loadExpenses();
    _isLoading = false;
  }

  Future<void> initialize() async {
    expenses = HiveService.loadExpenses();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(Expense exp) async {
    try {
      // 💡 THE ULTIMATE FIX: Create a pristine deep copy of the object on save.
      // This completely severs any shared memory links for nested maps (like paidBy)
      // and forces Flutter to discard its internal widget render caches.
      final clonedExpense = Expense.fromMap(exp.toMap());

      int existingIndex = expenses.indexWhere((e) => e.id == clonedExpense.id);
      if (existingIndex >= 0) {
        expenses[existingIndex] = clonedExpense;
      } else {
        expenses.add(clonedExpense);
      }
      
      // Shatter the array reference to trigger a deep tab redraw
      expenses = List.from(expenses);
      
      // Explicitly await the disk-writing operation before updating state
      await HiveService.saveExpense(clonedExpense);
      notifyListeners();
    } catch (e) {
      print('❌ Error adding/updating expense: $e');
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    expenses.removeWhere((e) => e.id == id);
    await HiveService.deleteExpense(id);
    notifyListeners();
  }

  double getTotalSpent() =>
      expenses.fold(0, (sum, e) => sum + (e.amount as num).toDouble());

  double getNetBalance(String personId) {
    double paid = 0, owed = 0;
    for (var exp in expenses) {
      paid += exp.paidBy[personId] ?? 0;
      owed += exp.splitAmong[personId] ?? 0;
    }
    return paid - owed;
  }

  Map<String, double> getAllBalances(List<String> memberIds) {
    Map<String, double> balances = {};
    for (var id in memberIds) {
      balances[id] = getNetBalance(id);
    }
    return balances;
  }

  List<Expense> getExpensesByCategory(ExpenseCategory category) =>
      expenses.where((e) => e.category == category).toList();

  Map<String, double> getMonthlySpending() {
    Map<String, double> monthly = {};
    for (var exp in expenses) {
      String key =
          '${exp.date.year}-${exp.date.month.toString().padLeft(2, '0')}';
      monthly[key] = (monthly[key] ?? 0) + exp.amount;
    }
    return monthly;
  }

  Map<ExpenseCategory, double> getCategorySpending() {
    Map<ExpenseCategory, double> byCategory = {};
    for (var exp in expenses) {
      byCategory[exp.category] = (byCategory[exp.category] ?? 0) + exp.amount;
    }
    return byCategory;
  }

  Future<void> clearAll() async {
    expenses.clear();
    await HiveService.clearAllExpenses();
    notifyListeners();
  }
}
