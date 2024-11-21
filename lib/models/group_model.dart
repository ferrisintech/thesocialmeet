class GroupList {
  final String name;

  GroupList({required this.name});

  // Convert a Firestore document to a GroupList object
  factory GroupList.fromMap(Map<String, dynamic> map) {
    return GroupList(
      name: map['name'] ?? 'Unnamed Group', // Ensure that name exists in the map
    );
  }

  // Optionally, you can create a method to convert it to a map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}
