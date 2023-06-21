import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:home/bottom_tab_page.dart';
import 'package:home/firebase_options.dart';
import 'package:home/login.dart';
import 'package:home/signup.dart';
// import 'package:your_package_name/SignUpPage.dart'; // SignUpPageのパスを正しく設定してください

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFFFFFFFF),
        fontFamily: 'Zen_Kaku_Gothic_New',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SignUpPage(),
      routes: <String, WidgetBuilder>{
        "/Login": (BuildContext context) => LoginPage(),
        // "/SignUp": (BuildContext context) => SignUpPage(),  // SignUpPageのクラスが作成されていればコメントを外してください
      },
    );
  }
}
