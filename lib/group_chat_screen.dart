import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // For formatting timestamps

class GroupChat extends StatefulWidget {
  final String groupId;

  const GroupChat({super.key, required this.groupId});

  @override
  State<GroupChat> createState() => GroupChatState();
}

class GroupChatState extends State<GroupChat> {
  final TextEditingController _messageController = TextEditingController();
  final String currentUserId =
      FirebaseAuth.instance.currentUser?.uid ?? "unknown_user";

  @override
  Widget build(BuildContext context) {
//    final localeProvider = Provider.of<LanguageChangeProvider>(context);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo[800],
          title: Text(widget.groupId,
              style: const TextStyle(fontSize: 20, color: Colors.white)),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          color: Colors.indigo[800],
          child: Column(
            children: [
              // Chat messages list
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('groups')
                      .doc(widget.groupId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final messages = snapshot.data!.docs;
                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isCurrentUser =
                            message['senderId'] == currentUserId;

                        // Determine if we should display a timestamp
                        bool showTimestamp = false;
                        if (index == messages.length - 1) {
                        // Show timestamp for the last message in the list
                        showTimestamp = true;
                        } else {
                        final currentMessageTime =
                        message['timestamp'] as Timestamp?;
                        final previousMessageTime = messages[index + 1]
                        ['timestamp'] as Timestamp?;

                        // Display timestamp if the gap between two messages is significant
                        if (currentMessageTime != null &&
                            previousMessageTime != null) {
                          final currentTime = currentMessageTime.toDate();
                          final previousTime = previousMessageTime.toDate();
                          showTimestamp = _shouldShowTimestamp(
                              currentTime, previousTime);
                        }
                        }

                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                            if (showTimestamp)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            _formatTimestamp(
                                message['timestamp'] as Timestamp?),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                              const SizedBox(height: 12),

                        Align(
                          alignment: isCurrentUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            margin: const EdgeInsets.only(right: 12, left: 12, bottom: 10),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? Colors.indigo[400]
                                  : Colors.orange[800],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(10),
                                topRight: const Radius.circular(10),
                                bottomLeft: isCurrentUser
                                    ? const Radius.circular(10)
                                    : Radius.zero,
                                bottomRight: isCurrentUser
                                    ? Radius.zero
                                    : const Radius.circular(10),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isCurrentUser)
                                  Text(
                                    message['senderName'] ?? "Unknown",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                Text(
                                  message['content'],
                                  style: TextStyle(
                                    color: isCurrentUser
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                              ),
                              ],
                        );
                      },
                    );
                  },
                ),
              ),

              // Message input field
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Colors.tealAccent,
                              size: 28,
                            ),
                            onPressed: _sendMessage,
                          ),
                          hintText: "Type your message...",
                          hintStyle: TextStyle(color: Colors.indigo[300]),
                          filled: true,
                          fillColor: Colors.black54,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to determine if we should display a timestamp
  bool _shouldShowTimestamp(DateTime current, DateTime previous) {
    return current.difference(previous).inMinutes > 1;
  }

// Function to format Firestore timestamps
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown time";
    final dateTime = timestamp.toDate();
    return DateFormat('EEEE hh:mm a')
        .format(dateTime); // Example: "Monday 08:30 AM"
  }


  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    // Fetch the current user's name from the `users` collection
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(currentUserId)
          .get();
      final senderName = userSnapshot.data()?['name'] ?? "Unknown";

      final message = {
        'senderId': currentUserId,
        'senderName': senderName,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      };


      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .add(message);

    } catch (e) {
      print("Error sending message: $e");
    }
  }
}
