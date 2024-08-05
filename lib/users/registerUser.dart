import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> registerUser(String email, String password, String name) async {
  try {
    // Firebase Authentication을 통해 사용자 생성
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;
    if (user != null) {
      // Firebase Realtime Database에 사용자 정보 저장
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users/${user.uid}');

      await userRef.set({
        'profile': {
          'name': name,
          'email': email,
          'registration_date': DateTime.now().toIso8601String(),
        },
        'heart_rate_data': {}, // 심박수 데이터 초기화
        'threshold': 100, // 기본 임계치
        'reports': {}, // 신고 내역 초기화
      });

      print('User registered and data saved successfully.');
    }
  } catch (e) {
    print('Error registering user: $e');
  }
}
