import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../dashboard.dart';

class MatchGroupPage extends StatefulWidget {
  const MatchGroupPage({super.key});

  @override
  State<MatchGroupPage> createState() => MatchGroupPageState();
}

class MatchGroupPageState extends State<MatchGroupPage> {
  final formKey2 = GlobalKey<FormState>();
  final firestore = FirebaseFirestore.instance;

 // List<GroupList> groups = [];
  List<String> groupIds = [];
  Map<String, bool> isJoined = {};
  int joinedGroupCount = 0; // To track how many groups the user has joined


  @override
  void initState() {
    super.initState();
    fetchGroupIds();
  }

  void fetchGroupIds() async {
    final User user = FirebaseAuth.instance.currentUser!;
    final snapshot = await firestore.collection('groups').get();

    final List<String> groupNames = [];
    final Map<String, bool> initialStates = {};

    // Loop through documents to fetch group IDs
    for (var doc in snapshot.docs) {
      groupNames.add(doc.id); // Add the document ID (group name)

      final usersField = doc['users'];
      if (usersField is List) {
        final users = usersField.map((e) => e.toString()).toList();
        initialStates[doc.id] = users.contains(user.uid);
        if (users.contains(user.uid)) {
          joinedGroupCount++; // Increment count if user is in the group
        }
      } else {
        initialStates[doc.id] = false;
      }

    }

    setState(() {
      groupIds = groupNames;
      isJoined = initialStates;
    });
  }

  // Handle join/leave action for a specific group
  Future<void> toggleGroupMembership(String groupId, bool join) async {
    try {
      final User user = FirebaseAuth.instance.currentUser!;
      final groupRef = firestore.collection('groups').doc(groupId);

      if (join) {
        if (joinedGroupCount >= 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can join a maximum of 2 groups')),
          );
          return;
        }
      }

      await groupRef.update({
        'users': join
            ? FieldValue.arrayUnion([user.uid]) // Add user
            : FieldValue.arrayRemove([user.uid]) // Remove user
      });

      setState(() {
        isJoined[groupId] = join;
        if (join) {
          joinedGroupCount++;
        } else {
          joinedGroupCount--;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
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
          title: const Text("Suggested Groups", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                  groupIds.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                    height: 550,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, groupIndex) {

                      final groupId = groupIds[groupIndex];
                      final joined = isJoined[groupId] ?? false;
                      final canJoin = joinedGroupCount < 2 || joined;

                      return ListTile(
                          title: Text(
                            groupId,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: TextButton(
                            onPressed: canJoin
                                ? () {
                              toggleGroupMembership(groupId, !joined);
                            } : null, // Disable the button if limit is reached
                            child: Text(
                              joined ? "Leave" : "Join",
                              style: TextStyle(
                                color: joined  //isJoined[groupIndex]
                                    ? Colors.red
                                    //: Colors.blue[500],
                                    : (canJoin ? Colors.blue[500] : Colors.grey),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, idx) {
                        return const SizedBox(
                          height: 10,
                        );
                      },
                      itemCount: groupIds.length,
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const DashboardPage(), // Navigate to the next page
                        ),
                      );
                    },
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
