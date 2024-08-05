import 'package:flutter/material.dart';

import 'SignUpScreen.dart';

class MemberSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F8FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '회원 유형 선택',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: 'Noto Sans HK',
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 80),
            _buildGeneralMemberOption(context),
            SizedBox(height: 80),
            _buildAdminMemberOption(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralMemberOption(BuildContext context) {
    return Container(
      width: 250, // Fixed width for consistency
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          elevation: 5,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpScreen(role: 'general'),
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person, size: 40, color: Colors.blue),
            SizedBox(width: 10),
            Text(
              '일반 회원',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMemberOption(BuildContext context) {
    return Container(
      width: 250, // Fixed width for consistency
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          elevation: 5,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpScreen(role: 'admin'),
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings, size: 40, color: Colors.red),
            SizedBox(width: 10),
            Text(
              '관리자 회원',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

