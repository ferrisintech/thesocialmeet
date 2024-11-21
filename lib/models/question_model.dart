class Question {
  String category;
  String text;
  List<String> options;
  List<bool> selected;

  Question({
    required this.category,
    required this.text,
    required this.options,
    required this.selected,
  });

  // Convert the Question object to a Map
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'text': text,
      'options': options,
      'selected': selected,
    };
  }

  // Optional: Add a fromMap constructor if you need to load data from Firestore
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      category: map['category'],
      text: map['text'],
      options: List<String>.from(map['options']),
      selected: List<bool>.from(map['selected']),
    );
  }
}
