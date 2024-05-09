import 'package:flutter/material.dart';
import 'package:map_sample_flutter/models/store_detail.dart';
import 'package:bubble/bubble.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreInfoTab extends StatelessWidget {
  final StoreDetail storeDetail;

  StoreInfoTab({required this.storeDetail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Bubble(
            color: Color.fromARGB(255, 167, 227, 255),
            shadowColor: Colors.grey,
            elevation: 10,
            stick: true,
            margin: BubbleEdges.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "営業時間",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5), // 必要に応じて適切なスペースを追加
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: storeDetail.weekdayText!
                      .map(
                        (text) => Text(
                          text,
                          maxLines: 1,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),

          // 他の店舗情報もここで表示
          Bubble(
            color: Color.fromARGB(255, 167, 227, 255),
            shadowColor: Colors.grey,
            elevation: 10,
            stick: true,
            margin: BubbleEdges.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "店舗情報",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SelectableText("住所：${storeDetail.vicinity}"),
                TextButton(
                    onPressed: () => storeDetail.webSite == '不明'
                        ? null
                        : launchUrl(Uri.parse(storeDetail.webSite)),
                    child: Text("ホームページ：${storeDetail.webSite}"))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
