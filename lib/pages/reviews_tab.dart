import 'package:flutter/material.dart';
import 'package:map_sample_flutter/models/store_detail.dart';
import 'package:map_sample_flutter/wigets/review_bubble.dart';

class ReviewsTab extends StatelessWidget {
  final StoreDetail storeDetail;

  ReviewsTab({required this.storeDetail});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: storeDetail.reviews.length,
      itemBuilder: (context, index) {
        return ReviewBubble(review: storeDetail.reviews[index]);
      },
    );
  }
}
