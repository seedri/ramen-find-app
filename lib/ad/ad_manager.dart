import 'dart:io';

class AdManager {
  // アプリIDを返す関数
  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-7585032538907137~4817121830";
    } else if (Platform.isIOS) {
      return "ca-app-pub-7585032538907137~1445104687";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  // バナー広告ユニットIDを返す関数
  static String get bannerAdUnitId {
    const String bannerIdTest = "ca-app-pub-3940256099942544/2934735716";
    //本番環境のID
    const String bannerId = "ca-app-pub-7585032538907137/5176767457";
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/6300978111"; // テストID
    } else if (Platform.isIOS) {
      return bannerId;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  // アプリ起動広告IDを返す関数
  static String get appOpenAdUnitId {
    const String appOpenIdTest = "ca-app-pub-3940256099942544/5575463023";
    //本番環境のID
    const String appOpenId = "ca-app-pub-7585032538907137/8086620370";
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/9257395921"; // テストID
    } else if (Platform.isIOS) {
      return appOpenId;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
