class Hobby {
  final String category;
  final List<String> options;
  List<bool> selected = [];


  Hobby({
    required this.category,
    required this.options,
    required this.selected,
  });

  // Convert the Question object to a Map
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'options': options,
      'selected': selected,
    };
  }

  // Optional: Add a fromMap constructor if you need to load data from Firestore
  factory Hobby.fromMap(Map<String, dynamic> map) {
    return Hobby(
      category: map['category'],
      options: List<String>.from(map['options']),
      selected: List<bool>.from(map['selected']),
    );
  }
}