import 'dart:convert';
import 'dart:html' as html; // 💡 Routes data directly to Chrome's native storage
import 'package:smart_split/models/expense.dart';
import 'package:smart_split/models/group_member.dart';

class HiveService {
  static const String expenseBoxName = 'smartsplit_expenses_browser';
  static const String membersBoxName = 'smartsplit_members_browser';

  // Keeping method signature identical so main.dart remains perfectly valid
  static Future<void> initHive() async {
    print('🌐 Browser Native Web-Storage engine initialized!');
  }

  // Expenses
  static Future<void> saveExpense(Expense exp) async {
    try {
      // 1. Fetch current list array from browser memory
      final String? existingData = html.window.localStorage[expenseBoxName];
      List<dynamic> currentList = [];
      
      if (existingData != null) {
        currentList = jsonDecode(existingData) as List<dynamic>;
      }

      // 2. Remove entry if it already exists (handling update/edit states)
      currentList.removeWhere((item) => item['id'] == exp.id);
      
      // 3. Add updated item
      currentList.add(exp.toMap());
      
      // 4. Force browser to lock the string map onto physical disk
      html.window.localStorage[expenseBoxName] = jsonEncode(currentList);
      print('✅ Expense safely committed to Chrome Storage: ${exp.id}');
    } catch (e) {
      print('❌ Browser write failure: $e');
    }
  }

  static Future<void> deleteExpense(String id) async {
    try {
      final String? existingData = html.window.localStorage[expenseBoxName];
      if (existingData != null) {
        List<dynamic> currentList = jsonDecode(existingData) as List<dynamic>;
        currentList.removeWhere((item) => item['id'] == id);
        html.window.localStorage[expenseBoxName] = jsonEncode(currentList);
      }
    } catch (e) {
      print('❌ Browser delete failure: $e');
    }
  }

  static List<Expense> loadExpenses() {
    try {
      final String? existingData = html.window.localStorage[expenseBoxName];
      if (existingData == null) return [];

      List<dynamic> rawList = jsonDecode(existingData) as List<dynamic>;
      return rawList.map((item) {
        final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item as Map);
        return Expense.fromMap(itemMap);
      }).toList();
    } catch (e) {
      print('❌ Browser reading failure: $e');
      return [];
    }
  }

  static Future<void> clearAllExpenses() async {
    html.window.localStorage.remove(expenseBoxName);
  }

  // Members
  static Future<void> saveMember(GroupMember member) async {
    try {
      final String? existingData = html.window.localStorage[membersBoxName];
      List<dynamic> currentList = [];
      
      if (existingData != null) {
        currentList = jsonDecode(existingData) as List<dynamic>;
      }

      currentList.removeWhere((item) => item['id'] == member.id);
      currentList.add(member.toMap());
      
      html.window.localStorage[membersBoxName] = jsonEncode(currentList);
      print('✅ Member safely committed to Chrome Storage: ${member.name}');
    } catch (e) {
      print('❌ Browser member write failure: $e');
    }
  }

  static Future<void> deleteMember(String id) async {
    try {
      final String? existingData = html.window.localStorage[membersBoxName];
      if (existingData != null) {
        List<dynamic> currentList = jsonDecode(existingData) as List<dynamic>;
        currentList.removeWhere((item) => item['id'] == id);
        html.window.localStorage[membersBoxName] = jsonEncode(currentList);
      }
    } catch (e) {
      print('❌ Browser member delete failure: $e');
    }
  }

  static List<GroupMember> loadMembers() {
    try {
      final String? existingData = html.window.localStorage[membersBoxName];
      if (existingData == null) return [];

      List<dynamic> rawList = jsonDecode(existingData) as List<dynamic>;
      return rawList.map((item) {
        final Map<String, dynamic> itemMap = Map<String, dynamic>.from(item as Map);
        return GroupMember.fromMap(itemMap);
      }).toList();
    } catch (e) {
      print('❌ Browser reading failure: $e');
      return [];
    }
  }

  static Future<void> clearAllMembers() async {
    html.window.localStorage.remove(membersBoxName);
  }
}
