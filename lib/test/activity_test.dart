import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/hobby_model.dart';
import 'match_group_test.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => ActivityPageState();
}

class ActivityPageState extends State<ActivityPage> {
  final formKey2 = GlobalKey<FormState>();
  final firestore = FirebaseFirestore.instance;

  final List<Hobby> hobbys = [
    Hobby(
      category: "Sport",
      options: [
        "Żużel",
        "Piłka nożna",
        "Siatkówka",
        "Koszykówka",
        "Hokej",
      ],
      selected: [false, false, false, false, false],
    ),
    Hobby(
      category: "Literatura",
      options: [
        "Romans",
        "Kryminał",
        "Sci-fi",
        "Popularnonaukowa",
        "Naukowa",
      ],
      selected: [false, false, false, false, false],
    ),
    Hobby(
      category: "Film",
      options: [
        "Horror",
        "Komedia",
        "Akcja",
        "Sci-fi",
        "Sztuki walki",
      ],
      selected: [false, false, false, false, false,],
    ),
    Hobby(
      category: "Muzyka",
      options: [
        "Rock",
        "Pop",
        "Jazz",
        "Hip-hop",
        "Klasyczna",
      ],
      selected: [false, false, false, false, false,],
    ),
  ];

  // Computed property to check if all categories have at least one selection
  bool get allAnswered {
    return hobbys.every((hobby) => hobby.selected.contains(true));
  }

  Future<void> saveActivitiesResult() async {
    try {
      final User user = FirebaseAuth.instance.currentUser!;
      final testCollection = firestore.collection('profiles')
          .doc(user.uid)
          .collection("hobbyResults")
          .doc("hobbyID"); // You could dynamically generate the document ID if needed

      final hobbyData = hobbys.map((hobby) => hobby.toMap()).toList();

      await testCollection.set({
        'hobbies': hobbyData, // Save the list of hobby selections
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MatchGroupPage(), // Navigate to the next page
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      SnackBar snackBar = SnackBar(
        content: Text(e.message!.trim(), style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.indigo,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: 700,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, hobbyIndex) {
                      return ListTile(
                        title: Text(
                          hobbys[hobbyIndex].category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Container(
                          height: 100, // Adjust height if needed
                          margin: const EdgeInsets.only(top: 10,), // left: 20, right: 20),
                         // alignment: Alignment.center,
                          child: Wrap(
                            spacing: 10.0, // Horizontal space between items
                            runSpacing: 10.0, // Vertical space between rows
                            children: List.generate(hobbys[hobbyIndex].options.length, (optionIndex) {
                              return ChoiceChip(
                                label: Text(
                                  hobbys[hobbyIndex].options[optionIndex],
                                  style: const TextStyle(fontSize: 14),
                                ),
                                selected: hobbys[hobbyIndex].selected[optionIndex],
                                onSelected: (bool selected) {
                                  setState(() {
                                    hobbys[hobbyIndex].selected[optionIndex] = selected;
                                  });
                                },
                                checkmarkColor: Colors.white,
                                selectedColor: Colors.indigo[400],
                                backgroundColor: Colors.grey[300],
                                labelStyle: TextStyle(
                                  color: hobbys[hobbyIndex].selected[optionIndex] ? Colors.white : Colors.black,
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, idx) {
                      return const SizedBox(
                        height: 10,
                      );
                    },
                    itemCount: hobbys.length,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: allAnswered ? Colors.black : Colors.grey,
                    ),
                    onPressed: allAnswered
                        ? () {
                      saveActivitiesResult();
                    } : null,
                    child: const Text(
                      "Next",
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
