import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Firebase 프로젝트 설정에 따른 옵션 파일

class FirebaseService {
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase 초기화 완료');
    } catch (e) {
      print('Firebase 초기화 중 오류 발생: $e');
    }
  }
}
