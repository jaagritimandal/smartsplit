import 'package:flutter/material.dart';
import 'package:smart_split/models/group_member.dart';
import 'package:smart_split/services/hive_service.dart';
import 'package:uuid/uuid.dart';

class GroupProvider extends ChangeNotifier {
  List<GroupMember> members = [];
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    members = HiveService.loadMembers();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMember(String name) async {
    final member = GroupMember(
      id: const Uuid().v4(),
      name: name,
      isActive: true,
    );
    members.add(member);
    await HiveService.saveMember(member);
    notifyListeners();
  }

  Future<void> deactivateMember(String id) async {
    int index = members.indexWhere((m) => m.id == id);
    if (index >= 0) {
      members[index] = GroupMember(
        id: members[index].id,
        name: members[index].name,
        isActive: false,
      );
      await HiveService.saveMember(members[index]);
      notifyListeners();
    }
  }

  Future<void> reactivateMember(String id) async {
    int index = members.indexWhere((m) => m.id == id);
    if (index >= 0) {
      members[index] = GroupMember(
        id: members[index].id,
        name: members[index].name,
        isActive: true,
      );
      await HiveService.saveMember(members[index]);
      notifyListeners();
    }
  }

  GroupMember? getMemberById(String id) {
    try {
      return members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  List<GroupMember> getActiveMembers() {
    return members.where((m) => m.isActive).toList();
  }

  Future<void> clearAll() async {
    members.clear();
    await HiveService.clearAllMembers();
    notifyListeners();
  }
}