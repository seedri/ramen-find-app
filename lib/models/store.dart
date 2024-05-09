class Store {
  int id = 0;
  final String name;
  final double latitude;
  final double longitude;
  final bool open;
  final double rating;
  final String photoReference;
  final String placeId;
  final int userRatingsTotal;
  int distance = 0;
  // final int distance;
  Store(
      {required this.name,
      required this.latitude,
      required this.longitude,
      required this.open,
      required this.rating,
      required this.photoReference,
      required this.placeId,
      required this.userRatingsTotal});

  factory Store.fromJson(Map<String, dynamic> json) {
    var location = json['geometry']["location"];
    // "opening_hours"が存在しない場合はopenプロパティにfalseを代入
    bool isOpen = json["opening_hours"] != null
        ? json["opening_hours"]["open_now"]
        : false;
    var model = Store(
        name: json['name'],
        latitude: location['lat'],
        longitude: location['lng'],
        rating: (json['rating'] ?? -1).toDouble(),
        photoReference:
            json['photos'] != null ? json['photos'][0]['photo_reference'] : "",
        open: isOpen,
        placeId: json['place_id'],
        userRatingsTotal: json['user_ratings_total']);
    return model;
  }
}
