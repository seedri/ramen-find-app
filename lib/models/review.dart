class Review {
  final int rating;
  final String relative_time_description;
  final String text;
  Review(
      {required this.rating,
      required this.relative_time_description,
      required this.text});

  factory Review.fromJson(Map<String, dynamic> review) {
    var model = Review(
        rating: review["rating"],
        relative_time_description: review["relative_time_description"],
        text: review["text"]);
    return model;
  }
}
