import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home/bottom_tab_page.dart';
import 'package:home/firebase_options.dart';
import 'package:home/gakunennreki_data.dart';
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
        splitelement[6],
        splitelement[7]));
  }
  return syllabusscrapingdata;
}

late final List<SyllabusScrapingdata> syllabusscrapingdata;

Future<List<GakunennrekiData>> loadgakunennrekidata() async {
  final data = await rootBundle.loadString('assets/gakunennreki.csv');
  final classlist = data.split('\r\n');
  final gakunennrekidata = <GakunennrekiData>[];
  for (final element in classlist) {
    final splitelement = element.split(',');
    final date = DateTime(int.parse(splitelement[0]),
        int.parse(splitelement[1]), int.parse(splitelement[2]));
    final q1 = splitelement[3];
    if (q1.isNotEmpty) {
      final dayofweek = q1.substring(0, 1);
      final numberoftimes = int.parse(q1.substring(1, q1.length));
      gakunennrekidata
          .add(GakunennrekiData(date, '1Q', dayofweek, numberoftimes));
    }
    final q2 = splitelement[4];
    if (q2.isNotEmpty) {
      final dayofweek = q2.substring(0, 1);
      final numberoftimes = int.parse(q2.substring(1, q2.length));
      gakunennrekidata
          .add(GakunennrekiData(date, '2Q', dayofweek, numberoftimes));
    }
    final former = splitelement[5];
    if (former.isNotEmpty) {
      final dayofweek = former.substring(0, 1);
      final numberoftimes = int.parse(former.substring(1, former.length));
      gakunennrekidata
          .add(GakunennrekiData(date, '前期', dayofweek, numberoftimes));
    }
    final q3 = splitelement[6];
    if (q3.isNotEmpty) {
      final dayofweek = q3.substring(0, 1);
      final numberoftimes = int.parse(q3.substring(1, q3.length));
      gakunennrekidata
          .add(GakunennrekiData(date, '3Q', dayofweek, numberoftimes));
    }
    final q4 = splitelement[7];
    if (q4.isNotEmpty) {
      final dayofweek = q4.substring(0, 1);
      final numberoftimes = int.parse(q4.substring(1, q4.length));
      gakunennrekidata
          .add(GakunennrekiData(date, '4Q', dayofweek, numberoftimes));
    }
    final latter = splitelement[8];
    if (latter.isNotEmpty) {
      final dayofweek = latter.substring(0, 1);
      final numberoftimes = int.parse(latter.substring(1, latter.length));
      gakunennrekidata
          .add(GakunennrekiData(date, '後期', dayofweek, numberoftimes));
    }
  }
  return gakunennrekidata;
}

late final List<GakunennrekiData> gakunennrekidata;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  syllabusscrapingdata = await loadscrapingdata();
  gakunennrekidata = await loadgakunennrekidata();
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
