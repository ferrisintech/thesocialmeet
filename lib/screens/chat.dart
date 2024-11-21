
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thesocialmeet/group_chat_screen.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User _currentUser = FirebaseAuth.instance.currentUser!;
  List<String> groupIds = [];


  Future<void> fetchUserGroups() async {
    try {
      final snapshot = await _firestore
          .collection('groups')
          .where('users', arrayContains: _currentUser.uid) // Filter groups
          .get();

      final List<String> userGroups = snapshot.docs.map((doc) => doc.id).toList();

      setState(() {
        groupIds = userGroups;
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserGroups();
  }


  void showGroupDialog(BuildContext context, String groupId) async {
    try {
      // Fetch the group data
      DocumentSnapshot groupSnapshot =
      await _firestore.collection('groups').doc(groupId).get();

      if (!groupSnapshot.exists) {
        throw Exception("Group not found");
      }

      // Extract user IDs
      List<dynamic> userIds = groupSnapshot['users'];
      if (userIds.isEmpty) {
        throw Exception("No users in group");
      }

      // Fetch user details
      List<Map<String, dynamic>> userDetails = [];
      for (String userId in userIds) {
        DocumentSnapshot userSnapshot =
        await _firestore.collection('profiles').doc(userId).get();
        if (userSnapshot.exists) {
          userDetails.add({
           // 'uid': userId,
            'name': userSnapshot['name'] ?? 'Unknown',
          });
        }
      }

      // Show dialog with group info
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(child: Text(groupId, style: const TextStyle(fontWeight: FontWeight.bold))),
            content: SizedBox(
              width: double.maxFinite,
              child:
              ListView.builder(
                shrinkWrap: true,
                itemCount: userDetails.length,
                itemBuilder: (context, index) {
                  final user = userDetails[index];

                  // Append " (me)" if the user ID matches the current user
                  final displayName = user['uid'] == _currentUser.uid
                      ? "${user['name']} (me)"
                      : user['name'];

                  return ListTile(
                    title: Text(displayName),
                    leading: CircleAvatar(
                      child: Text(user['name'][0].toUpperCase()), // Initial of the name
                    ),
                  );
                },
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      print("Error: ${e.toString()}");
    }
  }




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
          title: const Text("Chats", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child:
          FutureBuilder<QuerySnapshot>(
            future: _firestore.collection('groups').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error fetching chats'));
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No chats available'));
              } else {
                var privateChats = snapshot.data!.docs;

                return ListView(
                  children: [
                    // GROUP section
                    if (groupIds.isNotEmpty)
                      ExpansionTile(
                        key:PageStorageKey(groupIds),
                        initiallyExpanded: true,
                        trailing: Icon(Icons.arrow_drop_up_sharp, size: 0,),
                        title: const Text('GROUP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                        children: groupIds.map<Widget>((groupId) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              border: Border.all(color: Colors.black54),
                            ),
                            child: ListTile(
                            title: Text(groupId, style: TextStyle(fontSize: 18),),
                            trailing: IconButton(
                              icon: const Icon(Icons.info_outline, size: 26,),
                              color: Colors.orange[700],
                              onPressed: () {
                                showGroupDialog(context, groupId);
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => GroupChat(groupId: groupId),), //const DashboardPage(),
                                );
                            },
                            ), );
                        }).toList(),
                      ),

                    /*
                    // PRIVATE section
                    if (privateChats.isNotEmpty)
                      ExpansionTile(
                        title: const Text('PRIVATE'),
                        children: privateChats.map<Widget>((privateChat) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(privateChat['user2']['photoUrl']),
                            ),
                            title: Text(privateChat['user2']['name']),
                            subtitle: Text(
                              privateChat['lastMessage'].toString().length > 20
                                  ? privateChat['lastMessage'].toString().substring(0, 20) + '...'
                                  : privateChat['lastMessage'],
                            ),
                            onTap: () {
                              // Navigate to private chat details screen
                            },
                          );
                        }).toList(),
                      ),
                    */
                  ],
                );
              }
            },
          ),

        ),
      ),
    );
  }
}