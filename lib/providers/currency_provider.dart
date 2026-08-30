import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_split/models/currency.dart';

class CurrencyProvider extends ChangeNotifier {
  String _currencyCode = 'INR';

  String get currencyCode => _currencyCode;
  Currency get currentCurrency => CurrencyManager.getByCode(_currencyCode);

  CurrencyProvider() {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _currencyCode = prefs.getString('currencyCode') ?? 'INR';
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    _currencyCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currencyCode', code);
    notifyListeners();
  }

  String formatAmount(double amount) {
    return '${currentCurrency.symbol}${amount.toStringAsFixed(2)}';
  }
}