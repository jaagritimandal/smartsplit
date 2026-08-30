class GroupMember {
  String id;
  String name;
  bool isActive; // 💡 Fixed: Added to clear your 'isActive' UI errors

  GroupMember({
    required this.id,
    required this.name,
    this.isActive = true, // Defaults to true when a member is created
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'isActive': isActive,
      };

  factory GroupMember.fromMap(Map<String, dynamic> map) => GroupMember(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        isActive: map['isActive'] ?? true,
      );
}
