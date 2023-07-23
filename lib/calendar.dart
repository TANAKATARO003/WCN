import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home/main.dart';
import 'package:home/syllabus_scrapingdata.dart';
import 'package:home/userdata.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:holiday_jp/holiday_jp.dart' as holiday_jp;
import 'package:flutter_svg/flutter_svg.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  _CalendarState createState() => _CalendarState();
}

bool _isAnnouncementVisible = true; // この変数でお知らせセクションの表示状態を管理

class _CalendarState extends State<Calendar>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // 重要なお知らせセクションの表示と非表示
  void _toggleAnnouncement() {
    setState(() {
      _isAnnouncementVisible = !_isAnnouncementVisible;
    });
  }

  // 開講科目名と主担当教員のコントローラー
  final _courseController = TextEditingController();
  final _maininstructorController = TextEditingController();

  // 開講科目名候補のリスト
  final coursePredicts = ValueNotifier<List<SyllabusScrapingdata>>([]);

  // 選択された開講科目を追跡するための ValueNotifier
  final selectedCourse = ValueNotifier<SyllabusScrapingdata?>(null);

  UserData? userdata;
  StreamSubscription? subuser;
  void subscribeuserdata() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    subuser = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((event) {
      userdata = UserData.fromfirestore(event);
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 14, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    subscribeuserdata();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
    subuser?.cancel();
  }

  String getWeekdayInJapaneseShort(int weekday) {
    switch (weekday) {
      case 1:
        return "月";
      case 2:
        return "火";
      case 3:
        return "水";
      case 4:
        return "木";
      case 5:
        return "金";
      case 6:
        return "土";
      case 7:
        return "日";
      default:
        return "";
    }
  }

  final Uri _url = Uri.parse(
      'https://kmags.wakayama-u.ac.jp/campusweb/campussmart.do?page=main&tabId=kh');

  void _launchURL() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    var black;
    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: AppBar(
          title: Text(
            "カレンダー",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          shadowColor: Colors.grey.withOpacity(0.5),
          backgroundColor: Colors.white,
          elevation: 1.5,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Color(0xffed6102),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3.0,
              isScrollable: true,
              labelColor: Colors.black,
              unselectedLabelColor: Color(0xff808080),
              labelPadding: EdgeInsets.all(0),
              tabs: List<Widget>.generate(
                14,
                (index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final weekdayInJapaneseShort =
                      getWeekdayInJapaneseShort(date.weekday);
                  final monthDay = "${date.month}/${date.day}";

                  return Container(
                    width: MediaQuery.of(context).size.width / 5,
                    child: Tab(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: '${monthDay.split('/')[0]}/',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                            TextSpan(
                              text: '${monthDay.split('/')[1]}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            TextSpan(
                              text: '\u2009' + '($weekdayInJapaneseShort)',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: holiday_jp.isHoliday(date) ||
                                          date.weekday == 7
                                      ? Color(
                                          0xffe72f2f) // For Sunday and Holidays
                                      : date.weekday == 6
                                          ? Color(0xff0081b7) // For Saturday
                                          : Colors.black // For other days
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      body: Builder(builder: (context) {
        final index = _tabController.index;
        final date = DateTime.now().add(Duration(days: index));
        final weekdayInJapaneseShort = getWeekdayInJapaneseShort(date.weekday);
        final monthDay = "${date.month}/${date.day}";

        final todayschedule = <SyllabusScrapingdata>[];
        final classsessionnumber = gakunennrekidata
            .where((element) => DateUtils.isSameDay(date, element.date))
            .toList();
        for (final classsessionnumberone in classsessionnumber) {
          todayschedule.addAll(userdata?.coursestaken['2023']?.where(
                (element) =>
                    classsessionnumberone.semesteroffered ==
                        element.semesteroffered &&
                    (classsessionnumberone.dayofweek == element.dayofweek ||
                        classsessionnumberone.dayofweek ==
                            element.dayofweek2) &&
                    classsessionnumberone.numberoftimes <=
                        element.numberoftimesint,
              ) ??
              []);
        }
        // syllabus_scrapingdata.dartのperiodという何時間目の授業なのかのゲッターでソート
        todayschedule.sort((a, b) {
          // 各授業の最小の曜日と時限を見つける
          final aMinDay = a.dayofweeks.reduce((value, element) =>
              value.compareTo(element) < 0 ? value : element);
          final aMinPeriod = a.periods
              .reduce((value, element) => value < element ? value : element);
          final bMinDay = b.dayofweeks.reduce((value, element) =>
              value.compareTo(element) < 0 ? value : element);
          final bMinPeriod = b.periods
              .reduce((value, element) => value < element ? value : element);

          // 最初に曜日を比較し、その後で時限を比較する
          final dayComparison = aMinDay.compareTo(bMinDay);
          if (dayComparison != 0) {
            return dayComparison;
          } else {
            return aMinPeriod.compareTo(bMinPeriod);
          }
        });

        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // 重要なお知らせセクション
              if (_isAnnouncementVisible)
                Container(
                  color: Color(0xFFFFFFFF),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xffed6102),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            padding: EdgeInsets.fromLTRB(10.0, 2.5, 10.0, 5.0),
                            child: Text(
                              '重要なお知らせ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          // 修正後のアイコンボタン
                          IconButton(
                            padding: EdgeInsets.zero, // 追加: パディングをゼロに設定
                            constraints:
                                const BoxConstraints(), // デフォルトで設定されているBoxConstrainsを0にする（最重要）
                            icon: Icon(Icons.cancel),
                            iconSize: 29,
                            onPressed: _toggleAnnouncement,
                          ),
                        ],
                      ),
                      SizedBox(height: 4.0), // スペース確保
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '授業の休講・掲示情報は',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  // 2つのテキストを左右揃えでそれぞれ表示
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      '教育サポートシステムでご確認ください。',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _launchURL,
                                      child: Text(
                                        '開く',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 15), // 履修科目という文字とタブバーの間のスペース
              Container(
                margin: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '履修科目',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5), // 登録した履修科目カードとタブバーの間のスペース
              // 履修科目の記事カード
              GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("確認"),
                          content: Text("選択した授業の名前" + "の登録を削除しますか？"),
                          actions: [
                            TextButton(
                              child: Text("はい"),
                              onPressed: () {
                                final course = selectedCourse.value;
                                if (course != null) {
                                  final syllabuslist =
                                      userdata?.coursestaken['2023'] ?? [];

                                  // タップされた授業のインデックスを特定
                                  final indexToRemove =
                                      syllabuslist.indexOf(course);

                                  // インデックスがリスト内に存在する場合、そのインデックスの授業を削除
                                  if (indexToRemove != -1) {
                                    syllabuslist.removeAt(indexToRemove);
                                  }

                                  // 更新されたリストをFirestoreに保存
                                  userdata?.reference.update({
                                    'coursestaken.2023': syllabuslist
                                  }).then((_) {
                                    print("Firestore update successful");
                                  }).catchError((error) {
                                    print("Error updating Firestore: $error");
                                  });
                                }
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text(
                                "いいえ",
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      });
                },
                child: Column(
                  children: todayschedule.isEmpty
                      ? [
                          SizedBox(height: 40),
                          Center(
                            child: Text(
                              '本日の履修科目は登録されていません。',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ]
                      : ['1', '2', '3', '4', '5', '6'].map(
                          (p) {
                            String todayweekday =
                                getWeekdayInJapaneseShort(date.weekday);
                            final schedule = todayschedule
                                .where((schedule) => schedule.dayperiod
                                    .contains('$todayweekday$p'))
                                .toList();
                            return Column(
                              children: [
                                ...schedule.map((e) {
                                  String timeText = '';
                                  String startTimeText = '';
                                  String endTimeText = '';

                                  switch (p) {
                                    case '1':
                                      timeText = '１限';
                                      startTimeText = '9:10';
                                      endTimeText = '10:50';
                                      break;
                                    case '2':
                                      timeText = '２限';
                                      startTimeText = '10:50';
                                      endTimeText = '12:20';
                                      break;
                                    case '3':
                                      timeText = '３限';
                                      startTimeText = '13:10';
                                      endTimeText = '14:40';
                                      break;
                                    case '4':
                                      timeText = '４限';
                                      startTimeText = '14:50';
                                      endTimeText = '16:20';
                                      break;
                                    case '5':
                                      timeText = '５限';
                                      startTimeText = '16:30';
                                      endTimeText = '18:00';
                                      break;
                                    case '6':
                                      timeText = '６限';
                                      startTimeText = '18:10';
                                      endTimeText = '19:40';
                                      break;
                                    default:
                                      timeText = '';
                                      startTimeText = '';
                                      endTimeText = '';
                                      break;
                                  }

                                  String classroomText = e.classroom.length > 12
                                      ? '${e.classroom.substring(0, 12)}...'
                                      : e.classroom;

                                  return Container(
                                    width: double.infinity,
                                    height: 100,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 1, horizontal: 15),
                                    child: Card(
                                      shadowColor: Colors.grey.withOpacity(0.5),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.baseline,
                                              textBaseline: TextBaseline
                                                  .alphabetic, // これで欧文ベースラインを実現
                                              children: [
                                                Text(
                                                  timeText,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xffed6102),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  '$startTimeText',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Text(
                                                  ' - ',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Text(
                                                  '$endTimeText',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Spacer(),
                                                Text(
                                                  classroomText,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFF707070),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            // 科目名とsvgアイコン。カードからはみ出ないように判定している
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: LayoutBuilder(
                                                builder: (BuildContext context,
                                                    BoxConstraints
                                                        constraints) {
                                                  final maxWidthForText =
                                                      constraints.maxWidth -
                                                          16.0 -
                                                          7.5; // SVGの幅と間隔を引きます

                                                  return Row(
                                                    children: [
                                                      SvgPicture.asset(
                                                        e.courseofferedby ==
                                                                '共通'
                                                            ? 'assets/com.svg'
                                                            : 'assets/other.svg',
                                                        width: 16.0,
                                                        height: 16.0,
                                                      ),
                                                      SizedBox(width: 7.5),
                                                      ConstrainedBox(
                                                        constraints:
                                                            BoxConstraints(
                                                          maxWidth:
                                                              maxWidthForText,
                                                        ),
                                                        child: Text(
                                                          e.course,
                                                          overflow: TextOverflow
                                                              .ellipsis, // テキストが長すぎて表示できない場合、末尾に...を表示します
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                  return SizedBox();
                                })
                              ],
                            );
                          },
                        ).toList(),
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPostDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Color(0xffed6102), // 任意のカラーコードを設定
      ),
    );
  }

  // 履修科目登録ダイアログを表示するメソッド
  void _showAddPostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ValueListenableBuilder(
          valueListenable: coursePredicts,
          builder: (context, value, child) {
            return AlertDialog(
              content: Container(
                width:
                    MediaQuery.of(context).size.width - 20.0, // ポップアップウィンドウの横幅
                // SingleChildScrollViewで囲うことによって、リストがダイアログからはみ出ない
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '履修科目の日程を登録',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '開講科目名と主担当教員名を入力し、検索して選択することでカレンダーに登録できます。',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),

                      SizedBox(height: 20), // 説明と入力フィールドの間のスペース

                      TextFormField(
                        controller: _courseController,
                        decoration: InputDecoration(
                          labelText: '開講科目名',
                          labelStyle: TextStyle(
                            // ラベルのスタイルを設定
                            fontSize: 15.0, // フォントサイズを15に設定
                          ),
                        ),
                        maxLength: 40,
                        onChanged: (text) {
                          // 開講科目名または主担当教員のテキストが空でない場合
                          if (text.isNotEmpty ||
                              _maininstructorController.text.isNotEmpty) {
                            // 開講科目名と主担当教員の両方を考慮した検索を行う
                            coursePredicts.value = syllabusscrapingdata
                                .where((element) =>
                                    (element.course.contains(
                                            text) || // 開講科目名が検索クエリを含むか、または検索クエリが空である
                                        text.isEmpty) &&
                                    (element.maininstructor.contains(
                                            _maininstructorController
                                                .text) || // 主担当教員が検索クエリを含むか、または検索クエリが空である
                                        _maininstructorController.text.isEmpty))
                                .toList();
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '開講科目名を入力してください';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _maininstructorController,
                        decoration: InputDecoration(
                          labelText: '主担当教員名　※姓名間は半角スペース',
                          labelStyle: TextStyle(
                            // ラベルのスタイルを設定
                            fontSize: 15.0, // フォントサイズを15に設定
                          ),
                        ),
                        maxLength: 40,
                        onChanged: (text) {
                          // 主担当教員または開講科目名のテキストが空でない場合
                          if (text.isNotEmpty ||
                              _courseController.text.isNotEmpty) {
                            // 開講科目名と主担当教員の両方を考慮した検索を行う
                            coursePredicts.value = syllabusscrapingdata
                                .where((element) =>
                                    (element.course.contains(_courseController
                                            .text) || // 開講科目名が検索クエリを含むか、または検索クエリが空である
                                        _courseController.text.isEmpty) &&
                                    (element.maininstructor.contains(
                                            text) || // 主担当教員が検索クエリを含むか、または検索クエリが空である
                                        text.isEmpty))
                                .toList();
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '主担当教員名を入力してください';
                          }
                          return null;
                        },
                      ),

                      // 入力フィールドと候補リストの間のスペース
                      SizedBox(height: 10.0),

                      Container(
                        height: coursePredicts.value.isEmpty
                            ? 0
                            : 40, // 入力前はリストと同じで見えないように
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${coursePredicts.value.length}件の候補が見つかりました。',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xff0081b7), // 候補件数の文字色
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),

                      Container(
                        height: coursePredicts.value.isEmpty
                            ? 0
                            : 240, // 入力前はリストの幅を占有しない
                        child: Scrollbar(
                          // ValueListenableBuilder を Scrollbar の child として追加
                          child: ValueListenableBuilder(
                            valueListenable: selectedCourse,
                            builder: (context, value, child) {
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: coursePredicts.value.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      selectedCourse.value =
                                          coursePredicts.value[
                                              index]; // 選択されたアイテムを保存。これを使用して登録
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2.5, horizontal: 0.0),
                                      color: value ==
                                              coursePredicts.value[
                                                  index] // 選択されたアイテムの場合、色を変更
                                          ? Colors.blue[100]
                                          : index % 2 == 0
                                              ? Colors.grey[200]
                                              : Colors.grey[50], // リストの色を互い違いに
                                      child: ListTile(
                                        title: Text(
                                          coursePredicts.value[index].course +
                                              '（' +
                                              coursePredicts.value[index]
                                                  .semesteroffered +
                                              ', ' +
                                              coursePredicts
                                                  .value[index].dayperiod +
                                              ', ' +
                                              coursePredicts
                                                  .value[index].maininstructor +
                                              '）',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        trailing: value ==
                                                coursePredicts.value[
                                                    index] // 選択されたアイテムの場合、アイコンを表示
                                            ? Icon(Icons.check_circle,
                                                color: Colors.green)
                                            : null, // 選択した時のチェックマーク
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),

                      // 候補リストとボタンの間のスペース
                      SizedBox(height: 20.0),

                      ElevatedButton(
                        onPressed: () {
                          final course = selectedCourse.value;
                          if (course == null) {
                            return;
                          }
                          final syllabuslist = userdata?.coursestaken['2023'];
                          if (syllabuslist == null) {
                            userdata?.coursestaken['2023'] = [course];
                          } else {
                            userdata?.coursestaken['2023']!.add(course);
                          }
                          userdata?.reference.update(userdata!.tomap());
                          Navigator.pop(context);
                        },
                        child: Text(
                          '登録する',
                          style: TextStyle(
                            color: Colors.white, // ボタンのテキスト色を設定
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffed6102), // ボタンの背景色を設定
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
