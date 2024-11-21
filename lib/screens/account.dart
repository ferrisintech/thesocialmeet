import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:thesocialmeet/main.dart';
import '../auth/register.dart';
import '../models/voivod_model.dart';
import '../variables/variable.dart';
import '../variables/voivodeship.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  TextEditingController editingControllerPopMenu = TextEditingController();
  TextEditingController editingControllerMyList = TextEditingController();

  TextEditingController txtTimeController1 = TextEditingController();
  TextEditingController txtTimeController2 = TextEditingController();

  late TextEditingController emailL;
  late TextEditingController hasloL;
  late TextEditingController nameR;
  late TextEditingController emailR;
  late TextEditingController hasloR;
  late TextEditingController hasloReset;

  bool isSignUp = true;
  bool clickLogin = false;
  bool isHoverReset = false;
  bool isVisible = true;
  final ImagePicker _picker = ImagePicker();
  final firestore = FirebaseFirestore.instance;

  late List<Voivodeship> voivodeships;
  Voivodeship? selectedVoivodeship;
  String? selectedCityIs;
  bool isCityDropdownDisabled = true;
  File? pickedFile;

  @override
  void initState() {
    super.initState();
    emailL = TextEditingController();
    hasloL = TextEditingController();
    emailR = TextEditingController();
    hasloR = TextEditingController();
    nameR = TextEditingController();
    hasloReset = TextEditingController();
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
    super.dispose();
  }

  // Load voivodeship data into objects and sort them
  List<Voivodeship> _loadVoivodeshipsData() {
    final List<Map<String, dynamic>> voivodeshipsData =
        List.from(voivodeshipData['voivodeships']);

    // Convert the raw data into Voivodeship objects and sort by name
    List<Voivodeship> sortedVoivodeships =
        voivodeshipsData.map((data) => Voivodeship.fromMap(data)).toList();

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

  // Function to pick an image from gallery
  Future pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

     // final imageTemp = File(pickedFile.path);
      final imagePerm = await saveImagePerm(pickedFile.path);
      setState(() => this.pickedFile = imagePerm);
    } on PlatformException catch (e) {
      print("Failed to pick image $e");
    }
  }

  // Function to pick an image from camera
  Future pickImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile == null) return;

      //final imageTemp = File(pickedFile.path);
      final imagePerm = await saveImagePerm(pickedFile.path);
      setState(() => this.pickedFile = imagePerm);
    } on PlatformException catch (e) {
      print("Failed to pick image $e");
    }
  }

/*
  Future<File> saveImagePerm(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');

    return File(imagePath).copy(image.path);
  }
*/
  Future<File> saveImagePerm(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = imagePath.split('/').last;
    final image = File('${directory.path}/$name');

    return File(imagePath).copy(image.path);
  }

  // Function to show options for picking image
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from Gallery'),
                onTap: () {
                  pickImageFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  pickImageFromCamera();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegisterPage()),
        );
      }
    } catch (e) {
      print("error $e");
    }
  }


  void _showEditDialog(
    BuildContext context,
    String fieldName,
    String initialValue, {
    List<String> options = const [],
    String? selectedValue, // Default to an empty list
  }) {
    final TextEditingController controller =
        TextEditingController(text: initialValue);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit"),
          content: fieldName == "gender" ||
                  fieldName == "city" ||
                  fieldName == "voivodeship"
              ? DropdownButtonFormField<String>(
                  value: selectedValue,
                  decoration: InputDecoration(
                    labelText: "Select $fieldName",
                    border: const OutlineInputBorder(),
                  ),
                  items: options.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    selectedValue = newValue;
                  },
                )
              : TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    // labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String updatedValue = controller.text;

                if (updatedValue.isNotEmpty) {
                  try {
                    final User user = FirebaseAuth.instance.currentUser!;

                    final profileCol = FirebaseFirestore.instance
                        .collection("profiles")
                        .doc(user.uid);

                    await profileCol.update({
                      fieldName: updatedValue,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Profile updated successfully!")),
                    );

                    setState(() {});
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to update profile")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Email cannot be empty")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialogVoivodeshipAndCity(
      BuildContext context,
      String initialVoivodeship,
      String initialCity,
      ) {
    // Set initial values for Voivodeship and City
    selectedVoivodeship = voivodeships.firstWhere(
          (voivodeship) => voivodeship.name == initialVoivodeship,
      orElse: () => voivodeships.first,
    );
    selectedCityIs = selectedVoivodeship!.cities.contains(initialCity)
        ? initialCity
        : (selectedVoivodeship!.cities.isNotEmpty ? selectedVoivodeship?.cities.first : null);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Voivodeship and City"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown for Voivodeship
                  DropdownButtonFormField<Voivodeship>(
                    decoration: const InputDecoration(
                      labelText: "Select Voivodeship",
                      contentPadding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      border: OutlineInputBorder(),
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
                        // Update the selected Voivodeship
                        selectedVoivodeship = selected;
                        // Update the City dropdown to show cities for the selected Voivodeship
                        selectedCityIs = selectedVoivodeship!.cities.isNotEmpty
                            ? selectedVoivodeship?.cities.first
                            : null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Dropdown for City
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Select City",
                      contentPadding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      border: OutlineInputBorder(),
                    ),
                    value: selectedCityIs,
                    items: selectedVoivodeship?.cities.map((city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (selectedCity) {
                      setState(() {
                        selectedCityIs = selectedCity;
                      });
                    },
                    isExpanded: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final User user = FirebaseAuth.instance.currentUser!;

                      // Reference to the Firestore collection 'profiles'
                      final profileCol = FirebaseFirestore.instance
                          .collection("profiles")
                          .doc(user.uid);

                      await profileCol.update({
                        "voivodeship": selectedVoivodeship?.name.trim(),
                        "city": selectedCityIs?.trim(),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Profile updated successfully!"),
                        ),
                      );

                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to update profile"),
                        ),
                      );
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _showDialogGender(
      BuildContext context,
      String fieldName,
      String initialGender,
      ) {
    // List of gender options
    final List<String> genLabels = ["Female", "Other", "Male"];

    // Set initial gender value
    String? selectedGender = genLabels.contains(initialGender) ? initialGender : null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      border: OutlineInputBorder(),
                    ),
                    value: selectedGender,
                    items: genLabels.map((gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (String? newGender) {
                      setState(() {
                        selectedGender = newGender;
                      });
                    },
                    isExpanded: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final User user = FirebaseAuth.instance.currentUser!;

                      // Reference to the Firestore collection 'profiles'
                      final profileCol = FirebaseFirestore.instance
                          .collection("profiles")
                          .doc(user.uid);

                      await profileCol.update({
                        fieldName: selectedGender?.trim(),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Profile updated successfully!"),
                        ),
                      );

                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to update profile"),
                        ),
                      );
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
//    final localeProvider = Provider.of<LanguageChangeProvider>(context);

    final User user = FirebaseAuth.instance.currentUser!;
    firestore.collection("profiles").doc(user.uid).get();
    final profileCSnap = FirebaseFirestore.instance
        .collection('profiles')
        .doc(user.uid)
        .snapshots();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(
                height: 50,
              ),
              Center(
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: ClipOval(
                    child: pickedFile != null
                        ? Image.file(
                        pickedFile!,
                      height: 140,
                      width: 140,
                      fit: BoxFit.cover,
                      ) // Load selected image
                       : Container(
                         height: 140,
                         width: 140,
                         color: Colors.grey,
                         child: const Icon(
                           Icons.add_a_photo,
                           color: Colors.white,
                           size: 45,
                         ),
                      ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),

              // StreamBuilder to load profile data in real-time
              StreamBuilder<DocumentSnapshot>(
                stream:
                    profileCSnap, // Assuming this is a Stream<DocumentSnapshot>
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Show a loader while waiting
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text("Profile not found");
                  } else {
                    final profileData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 10),
                          child: ListTile(
                            title: Text(profileData["name"]),
                            tileColor: Colors.blue.shade50,
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.orange),
                              onPressed: () {
                                _showEditDialog(
                                  context,
                                  "name",
                                  profileData["name"] ?? "",
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 10),
                          child: ListTile(
                            title: Text(profileData["email"]),
                            tileColor: Colors.blue.shade50,
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.orange),
                              onPressed: () {
                                _showEditDialog(
                                  context,
                                  "email",
                                  profileData["email"] ?? "",
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 10),
                          child: ListTile(
                            title: Text(profileData["age"].toString()),
                            tileColor: Colors.blue.shade50,
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.orange),
                              onPressed: () {
                                _showEditDialog(
                                  context,
                                  "age",
                                  profileData["age"].toString(),
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 10),
                          child: ListTile(
                            title: Text(profileData["gender"]),
                            tileColor: Colors.blue.shade50,
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.orange),
                              onPressed: () {

                                _showDialogGender(
                                  context,
                                  "gender",
                                  profileData["gender"] ?? "",
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: ListTile(
                            title: Text(profileData["city"]),
                            subtitle: Text(profileData["voivodeship"]),
                            tileColor: Colors.blue.shade50,
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.orange),
                              onPressed: () {
                                _showEditDialogVoivodeshipAndCity(
                                  context,
                                  profileData["voivodeship"] ?? "",
                                  profileData["city"] ?? "",
                                );

                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),

              Container(
                height: 48,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    _logout();
                  },
                  child: Text(
                    localization["logOut"]!,
                    style: const TextStyle(color: Colors.white, fontSize: 19),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
