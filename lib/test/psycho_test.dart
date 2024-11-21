import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/question_model.dart';
import 'activity_test.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  final formKey2 = GlobalKey<FormState>();
  final firestore = FirebaseFirestore.instance;

  final List<Question> questions = [
    Question(
      category: "Znajomość",
      text: "Kogo szukasz?",
      options: [
        "Znajomych",
        "Miłości",
        "Obojętnie",
      ],
      selected: [false, false, false],
    ),
    Question(
      category: "Rodzina",
      text: "Za jaką osobę Siebie uważasz?",
      options: [
        "Skryta",
        "Otwarta",
        "Zagubiona ",
      ],
      selected: [false, false, false],
    ),
    Question(
      category: "Single",
      text: "Czy byłabyś/byłbyś otwarty na randkę?",
      options: [
        "Tak",
        "Może",
        "Nie",
      ],
      selected: [false, false, false],
    ),
    Question(
      category: "Wspólne spędzanie czasu",
      text: "Czy jesteś wierząca/wierzący?",
      options: [
        "Tak",
        "Nie",
      ],
      selected: [false, false],
    ),
  ];

  // State variable to control button enable/disable
  bool allAnswered = false;

  // Function to check if all questions are answered
  void checkIfAllAnswered() {
    setState(() {
      allAnswered = questions.every(
            (question) => question.selected.contains(true),
      );
    });
  }


  Future<void> saveTestResult() async {
    try {
      final User user = FirebaseAuth.instance.currentUser!;
      final testCollection = firestore.collection('profiles')
          .doc(user.uid)
          .collection("testResults")
          .doc("testID"); // Consider dynamically generating test IDs

      // Collect answers from the questions list
      final testData = questions.map((question) => question.toMap()).toList();

      // Save the answers to Firestore
      await testCollection.set({
        'answers': testData, // Save the list of answers
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ActivityPage(), // Navigate after saving
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
                  height: 50,
                ),
                SizedBox(
                  height: 550,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, questionIndex) {
                      return ListTile(
                        title: Text(
                          questions[questionIndex].text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Container(
                          height: 48,
                          margin: const EdgeInsets.only(top:10,left: 20, right: 20),
                          alignment: Alignment.center,
                          child: ToggleButtons(
                            fillColor: Colors.green[500],
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            selectedColor: Colors.white,
                            isSelected: questions[questionIndex].selected,
                            onPressed: (int optionIndex) {
                              setState(() {
                                for (int i = 0; i < questions[questionIndex].selected.length; i++) {
                                  questions[questionIndex].selected[i] = i == optionIndex;
                                }
                              });
                              checkIfAllAnswered(); // Check if all questions are answered
                            },
                            children: questions[questionIndex]
                                .options
                                .map((label) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        label,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, idx) {
                      return const SizedBox(
                        height: 10,
                      );
                    },
                    itemCount: questions.length,
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
                      saveTestResult();
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
