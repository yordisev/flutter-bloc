// models/guest.dart
class Guest {
  final String id;
  final String name;
  final bool isInvited;

  Guest({
    required this.id,
    required this.name,
    this.isInvited = false,
  });

  Guest copyWith({
    String? id,
    String? name,
    bool? isInvited,
  }) {
    return Guest(
      id: id ?? this.id,
      name: name ?? this.name,
      isInvited: isInvited ?? this.isInvited,
    );
  }

  @override
  String toString() => 'Guest(id: $id, name: $name, isInvited: $isInvited)';
}
