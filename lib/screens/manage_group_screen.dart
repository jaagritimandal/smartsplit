import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_split/providers/group_provider.dart';
import 'package:smart_split/utils/validators.dart';

class ManageGroupScreen extends StatefulWidget {
  const ManageGroupScreen({Key? key}) : super(key: key);

  @override
  State<ManageGroupScreen> createState() => _ManageGroupScreenState();
}

class _ManageGroupScreenState extends State<ManageGroupScreen> {
  late TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addMember(GroupProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    
    await provider.addMember(_nameController.text);
    _nameController.clear();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member added!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Group')),
      body: Consumer<GroupProvider>(
        builder: (_, provider, __) {
          return Column(
            children: [
              // Add member form
              Padding(
  padding: EdgeInsets.all(16),
  child: Card(
    elevation: 2,
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Member Name',
                  border: OutlineInputBorder(),
                  hintText: 'Enter name',
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.white,
                  filled: true,
                ),
                              validator: ExpenseValidator.validateMemberName,
                            ),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => _addMember(provider),
                            icon: Icon(Icons.add),
                            label: Text('Add'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Members list
              Expanded(
                child: provider.members.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No members yet'),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.members.length,
                        itemBuilder: (_, i) {
                          var member = provider.members[i];
                          return Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              title: Text(
                                member.name,
                                style: TextStyle(
                                  color: member.isActive
                                      ? Colors.black
                                      : Colors.grey,
                                  decoration: member.isActive
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                              subtitle: member.isActive
                                  ? null
                                  : Text(
                                      'Inactive',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: Text(member.isActive
                                        ? 'Deactivate'
                                        : 'Reactivate'),
                                    onTap: () {
                                      if (member.isActive) {
                                        provider.deactivateMember(member.id);
                                      } else {
                                        provider.reactivateMember(member.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}