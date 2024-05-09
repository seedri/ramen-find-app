import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_sample_flutter/models/store.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:map_sample_flutter/pages/page_store_detail.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:map_sample_flutter/env/env.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoreCards extends StatefulWidget {
  StoreCards(
      {required this.stores,
      required this.mapController,
      required this.pageController});
  List<Store> stores;
  GoogleMapController mapController;
  PageController pageController;

  @override
  State<StoreCards> createState() => _StoreCardsState();
}

class _StoreCardsState extends State<StoreCards> {
  String apiKey = Env.key;
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      // width: MediaQuery.of(context).size.width * 1,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: PageView(
        onPageChanged: (int index) async {
          //スワイプ後のページのお店を取得
          final selectedStore = widget.stores.elementAt(index);
          //現在のズームレベルを取得
          final zoomLevel = await widget.mapController.getZoomLevel();
          //スワイプ後のお店の座標までカメラを移動
          widget.mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(selectedStore.latitude, selectedStore.longitude),
                zoom: zoomLevel,
              ),
            ),
          );
          widget.mapController
              .showMarkerInfoWindow(MarkerId(selectedStore.id.toString()));
        },
        controller: widget.pageController,
        children: _shopTiles(),
      ),
    );
  }

  //カード1枚1枚について
  List<Widget> _shopTiles() {
    final _shopTiles = widget.stores.map((store) {
      String photoReferenece = store.photoReference;

      return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 10,
          child: Stack(fit: StackFit.expand, children: [
            // 商品画像
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: CachedNetworkImage(
                imageUrl:
                    'https://maps.googleapis.com/maps/api/place/photo?maxwidth=300&photoreference=$photoReferenece&key=$apiKey',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              // オーバーレイ
              child: Container(
                color: Colors.grey.withOpacity(0.6),
                padding: const EdgeInsets.all(2),
                //height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: BorderedText(
                            child: Text(
                              store.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.notoSansJavanese(
                                textStyle:
                                    Theme.of(context).textTheme.headlineLarge,
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 16,
                              ),
                            ),
                            strokeWidth: 5,
                            strokeColor: Colors.black,
                          ),
                        ),
                        if (!store.open)
                          Text(
                            '※営業時間外',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                RatingBar.builder(
                                  initialRating: store.rating,
                                  allowHalfRating: true,
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star_rounded,
                                    color: Color.fromARGB(255, 255, 230, 0),
                                  ),
                                  onRatingUpdate: (rating) {},
                                  ignoreGestures: true,
                                  itemSize: 17,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                BorderedText(
                                  child: Text(
                                    '評価：${store.rating} (${store.userRatingsTotal}件)',
                                    style: GoogleFonts.notoSansJavanese(
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .headlineLarge,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 12,
                                    ),
                                  ),
                                  strokeWidth: 1,
                                  strokeColor: Colors.yellow,
                                )
                              ],
                            ),
                            BorderedText(
                              child: Text(
                                '現在地からの距離:${store.distance}m',
                                //textAlign: TextAlign.left,
                                style: GoogleFonts.zenMaruGothic(
                                    textStyle:
                                        Theme.of(context).textTheme.bodyLarge,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 12),
                              ),
                              strokeColor: Colors.black,
                              strokeWidth: 4,
                            )
                          ],
                        ),
                        FilledButton.tonal(
                          // style: ButtonStyle(
                          //     backgroundColor: MaterialStateProperty.all(
                          //         Color.fromARGB(255, 0, 172, 224))),
                          onPressed: () {
                            _showDetailPage(
                                context, store); // ボタンが押されたら詳細ページを表示
                          },
                          child: Text('詳細'),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ]));
    }).toList();
    return _shopTiles;
  }

  void _showDetailPage(BuildContext context, Store store) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return PageStoreDetail(store: store); // Store型の引数を渡して詳細ページを表示
      },
    );
  }
}
