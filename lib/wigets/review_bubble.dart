import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:map_sample_flutter/models/review.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewBubble extends StatelessWidget {
  final Review review;

  const ReviewBubble({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(height: 10),
      Row(children: [
        SizedBox(
          width: 20,
        ),
        Text(
          review.relative_time_description,
          style: TextStyle(fontSize: 12),
        ),
        SizedBox(
          width: 10,
        ),
        Text("評価:"),
        RatingBar.builder(
          initialRating: review.rating.toDouble(),
          itemBuilder: (context, _) => Icon(
            Icons.grade,
            color: Color.fromARGB(255, 241, 220, 22),
          ),
          onRatingUpdate: (temp) {},
          ignoreGestures: true,
          itemSize: 22,
        ),
      ]),
      Bubble(
        margin: BubbleEdges.all(10),
        nip: BubbleNip.leftTop,
        nipWidth: 20,
        nipHeight: 20,
        elevation: 10,
        color: Color.fromARGB(255, 253, 249, 192),
        alignment: Alignment.topLeft,
        child: Text(
          review.text,
          style: TextStyle(fontSize: 13),
        ),
      ),
      SizedBox(
        height: 10,
      )
    ]);
  }
}
