import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thesocialmeet/test/psycho_test.dart';

import '../dashboard.dart';
import '../models/profile_model.dart';
import '../models/voivod_model.dart';
import '../variables/variable.dart';
import '../variables/voivodeship.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final firestore = FirebaseFirestore.instance;


  TextEditingController editingControllerPopMenu = TextEditingController();
  TextEditingController editingControllerMyList = TextEditingController();

  TextEditingController txtTimeController1 = TextEditingController();
  TextEditingController txtTimeController2 = TextEditingController();

  late TextEditingController emailL;
  late TextEditingController hasloL;
  late TextEditingController nameR;
  late TextEditingController emailR;
  late TextEditingController hasloR;
  late TextEditingController ageR;
  late TextEditingController pictureR;
  late TextEditingController genderR;
  late TextEditingController voivodR;
  late TextEditingController cityR;
  late TextEditingController hasloReset;

  bool isSignUp = true;
  bool clickLogin = false;
  bool isHoverReset = false;
  bool isVisible = true;

 // final List<bool> genSelected = [false,true,false];
 // final List<String> genLabels = ["Female", "Other", "Male"];

  late List<Voivodeship> voivodeships;
  Voivodeship? selectedVoivodeship;
  String? selectedCityIs;
  bool isCityDropdownDisabled = true;


  @override
  void initState() {
    super.initState();
    emailL = TextEditingController();
    hasloL = TextEditingController();
    emailR = TextEditingController();
    hasloR = TextEditingController();
    nameR = TextEditingController();
    hasloReset = TextEditingController();
    ageR = TextEditingController();
    pictureR = TextEditingController();
    genderR = TextEditingController();
    voivodR = TextEditingController();
    cityR = TextEditingController();

    voivodeships = _loadVoivodeshipsData();

  }

  @override
  void dispose() {
    emailL.dispose();
    hasloL.dispose();
    emailR.dispose();
    hasloR.dispose();
    nameR.dispose();
    hasloReset.dispose();
    ageR.dispose();
    pictureR.dispose();
    genderR.dispose();
    voivodR.dispose();
    cityR.dispose();
    super.dispose();
  }

  // Load voivodeship data into objects and sort them
  List<Voivodeship> _loadVoivodeshipsData() {
    final List<Map<String, dynamic>> voivodeshipsData = List.from(voivodeshipData['voivodeships']);

    // Convert the raw data into Voivodeship objects and sort by name
    List<Voivodeship> sortedVoivodeships = voivodeshipsData
        .map((data) => Voivodeship.fromMap(data))
        .toList();

    // Sort the voivodeships alphabetically by name
    sortedVoivodeships.sort((a, b) => a.name.compareTo(b.name));

    // Sort cities alphabetically for each voivodeship and remove duplicates
    for (var voivodeship in sortedVoivodeships) {
      voivodeship.cities = removeDuplicatesAndSort(voivodeship.cities);
    }

    return sortedVoivodeships;
  }

  List<String> removeDuplicatesAndSort(List<String> cities) {
    // Remove duplicates and sort the list alphabetically
    Set<String> uniqueCities = Set.from(cities);
    List<String> sortedCities = uniqueCities.toList();
    sortedCities.sort();
    return sortedCities;
  }

  Future<void> _register() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailR.text.trim(), password: hasloR.text.trim());

      final User user = FirebaseAuth.instance.currentUser!;
      final profileCollection = firestore.collection('profiles');
      final age = int.tryParse(ageR.text.trim()) ?? 0;

      final newProfile = Profile(
        userID: user.uid,
        email: emailR.text.trim(),
        name: nameR.text.trim(),
        gender: genLabels[genSelected.indexOf(true)],
        age: age,
        voivodeship: selectedVoivodeship!.name.trim(),
        city: selectedCityIs!.trim(),
        picture: "",
      );

      await profileCollection.doc(newProfile.userID).set(newProfile.toJson());

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const TestPage(), //const DashboardPage(),
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

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailL.text.trim(),
        password: hasloL.text.trim(),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const DashboardPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = localization["emailFormated"]!;
          break;
        case 'wrong-password':
          errorMessage = localization["passwordInvalid"]!;
          break;
        case 'email-already-in-use':
          errorMessage = localization["emailAddressUsed"]!;
          break;
        case 'invalid-credential':
          errorMessage = localization["suppliedAuth"]!;
          break;
        case 'account-exists-with-different-credential':
          errorMessage = localization["accountExists"]!;
          break;
        default:
          errorMessage = localization["somethingWentWrong"]!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(errorMessage, style: const TextStyle(fontSize: 17))),
      );
    }
  }

  _loginWidgetMenu() {
    return clickLogin == false
        ? Container(
      height: 160, //240,
      width: 360,
      margin: const EdgeInsets.only(left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 4,
            spreadRadius: 3,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Text(
            localization["signIn"]!,
            //  "Sign In",
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22),
          ),
          const SizedBox(
            height: 20,
          ),
          /*
          Container(
            height: 48,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF09B83E),
              ),
              onPressed: () {},
              child: Text(localization["logInWithWeChat"]!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 1,
                color: Colors.black,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                localization["or"]!,
                style: const TextStyle(color: Colors.black, fontSize: 15),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                width: 30,
                height: 1,
                color: Colors.black,
              ),
            ],
          ),
          */
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 48,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  clickLogin = true;
                });
              },
              child: Text(
                localization["logInWithEmail"]!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    )
        : _loginWidget();
  }

  _loginWidget() {
    return Container(
      height: 330,
      width: 360,
      margin: const EdgeInsets.only(left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 4,
            spreadRadius: 3,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Text(
            localization["signIn"]!,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: TextFormField(
              controller: emailL,
              style: const TextStyle(color: Colors.black),
              onChanged: (value) {},
              decoration: InputDecoration(
                hintText: localization["email"]!,
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                contentPadding:
                const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: TextFormField(
              obscureText: isVisible,
              controller: hasloL,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                suffixIcon: isVisible
                    ? IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  color: Colors.blue[300],
                  onPressed: () {
                    setState(() {
                      isVisible = !isVisible;
                    });
                  },
                )
                    : IconButton(
                  icon: const Icon(Icons.visibility_off_outlined),
                  color: Colors.red[300],
                  onPressed: () {
                    setState(() {
                      isVisible = !isVisible;
                    });
                  },
                ),
                hintText: localization["password"]!,
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                contentPadding:
                const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(right: 20),
            child: TextButton(
              onPressed: () {
                // _dialogReset();
              },
              child: Text(
                localization["forgotPassword"]!,
                style: TextStyle(color: Colors.teal[600], fontSize: 14),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
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
                _login();
                // _apiService.loginChina(emailL.text.trim(), hasloL.text.trim());
              },
              child: Text(
                localization["login"]!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _registerWidgetMenu() {
    return Container(
      height: 600,
      width: 360,
      margin: const EdgeInsets.only(left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 4,
            spreadRadius: 3,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Text(
                localization["signUp"]!,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 60,
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (email) =>
                  email != null && !EmailValidator.validate(email)
                      ? localization["validEmail"]!
                      : null,
                  controller: emailR,
                  style: const TextStyle(color: Colors.black),
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    hintText: localization["email"]!,
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                    contentPadding: const EdgeInsets.only(
                        left: 14.0, bottom: 6.0, top: 8.0),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                height: 60,
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  obscureText: isVisible,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (pass) => pass != null && pass.length < 6
                      ? localization["minChar"]!
                      : null,
                  controller: hasloR,
                  style: const TextStyle(color: Colors.black),
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    suffixIcon: isVisible
                        ? IconButton(
                      icon: const Icon(Icons.visibility_outlined),
                      color: Colors.blue[300],
                      onPressed: () {
                        setState(() {
                          isVisible = !isVisible;
                        });
                      },
                    )
                        : IconButton(
                      icon: const Icon(Icons.visibility_off_outlined),
                      color: Colors.red[300],
                      onPressed: () {
                        setState(() {
                          isVisible = !isVisible;
                        });
                      },
                    ),
                    hintText: localization["password"]!,
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                    contentPadding: const EdgeInsets.only(
                        left: 14.0, bottom: 6.0, top: 8.0),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                height: 60,
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (name) =>
                  name!.isEmpty ? localization["enterName"]! : null,
                  controller: nameR,
                  style: const TextStyle(color: Colors.black),
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    hintText: localization["name"]!,
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                    contentPadding: const EdgeInsets.only(
                        left: 14.0, bottom: 6.0, top: 8.0),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                height: 60,
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (name) {
                    if (name == null || name.isEmpty) {
                      return localization["enterAge"];
                    }
                    final number = int.tryParse(name);
                    if (number == null || number < 16 || number > 80) {
                     // return localization["enterValidAge"]; // Add this key to your localization
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    LengthLimitingTextInputFormatter(2),    // Limit input to 2 digits
                  ],
                  controller: ageR,
                  style: const TextStyle(color: Colors.black),
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    hintText: localization["age"]!,
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                    contentPadding: const EdgeInsets.only(
                        left: 14.0, bottom: 6.0, top: 8.0),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                height: 48,
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: ToggleButtons(
                  fillColor: Colors.green[500],
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  selectedColor: Colors.white,
                  isSelected: genSelected,
                  onPressed: (int index) {
                      setState(() {
                        for (int i = 0; i < genSelected.length; i++) {
                          genSelected[i] = i == index;
                        }
                      });
                    },
                    children: genLabels
                        .map((label) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(label, style: TextStyle(fontSize: 15),),
                    )).toList(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 55,
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: DropdownButtonFormField<Voivodeship>(
                  decoration: InputDecoration(labelText: 'Select Voivodeship',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                    contentPadding: const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),

                  value: selectedVoivodeship,
                  items: voivodeships.map((voivodeship) {
                    return DropdownMenuItem<Voivodeship>(
                      value: voivodeship,
                      child: Text(voivodeship.name),
                    );
                  }).toList(),
                  onChanged: (selected) {
                    setState(() {
                       selectedVoivodeship = selected;
                       selectedCityIs = null; // Reset city selection
                       isCityDropdownDisabled = selected == null;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a voivodeship' : null,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
          Container(
            height: 55,
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select City',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                contentPadding: const EdgeInsets.only(left: 14.0, bottom: 6.0, top: 8.0),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black26),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),

              value: selectedCityIs,
              items: selectedVoivodeship?.cities.map((city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),

              onChanged: isCityDropdownDisabled
                  ? null // Disable if no voivodeship is selected
                  : (selectedCity) {
                      setState(() {
                        selectedCityIs = selectedCity;
                     });
                  },
              validator: (value) => value == null ? 'Please select a city' : null,

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
                    _register();
                  },
                  child: Text(
                    localization["createAccount"]!,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 130,
                ),
                 SizedBox(
                  height: isSignUp ? 90 : null,
                ),
                Align(
                  alignment: Alignment.center,
                  child: isSignUp ? _loginWidgetMenu() : _registerWidgetMenu(),

                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isSignUp
                          ? localization["notUser"]!
                          : localization["alreadyUser"]!,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    TextButton(
                      key: const Key('sign-key'),
                      onPressed: () {
                        setState(() {
                          isSignUp = !isSignUp;
                          clickLogin = false;
                        });
                      },
                      child: Text(
                        isSignUp
                            ? localization["createAnAccount"]!
                            : localization["logInIn"]!,
                        style:
                        TextStyle(color: Colors.blue[700]!, fontSize: 17),
                      ),
                    ),
                  ],
                ),
                clickLogin == true
                    ? Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        clickLogin = false;
                      });
                    },
                    child: Text(
                      localization["back"]!,
                      //"Go back",
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
