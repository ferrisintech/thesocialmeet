class Voivodeship {
  final String name;
  List<String> cities;

  Voivodeship({required this.name, required this.cities});

  factory Voivodeship.fromMap(Map<String, dynamic> map) {
    return Voivodeship(
      name: map['name'],
      cities: List<String>.from(map['cities']),
    );
  }
}

class City {
  final String name;

  City({required this.name});
}
