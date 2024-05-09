import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:map_sample_flutter/ad/ad_appopen_manager.dart';
import 'package:map_sample_flutter/ad/adbanner.dart';
import 'package:map_sample_flutter/functions/resize_image.dart';
import 'package:map_sample_flutter/logic/ad_utils.dart';
import 'models/store.dart';
import 'wigets/store_cards.dart';
import 'package:map_sample_flutter/env/env.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:styled_text/styled_text.dart';
import 'package:app_settings/app_settings.dart';

void main() =>
    runApp(MaterialApp(debugShowCheckedModeBanner: false, home: const MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController? mapController;
  final PageController pageController =
      PageController(viewportFraction: 0.8 //0.85くらいで端っこに別のカードが見えてる感じになる
          );
  //検索ボタンのy座標
  double searchButtonPosY = 0.91;
  double outPosY = 1.8;

  late double allign_y;
  bool markerTapped = false;
  //検索範囲、の場合は範囲設定なしを意味する
  double searchDistance = 0;
  double _searchDistanceSlider = 0;
  //営業時間外の店を表示するか
  bool closeStore = false;
  Set<Marker> markers = {};
  List<Store> stores = [];
  //初期値は東京駅
  final LatLng _center = const LatLng(35.6809591, 139.7673068);
  bool isLocationPermissionGranted = false;
  //店舗を検索中
  bool isLoading = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  //現在地
  Position? nowPos;
  final String apiKey = Env.key;

  //広告表示関連
  late AdUtils adUtils;
  AdAppOpenAdManager appOpenAdManager = AdAppOpenAdManager();
  late final AppLifecycleListener _listener;

  //位置情報許可を確認し、未許可なら設定画面を開かせる
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      showAlert();
      return false;
    } else {
      return true;
    }
  }

  showAlert() async {
    await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('このアプリの利用には位置情報取得許可が必要です。'),
            content: Text("位置情報を許可してください。"),
            actions: [
              ElevatedButton(
                child: Text("キャンセル"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text("設定を開く"),
                onPressed: () async {
                  await AppSettings.openAppSettings(
                      type: AppSettingsType.location);
                },
              ),
            ],
          );
        });
  }

  //エラーメッセージを出すときに使う関数
  showErrorLog(String titleText, String contentText) async {
    await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(titleText),
            content: Text(contentText),
            actions: [
              ElevatedButton(
                child: Text("閉じる"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  //現在位置を取得、地図を移動
  Future<void> getLocationAndMove() async {
    bool isLocationPermissionGranted =
        await requestLocationPermission(); //位置情報許可情報 //await：これが完了しないと次に進まない
    if (isLocationPermissionGranted) {
      // 現在の位置を返す
      nowPos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      //地図の移動
      _moveCameraToLoc(nowPos!);
    } else {
      //ここに現在位置を許可するアラートを出す処理を書く
      return;
    }
  }

  //付近のラーメン屋の検索
  Future<List<Store>> fetchPlaces() async {
    //改めて現在位置の取得
    nowPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    const String apiUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

    _moveCameraToLoc(nowPos!);
    double latitude = nowPos!.latitude;
    double longitude = nowPos!.longitude;
    //int radius = 500;

    String url =
        '$apiUrl?location=$latitude,$longitude&rankby=distance&type=restaurant&key=$apiKey&language=ja&keyword=ラーメン&';
    if (!closeStore) url += 'opennow=true&';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> decodeData = jsonDecode(response.body);
      List<dynamic> places = decodeData['results'];
      // List<dynamic> を List<Store> に変換
      List<Store> stores =
          places.map((place) => Store.fromJson(place)).toList();
      return stores;
    } else {
      throw Exception('Failed to load places');
    }
  }

  @override
  void dispose() {
    mapController!.dispose();
    super.dispose();
  }

  void _moveCameraToLoc(Position position) {
    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  // 付近のラーメン屋に対して配列の用意、現在地との距離の計算、マーカーの追加
  Future<void> handleSearchButtonPress() async {
    Set<Marker> _markers = {};
    bool isLocationPermissionGranted =
        await requestLocationPermission(); //位置情報許可情報 //await：これが完了しないと次に進まない
    //現在地許可のない場合終了
    if (!isLocationPermissionGranted) {
      return;
    }
    //ズームレベル設定のための緯度経度
    double minLat = 90;
    double maxLat = -90;
    double minLng = 180;
    double maxLng = -180;
    //検索中を有効にする
    setState(() {
      isLoading = true;
    });

    //検索し、得られた店舗を配列tempStoresに格納
    List<Store> tempStores = await fetchPlaces();
    stores.clear();
    int id = 0;

    if (tempStores.isNotEmpty) {
      for (Store store in tempStores) {
        store.id = id;
        //距離の計算
        int distanceMeter = Geolocator.distanceBetween(nowPos!.latitude,
                nowPos!.longitude, store.latitude, store.longitude)
            .toInt();
        store.distance = distanceMeter;
        //もし指定した距離以上なら検索結果から排除
        if (store.distance > searchDistance && searchDistance != 0) {
          id--;
        } else if (store.photoReference == "") {
          //写真情報がない時は表示しない
          id--;
        } else {
          stores.add(store);
          if (store.latitude < minLat) {
            minLat = store.latitude;
          }
          if (store.latitude > maxLat) {
            maxLat = store.latitude;
          }
          if (store.longitude < minLng) {
            minLng = store.longitude;
          }
          if (store.longitude > maxLng) {
            maxLng = store.longitude;
          }
        }
        id++;
      }
      if (stores.isEmpty) {
        showErrorLog("検索結果なし", "この距離ではラーメン店を見つけることはできませんでした");
        setState(() {
          isLoading = false;
        });
        return;
      }
      final ByteData data = await rootBundle.load('assets/pin-ramen-7.png');

      Uint8List bytes = data.buffer.asUint8List();

      Uint8List smalledMarkerImage = resizeImage(bytes, 90, 120);
      _markers = stores.map(
        (selectedShop) {
          return Marker(
            markerId: MarkerId(selectedShop.id.toString()),
            position: LatLng(selectedShop.latitude, selectedShop.longitude),
            icon: BitmapDescriptor.fromBytes(smalledMarkerImage),
            infoWindow: InfoWindow(title: selectedShop.name),
            onTap: () async {
              //タップしたお店がPageViewで表示されるように飛ばす
              pageController.jumpToPage(selectedShop.id);
              setState(() {
                markerTapped = true; // マーカーをタップしたことを記録
              });
            },
          );
        },
      ).toSet();
      setState(() {
        isLoading = false;
        markers = _markers;
        //ズームレベルの更新
        setCameraZoom(minLat, minLng, maxLat, maxLng);
      });
    } else {
      showErrorLog("検索結果なし", "この距離ではラーメン店を見つけることはできませんでした");
      setState(() {
        isLoading = false;
      });
    }
  }

  //ズームレベルを動的に変更する
  void setCameraZoom(
      double minLat, double minLng, double maxLat, double maxLng) {
    // マーカーの範囲に合わせてズームレベルと中心位置を設定
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    // カメラを範囲に合わせて移動
    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 60), // 追加の余白を指定できます
    );
  }

  @override
  void initState() {
    super.initState();
    _init(); // 非同期メソッドの呼び出し
  }

  Future<void> _init() async {
    allign_y = searchButtonPosY;
    adUtils = AdUtils();
    if (await adUtils.canShowAdAppOpen()) {
      appOpenAdManager.loadAd();
      _listener = AppLifecycleListener(
        onShow: () => appOpenAdManager.loadAd(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(0, 20, 255, 63)),
        textTheme: GoogleFonts.mPlus1CodeTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          appBar: AppBar(
            title: StyledText(
              textAlign: TextAlign.center,
              text: '爆速 <runner/>ラーメン',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Color.fromARGB(255, 100, 100, 100),
                    offset: Offset(2.0, 2.0),
                    blurRadius: 7.0,
                  ),
                ],
              ),
              tags: {
                'runner': StyledTextWidgetTag(Image.asset('assets/34879.png'),
                    size: Size(30, 30))
              },
            ),
            centerTitle: true,
            toolbarHeight: 45,
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 25),
            actions: stores.isNotEmpty
                ? [
                    IconButton(
                        icon: Icon(
                          Icons.delete_forever,
                          size: 40,
                          color: Color.fromARGB(255, 224, 21, 7),
                        ),
                        onPressed: () {
                          setState(() {
                            stores.clear();
                            markers = {};
                          });
                        })
                  ]
                : [],
          ),
          drawer: Drawer(
              child: ListView(
            children: [
              SizedBox(
                  height: 90,
                  child: DrawerHeader(
                      child: Text('検索条件設定'),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.black, width: 1)),
                      ))),
              Column(
                children: [
                  Text(
                    (searchDistance == 0)
                        ? '範囲設定なし'
                        : (searchDistance < 1000)
                            ? searchDistance.toInt().toString() + ' m以内'
                            : (searchDistance / 1000).toString() + ' km以内',
                    style: TextStyle(fontSize: 18),
                  ),
                  SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 5,
                        thumbColor: Colors.green,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 11),
                        overlayColor:
                            Color.fromARGB(255, 95, 87, 73).withAlpha(30),
                        activeTrackColor: Color.fromARGB(255, 141, 133, 255),
                        inactiveTrackColor: Colors.amber,
                        inactiveTickMarkColor:
                            const Color.fromARGB(255, 0, 0, 0),
                        activeTickMarkColor: Colors.red,
                      ),
                      child: Slider(
                        min: 0,
                        max: 2000,
                        divisions: 10,
                        value: _searchDistanceSlider,
                        onChanged: (value) {
                          //スライダーの縮尺を左右で変えるための処理
                          setState(() {
                            _searchDistanceSlider = value;
                            if (value <= 1000) searchDistance = value;
                            if (value > 1000 && value <= 1800) {
                              searchDistance = 1000 + (value - 1000) * 5;
                            } else if (value > 1800) {
                              searchDistance = 10000;
                            }
                          });
                        },
                      )),
                  Divider(),
                  SwitchListTile(
                      title: Text('営業時間外を含む'),
                      value: closeStore,
                      onChanged: (bool value) {
                        setState(() {
                          closeStore = value;
                        });
                      }),
                  Divider()
                ],
              ),
            ],
          )),
          body: Stack(children: [
            GoogleMap(
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 14.0,
              ),
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onCameraMoveStarted: () {
                setState(() {
                  allign_y = outPosY;
                });
              },
              onCameraIdle: () {
                setState(() {
                  allign_y = searchButtonPosY; // 検索ボタンの表示
                  markerTapped = false;
                });
              },
            ),
            if (stores.isNotEmpty)
              Column(
                children: [
                  StoreCards(
                    stores: stores,
                    mapController: mapController!,
                    pageController: pageController,
                  ),
                ],
              ),
            if (isLoading)
              Center(
                child: SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      strokeWidth: 10,
                    )),
              ),
            AnimatedAlign(
              alignment: Alignment(0, allign_y),
              duration: Duration(seconds: 1),
              curve: Curves.decelerate,
              child: Stack(
                children: [
                  FilledButton.icon(
                      onPressed: handleSearchButtonPress,
                      style: FilledButton.styleFrom(
                        side: BorderSide(color: Colors.black, width: 3),
                        // surfaceTintColor:
                        //     Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      icon: Image.asset(
                        'assets/19561.png',
                        width: 65,
                        height: 60,
                        color: Colors.white70,
                      ),
                      label: const Text(
                        '現在地付近で検索',
                        style: TextStyle(fontSize: 18),
                      )),
                  const Positioned(
                    bottom: -1,
                    right: -1,
                    child: Icon(
                      Icons.search,
                      size: 25,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ]),
          bottomNavigationBar: SafeArea(
            child: FutureBuilder(
              future: AdSize.getAnchoredAdaptiveBannerAdSize(
                  Orientation.portrait,
                  MediaQuery.of(context).size.width.truncate()),
              builder: (
                BuildContext context,
                AsyncSnapshot<AnchoredAdaptiveBannerAdSize?> snapshot,
              ) {
                if (snapshot.hasData) {
                  final data = snapshot.data;
                  if (data != null) {
                    return Container(
                      height: data.height.toDouble(),
                      color: Colors.white70,
                      child: AdBanner(size: data),
                    );
                  } else {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.9,
                      color: Colors.white70,
                    );
                  }
                } else {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    color: Colors.white70,
                  );
                }
              },
            ),
          ),
          floatingActionButton: SizedBox(
              width: 42,
              height: 42,
              child: FloatingActionButton(
                onPressed: () async {
                  LocationPermission permission =
                      await Geolocator.checkPermission();
                  if (permission == LocationPermission.deniedForever ||
                      permission == LocationPermission.denied) {
                    showAlert();
                  } else {
                    getLocationAndMove();
                  }
                },
                child: Icon(
                  Icons.near_me,
                ),
              ))),
    );
  }
}
