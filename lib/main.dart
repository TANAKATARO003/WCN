import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home/bottom_tab_page.dart';
import 'package:home/firebase_options.dart';
import 'package:home/login.dart';
import 'package:home/signup.dart';
import 'package:home/syllabus_scrapingdata.dart';
// import 'package:your_package_name/SignUpPage.dart'; // SignUpPageのパスを正しく設定してください

Future<List<SyllabusScrapingdata>> loadscrapingdata() async {
  final data =
      await rootBundle.loadString('assets/syllabus_scraping_all_cleaned.csv');
  final classlist = data.split('\n')..removeAt(0);
  final syllabusscrapingdata = <SyllabusScrapingdata>[];
  for (final element in classlist) {
    final splitelement = element.split(',');
    syllabusscrapingdata.add(SyllabusScrapingdata(
        splitelement[0],
        splitelement[1],
        splitelement[2],
        splitelement[3],
        splitelement[4],
        splitelement[5],
        splitelement[6]));
  }
  return syllabusscrapingdata;
}

late final List<SyllabusScrapingdata> syllabusscrapingdata;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  syllabusscrapingdata = await loadscrapingdata();
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
