import 'review.dart';

class StoreDetail {
  int id = 0;
  //営業時間のテキスト
  final List<String>? weekdayText;
  final List<String> photoReferences;
  final List<Review> reviews;
  //住所
  final String vicinity;
  final String webSite;
  // final int distance;
  StoreDetail(
      {required this.weekdayText,
      required this.photoReferences,
      required this.reviews,
      required this.vicinity,
      required this.webSite});

  factory StoreDetail.fromJson(Map<String, dynamic> json) {
    List<dynamic> photos = json["photos"];
    List<String> _photoReferences = [];
    List<dynamic> reviewsFromJson = json["reviews"];
    List<Review> _reviews = [];
    List<dynamic> weekdayTexts =
        json["current_opening_hours"]["weekday_text"] != null
            ? json["current_opening_hours"]["weekday_text"]
            : ["不明"];
    List<String> _weekdayText = [];
    String _webSite = json['website'] != null ? json['website'] : "不明";
    String _vicinity = json["vicinity"] != null ? json['vicinity'] : "不明";
    for (var photo in photos) {
      _photoReferences.add(photo["photo_reference"]);
    }
    for (var weekdayText in weekdayTexts) {
      _weekdayText.add(weekdayText);
    }
    for (var review in reviewsFromJson) {
      _reviews.add(Review.fromJson(review));
    }
    var model = StoreDetail(
        weekdayText: _weekdayText,
        photoReferences: _photoReferences,
        reviews: _reviews,
        webSite: _webSite,
        vicinity: _vicinity);
    return model;
  }
}
