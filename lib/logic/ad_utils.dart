import 'package:shared_preferences/shared_preferences.dart';

class AdUtils {
  //広告表示の間隔
  final int intervalDays = 3;
  late SharedPreferences _preferences;

  // SharedPreferences を設定するメソッド
  Future<void> setSharedPreferences(SharedPreferences prefs) async {
    _preferences = prefs;
  }

  Future<void> saveLastAdTimestamp() async {
    _preferences = await SharedPreferences.getInstance();
    int currentTimestamp =
        (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    _preferences.setInt('lastAdTimestamp', currentTimestamp);
  }

  Future<int> getLastAdTimestamp() async {
    _preferences = await SharedPreferences.getInstance();
    return _preferences.getInt('lastAdTimestamp') ?? 0;
  }

  Future<bool> canShowAdAppOpen() async {
    int lastAdTimestamp = await getLastAdTimestamp();
    int currentTimestamp =
        (DateTime.now().millisecondsSinceEpoch / 1000).floor();

    // 3日以上経過していれば広告表示を許可
    if (currentTimestamp - lastAdTimestamp >= intervalDays * 24 * 60 * 60) {
      // 広告が表示されたタイミングでタイムスタンプを更新
      await saveLastAdTimestamp();
      return true;
    } else
      return false;
  }
}
