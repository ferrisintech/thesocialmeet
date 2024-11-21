class GroupChat {
  final String id;
  final String groupName;
  final String lastMessage;
  final List<String> members; // List of user IDs

  GroupChat({
    required this.id,
    required this.groupName,
    required this.lastMessage,
    required this.members,
  });

  // Factory constructor to create a GroupChat object from Firestore data
  factory GroupChat.fromFirestore(String id, Map<String, dynamic> data) {
    return GroupChat(
      id: id,
      groupName: data['groupName'] as String,
      lastMessage: data['lastMessage'] as String,
      members: List<String>.from(data['members']),
    );
  }

  // Method to convert GroupChat object back to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'groupName': groupName,
      'lastMessage': lastMessage,
      'members': members,
    };
  }
}


class PrivateChat {
  final String id;
  final String user1Id; // ID of the first user
  final String user2Id; // ID of the second user
  final String lastMessage;

  PrivateChat({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.lastMessage,
  });

  // Factory constructor to create a PrivateChat object from Firestore data
  factory PrivateChat.fromFirestore(String id, Map<String, dynamic> data) {
    return PrivateChat(
      id: id,
      user1Id: data['user1'] as String,
      user2Id: data['user2'] as String,
      lastMessage: data['lastMessage'] as String,
    );
  }

  // Method to convert PrivateChat object back to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'user1': user1Id,
      'user2': user2Id,
      'lastMessage': lastMessage,
    };
  }
}
