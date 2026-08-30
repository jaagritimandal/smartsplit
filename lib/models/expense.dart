import 'package:smart_split/models/enums.dart';

class Expense {
  final String id;
  final String description;
  final ExpenseCategory category;
  final String? customCategoryName;
  final String? customCategoryEmoji;
  final double amount;
  final DateTime date;
  final DateTime? editedAt;
  final Map<String, double> paidBy;
  final Map<String, double> splitAmong;
  final SplitType type;
  final String notes;

  Expense({
    required this.id,
    required this.description,
    required this.category,
    this.customCategoryName,
    this.customCategoryEmoji,
    required this.amount,
    required this.date,
    this.editedAt,
    required this.paidBy,
    required this.splitAmong,
    this.type = SplitType.equal,
    this.notes = '',
  });

  String get displayCategory {
    if (category == ExpenseCategory.custom && customCategoryName != null) {
      return '${customCategoryEmoji ?? "✨"} ${customCategoryName!}';
    }
    return '${category.emoji} ${category.label}';
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'description': description,
    'category': category.toString(),
    'customCategoryName': customCategoryName,
    'customCategoryEmoji': customCategoryEmoji,
    'amount': amount,
    'date': date.toIso8601String(),
    'editedAt': editedAt?.toIso8601String(),
    'paidBy': paidBy,
    'splitAmong': splitAmong,
    'type': type.toString(),
    'notes': notes,
  };

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      category: _parseCategory(map['category']),
      customCategoryName: map['customCategoryName'],
      customCategoryEmoji: map['customCategoryEmoji'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      editedAt: map['editedAt'] != null ? DateTime.parse(map['editedAt']) : null,
      paidBy: Map<String, double>.from(
        (map['paidBy'] as Map).cast<String, double>(),
      ),
      splitAmong: Map<String, double>.from(
        (map['splitAmong'] as Map).cast<String, double>(),
      ),
      type: _parseSplitType(map['type']),
      notes: map['notes'] ?? '',
    );
  }

  static ExpenseCategory _parseCategory(String cat) {
    for (var c in ExpenseCategory.values) {
      if (c.toString() == cat) return c;
    }
    return ExpenseCategory.custom;
  }

  static SplitType _parseSplitType(String type) {
    for (var t in SplitType.values) {
      if (t.toString() == type) return t;
    }
    return SplitType.equal;
  }
}