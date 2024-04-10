import 'package:glorify_god/models/remote_config/remote_config_model.dart';

RemoteConfig remoteConfigData = RemoteConfig(
  bannerMessages: [],
  testAdUnitId: 'ca-app-pub-3940256099942544/6300978111',
  androidAdUnitId: 'ca-app-pub-1337686275359225/2110324213',
  // Fall back test id
  iosAdUniId: '"ca-app-pub-1337686275359225/7171079204',
  // Fall back test id
  showUpdateBanner: false,
  interstitialAdTestId: 'ca-app-pub-3940256099942544/8691691433',
  //'ca-app-pub-3940256099942544/1033173712',
  androidInterstitialAdUnitId: 'ca-app-pub-1337686275359225/1727180834',
  //'ca-app-pub-3940256099942544/1033173712',
  iosInterstitialAdUnitId: 'ca-app-pub-1337686275359225/4169565248',
  //'ca-app-pub-3940256099942544/1033173712',
  interstitialAdTime: 10,
  appUpdateVersions:
      AppUpdateVersions(androidLatestVersion: '1.0.007', iosLatestVersion: '1.0.007'),
);
