import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:map_sample_flutter/env/env.dart';
import 'dart:convert';
import 'package:map_sample_flutter/models/store.dart';
import 'package:map_sample_flutter/models/store_detail.dart';
import 'store_info_tab.dart';
import 'reviews_tab.dart';
import 'photos_tab.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PageStoreDetail extends StatefulWidget {
  final Store store;

  PageStoreDetail({required this.store});

  @override
  _PageStoreDetailState createState() => _PageStoreDetailState();
}

class _PageStoreDetailState extends State<PageStoreDetail> {
  StoreDetail? storeDetail;
  bool isLoading = true;
  String apiKey = Env.key;
  final DefaultCacheManager cacheManager = DefaultCacheManager();

  @override
  void initState() {
    super.initState();
    fetchPlaceDetail();
  }

  Future<void> fetchPlaceDetail() async {
    // キャッシュから取得
    final fileInfo = await cacheManager.getFileFromCache(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=${widget.store.placeId}&language=ja&key=${apiKey}');

    if (fileInfo != null && fileInfo.validTill.isAfter(DateTime.now())) {
      // キャッシュがあり、有効期限内ならばキャッシュを使用
      final data = await fileInfo.file!.readAsString();
      Map<String, dynamic> jsonData = jsonDecode(data);
      setState(() {
        storeDetail = StoreDetail.fromJson(jsonData['result']);
        isLoading = false;
      });
    } else {
      // キャッシュがない、または有効期限切れの場合はネットワークリクエストを行う
      String apiUrl = "https://maps.googleapis.com/maps/api/place/details/json";
      String url =
          '$apiUrl?place_id=${widget.store.placeId}&language=ja&key=$apiKey';

      try {
        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);
          setState(() {
            storeDetail = StoreDetail.fromJson(data['result']);
            isLoading = false;
          });

          // レスポンスをキャッシュに保存
          await cacheManager.putFile(
              'https://maps.googleapis.com/maps/api/place/details/json?place_id=${widget.store.placeId}&language=ja&key=${apiKey}',
              response.bodyBytes,
              maxAge: Duration(days: 10));
        } else {
          throw Exception('Failed to load place detail');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('詳細情報を取得できませんでした。'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            // toolbarHeight: 100,

            title: Text('詳細情報'),
            bottom: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              // indicatorColor: Color.fromARGB(255, 255, 57, 57),
              indicatorWeight: 3,
              dividerColor: Colors.grey,
              dividerHeight: 3,
              tabs: [
                Tab(text: 'レビュー'),
                Tab(text: '写真'),
                Tab(
                  text: '基本情報',
                )
              ],
            ),
          ),
          body: SafeArea(
            child: Container(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : TabBarView(
                      children: [
                        ReviewsTab(storeDetail: storeDetail!),
                        PhotosTab(storeDetail: storeDetail!, apiKey: apiKey),
                        StoreInfoTab(storeDetail: storeDetail!),
                      ],
                    ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              margin: const EdgeInsets.only(right: 10, left: 10),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // ボトムシートを閉じる
                  },
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(color: Colors.black)),
                  child: Text(
                    '閉じる',
                    style: TextStyle(color: Color.fromARGB(255, 255, 5, 5)),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
