import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_split/models/expense.dart';
import 'package:smart_split/models/enums.dart';
import 'package:smart_split/providers/expense_provider.dart';
import 'package:smart_split/providers/group_provider.dart';
import 'package:smart_split/utils/validators.dart';
import 'package:smart_split/utils/split_calculator.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expenseToEdit;

  const AddExpenseScreen({Key? key, this.expenseToEdit}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descController, _amountController;
  late TextEditingController _customCategoryController;

  ExpenseCategory _category = ExpenseCategory.food;
  String? _customCategoryEmoji;
  SplitType _splitType = SplitType.equal;
  Set<String> _selectedMembers = {};
  Set<String> _selectedPaidBy = {};
  Map<String, TextEditingController> _paidByControllers = {};
  Map<String, TextEditingController> _exactControllers = {};
  Map<String, TextEditingController> _percentageControllers = {};

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.expenseToEdit?.description ?? '');
    _amountController =
        TextEditingController(text: widget.expenseToEdit?.amount.toString() ?? '');
    _customCategoryController = TextEditingController();

    if (widget.expenseToEdit != null) {
      _category = widget.expenseToEdit!.category;
      _customCategoryController.text =
          widget.expenseToEdit!.customCategoryName ?? '';
      _customCategoryEmoji = widget.expenseToEdit!.customCategoryEmoji;
      _splitType = widget.expenseToEdit!.type;
      _selectedMembers =
          widget.expenseToEdit!.splitAmong.keys.toSet();
      // FIX 5: populate multi-payer selection from existing expense
      _selectedPaidBy = widget.expenseToEdit!.paidBy.keys.toSet();
    } else {
      // FIX 4: Default: select all members for new expenses
      Future.microtask(() {
        final groupProvider = context.read<GroupProvider>();
        if (mounted) {
          setState(() {
            _selectedMembers = groupProvider.getActiveMembers().map((m) => m.id).toSet();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    _customCategoryController.dispose();
    _paidByControllers.values.forEach((c) => c.dispose());
    _exactControllers.values.forEach((c) => c.dispose());
    _percentageControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select at least one member')),
      );
      return;
    }
    // FIX 5: validate against the multi-payer selection, not the unused single-payer field
    if (_selectedPaidBy.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select who paid')),
      );
      return;
    }

    double amount = double.parse(_amountController.text);
    Map<String, double> split = {};
    Map<String, double> paidBy = {};

    try {
      // Calculate who paid FIRST - only from selected payers
      _selectedPaidBy.forEach((id) {
        double paid = double.tryParse(_paidByControllers[id]?.text ?? '') ?? 0;
        if (paid > 0) {
          paidBy[id] = paid;
        }
      });

      // FIX 5: fall back to the full amount only when there's exactly one payer
      // and they didn't type an amount in; otherwise ask for explicit amounts
      // instead of crashing on a null single-payer id.
      if (paidBy.isEmpty) {
        if (_selectedPaidBy.length == 1) {
          paidBy[_selectedPaidBy.first] = amount;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Enter how much each person paid')),
          );
          return;
        }
      }

      // FIX 2: VALIDATE MULTI-PAYER TOTALS
      double totalPaid = paidBy.values.fold(0, (sum, v) => sum + v);
      if ((totalPaid - amount).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Who paid total (${totalPaid.toStringAsFixed(2)}) must equal amount (${amount.toStringAsFixed(2)})'),
          ),
        );
        return;
      }

      // Calculate splits
      if (_splitType == SplitType.equal) {
        split = SplitCalculator.calculateEqualSplit(
          amount,
          _selectedMembers.toList(),
        );
      } else if (_splitType == SplitType.exact) {
        Map<String, double> exactAmounts = {};
        _exactControllers.forEach((id, ctrl) {
          if (_selectedMembers.contains(id)) {
            exactAmounts[id] = double.tryParse(ctrl.text) ?? 0;
          }
        });
        split = SplitCalculator.validateExactSplit(exactAmounts, amount);
      } else if (_splitType == SplitType.percentage) {
        Map<String, double> percentages = {};
        _percentageControllers.forEach((id, ctrl) {
          if (_selectedMembers.contains(id)) {
            percentages[id] = double.tryParse(ctrl.text) ?? 0;
          }
        });
        split = SplitCalculator.calculatePercentageSplit(amount, percentages);
      }

      var expense = Expense(
        id: widget.expenseToEdit?.id ?? const Uuid().v4(),
        description: _descController.text,
        category: _category,
        customCategoryName:
            _category == ExpenseCategory.custom ? _customCategoryController.text : null,
        customCategoryEmoji: null,
        amount: amount,
        date: widget.expenseToEdit?.date ?? DateTime.now(),
        editedAt: widget.expenseToEdit != null ? DateTime.now() : null,
        paidBy: paidBy,
        splitAmong: split,
        type: _splitType,
      );

      context.read<ExpenseProvider>().addExpense(expense);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.expenseToEdit != null ? 'Expense updated' : 'Expense added'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expenseToEdit != null ? 'Edit Expense' : 'Add Expense'),
      ),
      body: Consumer<GroupProvider>(
        builder: (_, groupProvider, __) {
          for (var m in groupProvider.getActiveMembers()) {
            // FIX 5: prefill the paid-amount controller from the existing expense
            // the first time it's created, so editing shows previous amounts.
            _paidByControllers.putIfAbsent(m.id, () {
              final ctrl = TextEditingController();
              final existingPaid = widget.expenseToEdit?.paidBy[m.id];
              if (existingPaid != null) {
                ctrl.text = existingPaid.toString();
              }
              return ctrl;
            });
            _exactControllers.putIfAbsent(m.id, () => TextEditingController());
            _percentageControllers.putIfAbsent(m.id, () => TextEditingController());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: ExpenseValidator.validateDescription,
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount (max ₹1,000,000)',
                      border: OutlineInputBorder(),
                      prefixText: '₹ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Amount required';
                      final parsed = double.tryParse(val);
                      if (parsed == null) return 'Invalid number';
                      if (parsed <= 0) return 'Amount must be > 0';
                      if (parsed > 1000000) return 'Max amount: ₹1,000,000';
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: 16),

                  DropdownButtonFormField<ExpenseCategory>(
                    initialValue: _category,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: ExpenseCategory.values.map((cat) {
                      if (cat == ExpenseCategory.custom) {
  return DropdownMenuItem(
    value: cat,
    child: Text('✨ Custom Category'),
  );
}
                      return DropdownMenuItem(
                        value: cat,
                        child: Text('${cat.emoji} ${cat.label}'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _category = val ?? _category),
                  ),
                  SizedBox(height: 16),

                  if (_category == ExpenseCategory.custom)
                    Column(
                      children: [
                        TextFormField(
                          controller: _customCategoryController,
                          decoration: InputDecoration(
                            labelText: 'Category name (e.g., 🎸 Music)',
                            border: OutlineInputBorder(),
                            hintText: 'Type emoji + name',
                          ),
                          validator: (val) {
                            if (val?.isEmpty ?? true) return 'Name required';
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                      ],
                    ),

                  // Who paid? - MULTI-SELECT
                  Text('Who paid?', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: groupProvider.getActiveMembers().map((m) {
                          bool isSelected = _selectedPaidBy.contains(m.id);
                          return CheckboxListTile(
                            title: Text(m.name),
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedPaidBy.add(m.id);
                                } else {
                                  _selectedPaidBy.remove(m.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // How much did each pay? - ONLY SELECTED
                  // How much did each pay? - ONLY IF MULTIPLE SELECTED
if (_selectedPaidBy.length > 1)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('How much did each pay?',
          style: Theme.of(context).textTheme.titleMedium),
      SizedBox(height: 8),
      ...groupProvider.getActiveMembers()
          .where((m) => _selectedPaidBy.contains(m.id))
          .map((m) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: TextFormField(
                                  controller: _paidByControllers[m.id],
                                  decoration: InputDecoration(
                                    labelText: '${m.name} paid (₹)',
                                    border: OutlineInputBorder(),
                                    prefixText: '₹ ',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                ),
                              );
                            }).toList(),
                        SizedBox(height: 20),
                      ],
                    ),

                  // FIX 4: DEFAULT ALL + MUTUALLY EXCLUSIVE
                  // SPLIT AMONG - FIXED LOGIC
                  Text('Split among', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // "All" option
                          CheckboxListTile(
                            title: Text('All members'),
                            value: _selectedMembers.length == groupProvider.getActiveMembers().length,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedMembers = groupProvider.getActiveMembers().map((m) => m.id).toSet();
                                } else {
                                  _selectedMembers.clear();
                                }
                              });
                            },
                          ),
                          Divider(),
                          // Individual members - ALWAYS ENABLED
                          ...groupProvider.getActiveMembers().map((m) {
                            bool isMemberSelected = _selectedMembers.contains(m.id);

                            return CheckboxListTile(
                              title: Text(m.name),
                              value: isMemberSelected,
                              enabled: true,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedMembers.add(m.id);
                                  } else {
                                    _selectedMembers.remove(m.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  SegmentedButton<SplitType>(
                    segments: [
                      ButtonSegment(label: Text('Equal'), value: SplitType.equal),
                      ButtonSegment(label: Text('Exact'), value: SplitType.exact),
                      ButtonSegment(label: Text('%'), value: SplitType.percentage),
                    ],
                    selected: {_splitType},
                    onSelectionChanged: (selected) {
                      setState(() => _splitType = selected.first);
                    },
                  ),
                  SizedBox(height: 20),

                  if (_splitType == SplitType.exact)
                    _buildExactSplitUI(groupProvider),
                  if (_splitType == SplitType.percentage)
                    _buildPercentageSplitUI(groupProvider),

                  SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _submitForm(context),
                      icon: Icon(Icons.check),
                      label: Text(widget.expenseToEdit != null ? 'Update' : 'Add'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExactSplitUI(GroupProvider groupProvider) {
    double total = double.tryParse(_amountController.text) ?? 0;
    double allocated = _selectedMembers.fold(0, (sum, id) {
      return sum + (double.tryParse(_exactControllers[id]?.text ?? '') ?? 0);
    });
    double remaining = total - allocated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Remaining:'),
              Text(
                '₹${remaining.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: remaining.abs() < 0.01 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        ...groupProvider.getActiveMembers()
            .where((m) => _selectedMembers.contains(m.id))
            .map((m) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: TextFormField(
              controller: _exactControllers[m.id],
              decoration: InputDecoration(
                labelText: '${m.name} owes',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPercentageSplitUI(GroupProvider groupProvider) {
    double totalPct = _selectedMembers.fold(0, (sum, id) {
      return sum + (double.tryParse(_percentageControllers[id]?.text ?? '') ?? 0);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:'),
              Text(
                '${totalPct.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: (totalPct - 100).abs() < 0.05 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        ...groupProvider.getActiveMembers()
            .where((m) => _selectedMembers.contains(m.id))
            .map((m) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: TextFormField(
              controller: _percentageControllers[m.id],
              decoration: InputDecoration(
                labelText: '${m.name} (%)',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          );
        }).toList(),
      ],
    );
  }
}