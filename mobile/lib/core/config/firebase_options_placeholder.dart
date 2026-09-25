/// Firebase 설정 파일 플레이스홀더
///
/// 실제 사용을 위해서는 다음 명령어를 실행하여 firebase_options.dart를 생성해야 합니다:
///
/// ```bash
/// flutterfire configure
/// ```
///
/// 이 명령어는 Firebase 프로젝트와 연결하고 자동으로 firebase_options.dart 파일을 생성합니다.
/// 생성된 파일은 lib/firebase_options.dart 경로에 위치하게 됩니다.
///
/// 주의: 이 플레이스홀더 파일은 실제 앱 실행 시 사용되지 않습니다.

class FirebaseOptionsPlaceholder {
  static const String message = '''
Firebase 설정이 필요합니다.

다음 단계를 따라 설정해주세요:

1. Firebase Console에서 프로젝트 생성
2. 터미널에서 다음 명령어 실행:

   flutterfire configure

3. 프로젝트를 선택하고 플랫폼 설정 완료
4. 자동 생성된 firebase_options.dart 파일 확인

더 자세한 내용은 docs/firebase_deployment.md를 참고하세요.
''';
}
