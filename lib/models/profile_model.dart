class Profile {
  final String userID;
  final String email;
  final String name;
  final String voivodeship; // New field
  final String city;       // New field
  final int age;           // New field
  final String gender;     // New field
  final String picture;    // New field

  Profile({
    required this.userID,
    required this.email,
    required this.name,
    required this.voivodeship,
    required this.city,
    required this.age,
    required this.gender,
    required this.picture,
  });

  // Factory constructor to create a Profile object from JSON (Firestore Map)
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userID: json['userID'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      voivodeship: json['voivodeship'] ?? '',
      city: json['city'] ?? '',
      age: json['age'] != null ? int.tryParse(json['age'].toString()) ?? 0 : 0,
      gender: json['gender'] ?? '',
      picture: json['picture'] ?? '',
    );
  }

  // Method to convert Profile object to JSON (Firestore Map)
  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'email': email,
      'name': name,
      'voivodeship': voivodeship,
      'city': city,
      'age': age,
      'gender': gender,
      'picture': picture,
    };
  }
}