// 인수인계용 Firebase 설정 예시입니다. REPLACE_WITH_*는 실제 값이 아닙니다.
// 인수자 소유 Firebase 프로젝트를 만든 뒤 mobile/에서
// flutterfire configure를 실행하여 이 파일을 다시 생성하세요.
// Android 패키지명 io.trickcal.trickcal_coupon_notifier는 유지합니다.
// google-services.json과 mobile/firebase.json도 같은 프로젝트로 갱신하세요.
// 새 설정을 생성하기 전에는 Firebase 초기화/앱 실행이 정상 동작하지 않습니다.
// Firebase 클라이언트 설정이며 서비스 계정 private key를 넣는 파일이 아닙니다.
// 자세한 절차: README.md의 Firebase 설정 및 docs/HANDOVER.md 3절.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_WEB_API_KEY',
    appId: 'REPLACE_WITH_FIREBASE_WEB_APP_ID',
    messagingSenderId: 'REPLACE_WITH_FIREBASE_PROJECT_NUMBER',
    projectId: 'REPLACE_WITH_FIREBASE_PROJECT_ID',
    authDomain: 'REPLACE_WITH_FIREBASE_AUTH_DOMAIN',
    storageBucket: 'REPLACE_WITH_FIREBASE_STORAGE_BUCKET',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_ANDROID_API_KEY',
    appId: 'REPLACE_WITH_FIREBASE_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE_WITH_FIREBASE_PROJECT_NUMBER',
    projectId: 'REPLACE_WITH_FIREBASE_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_FIREBASE_STORAGE_BUCKET',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_IOS_API_KEY',
    appId: 'REPLACE_WITH_FIREBASE_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_FIREBASE_PROJECT_NUMBER',
    projectId: 'REPLACE_WITH_FIREBASE_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_FIREBASE_STORAGE_BUCKET',
    iosBundleId: 'io.trickcal.trickcalCouponNotifier',
  );
}
