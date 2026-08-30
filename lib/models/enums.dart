enum SplitType { equal, exact, percentage }

enum ExpenseCategory {
  food,
  transport,
  stay,
  entertainment,
  subscription,
  academic,
  travel,
  custom,
}

extension CategoryEmoji on ExpenseCategory {
  String get emoji {
    const map = {
      ExpenseCategory.food: '🍔',
      ExpenseCategory.transport: '🚕',
      ExpenseCategory.stay: '🏠',
      ExpenseCategory.entertainment: '🎬',
      ExpenseCategory.subscription: '📱',
      ExpenseCategory.academic: '📚',
      ExpenseCategory.travel: '✈️',
      ExpenseCategory.custom: '✨',
    };
    return map[this] ?? '📝';
  }

  String get label {
    const map = {
      ExpenseCategory.food: 'Food & Dining',
      ExpenseCategory.transport: 'Transport',
      ExpenseCategory.stay: 'Stay & Utilities',
      ExpenseCategory.entertainment: 'Entertainment',
      ExpenseCategory.subscription: 'Subscriptions',
      ExpenseCategory.academic: 'Academic',
      ExpenseCategory.travel: 'Trips & Travel',
      ExpenseCategory.custom: 'Custom',
    };
    return map[this] ?? 'Other';
  }
}

extension SplitTypeLabel on SplitType {
  String get label {
    const map = {
      SplitType.equal: 'Equal Split',
      SplitType.exact: 'Exact Amounts',
      SplitType.percentage: 'Percentage',
    };
    return map[this] ?? '';
  }
}