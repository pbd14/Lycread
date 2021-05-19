import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  Future<InitializationStatus> initialization;
  AdService(this.initialization);

  String get bannerAdUnitId => Platform.isAndroid
      ? 
      'ca-app-pub-3940256099942544/6300978111'
      // 'ca-app-pub-1051793823103334/7146335347'
      : 'ca-app-pub-3940256099942544/2934735716';

  AdListener get adListener => _adListener;

  AdListener _adListener = AdListener(
    onAdLoaded: (ad) => print('Ad loaded: ${ad.adUnitId}.'),
    onAdClosed: (ad) => print('Ad closed: ${ad.adUnitId}.'),
    onAdFailedToLoad: (ad, error) =>
        print('Ad failed to load: ${ad.adUnitId}, $error.'),
    onAdOpened: (ad) => print('Ad opened: ${ad.adUnitId}.'),
    onAppEvent: (ad, name, data) =>
        print('Ad event: ${ad.adUnitId}, $name, $data.'),
    onApplicationExit: (ad) => print('App exit: ${ad.adUnitId}.'),
    onNativeAdClicked: (ad) => print('Native ad clicked: ${ad.adUnitId}.'),
    onNativeAdImpression: (ad) =>
        print('Native ad impression: ${ad.adUnitId}.'),
    onRewardedAdUserEarnedReward: (ad, reward) => print(
        'User rewarded: ${ad.adUnitId}, ${reward.amount} ${reward.type}.'),
  );
}
