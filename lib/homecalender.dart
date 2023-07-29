import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:home/main.dart';
import 'package:home/syllabus_scrapingdata.dart';
import 'package:home/userdata.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'bottom_tab_page.dart';

class HomeCalendar extends StatefulWidget {
  const HomeCalendar({super.key});

  @override
  _HomeCalendarState createState() => _HomeCalendarState();
}

Future<Uint8List?> fetchurlimage(String name) async {
  return FirebaseStorage.instance.ref('classroom/$name.jpg').getData();
}

class _HomeCalendarState extends State<HomeCalendar>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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
    _tabController = TabController(length: 1, vsync: this);
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

  @override
  Widget build(BuildContext context) {
    var black;
    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List<Widget>.generate(
                1,
                (index) {
                  final date = DateTime.now();
                  final weekdayInJapaneseShort =
                      getWeekdayInJapaneseShort(date.weekday);
                  final monthDay = "${date.month}/${date.day}";

                  final todayschedule = <SyllabusScrapingdata>[];
                  final classsessionnumber = gakunennrekidata
                      .where(
                          (element) => DateUtils.isSameDay(date, element.date))
                      .toList();
                  for (final classsessionnumberone in classsessionnumber) {
                    todayschedule.addAll(userdata?.coursestaken['2023']?.where(
                          (element) =>
                              classsessionnumberone.semesteroffered ==
                                  element.semesteroffered &&
                              (classsessionnumberone.dayofweek ==
                                      element.dayofweek ||
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
                    final aMinPeriod = a.periods.reduce(
                        (value, element) => value < element ? value : element);
                    final bMinDay = b.dayofweeks.reduce((value, element) =>
                        value.compareTo(element) < 0 ? value : element);
                    final bMinPeriod = b.periods.reduce(
                        (value, element) => value < element ? value : element);

                    // 最初に曜日を比較し、その後で時限を比較する
                    final dayComparison = aMinDay.compareTo(bMinDay);
                    if (dayComparison != 0) {
                      return dayComparison;
                    } else {
                      return aMinPeriod.compareTo(bMinPeriod);
                    }
                  });

                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // 縦方向の配置を左寄せに設定
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 20),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '本日の予定',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5), // 登録した履修科目カードとタブバーの間のスペース
                      // 何か引っ張った時の青いやつ消すために追加しました
                      NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (overscroll) {
                          overscroll.disallowGlow();
                          return true;
                        },
                        // 履修科目の記事カード
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          key: UniqueKey(),
                          child: Row(
                            children: todayschedule.isEmpty
                                ? [
                                    SizedBox(height: 40, width: 20),
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
                                          getWeekdayInJapaneseShort(
                                              date.weekday);
                                      final schedule = todayschedule
                                          .where((schedule) => schedule
                                              .dayperiod
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

                                            String classroomText = e
                                                        .classroom.length >
                                                    10
                                                ? '${e.classroom.substring(0, 10)}...'
                                                : e.classroom;

                                            return Container(
                                                width: 320.0,
                                                height: 240.0,
                                                margin: EdgeInsets.only(
                                                  left: 5,
                                                  top: 0,
                                                  bottom: 0,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    BottomTabPage
                                                        .selectCalendarTab(
                                                            context);
                                                  },
                                                  child: Card(
                                                    shadowColor: Colors.grey
                                                        .withOpacity(0.5),
                                                    elevation: 2,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        // 画像表示部分
                                                        FutureBuilder<
                                                            Uint8List?>(
                                                          future: fetchurlimage(
                                                              e.classroom),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .done) {
                                                              if (snapshot
                                                                      .hasData &&
                                                                  snapshot.data !=
                                                                      null) {
                                                                return ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            15.0),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            15.0),
                                                                  ),
                                                                  child: Image
                                                                      .memory(
                                                                    snapshot
                                                                        .data!,
                                                                    width: 320,
                                                                    height: 140,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                );
                                                              } else {
                                                                // Firebase Storageからnoimage2.pngを試みる
                                                                return FutureBuilder<
                                                                    Uint8List?>(
                                                                  future: fetchurlimage(
                                                                      "noimage2.png"),
                                                                  builder: (context,
                                                                      secondarySnapshot) {
                                                                    if (secondarySnapshot
                                                                            .connectionState ==
                                                                        ConnectionState
                                                                            .done) {
                                                                      if (secondarySnapshot
                                                                              .hasData &&
                                                                          secondarySnapshot.data !=
                                                                              null) {
                                                                        return Image
                                                                            .memory(
                                                                          secondarySnapshot
                                                                              .data!,
                                                                          width:
                                                                              320,
                                                                          height:
                                                                              140,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        );
                                                                      } else {
                                                                        // assetsからnoimage2.pngを試みる
                                                                        return ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(15.0),
                                                                            topRight:
                                                                                Radius.circular(15.0),
                                                                          ),
                                                                          child:
                                                                              Image.asset(
                                                                            'assets/noimage2.png',
                                                                            width:
                                                                                320,
                                                                            height:
                                                                                140,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        );
                                                                      }
                                                                    } else {
                                                                      return Container(
                                                                        width:
                                                                            320,
                                                                        height:
                                                                            140,
                                                                        color: Colors
                                                                            .grey
                                                                            .withOpacity(0.5),
                                                                        child: Center(
                                                                            child:
                                                                                Container()),
                                                                      );
                                                                    }
                                                                  },
                                                                );
                                                              }
                                                            } else {
                                                              return Container(
                                                                width: 320,
                                                                height: 140,
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.5),
                                                                child: Center(
                                                                    child:
                                                                        Container()),
                                                              );
                                                            }
                                                          },
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 15,
                                                                  horizontal:
                                                                      15),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .baseline,
                                                                textBaseline:
                                                                    TextBaseline
                                                                        .alphabetic, // これで欧文ベースラインを実現
                                                                children: [
                                                                  Text(
                                                                    timeText,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Color(
                                                                          0xffed6102),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          10),
                                                                  Text(
                                                                    '$startTimeText',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    ' - ',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '$endTimeText',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  ),
                                                                  Spacer(),
                                                                  Text(
                                                                    classroomText,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: Color(
                                                                          0xFF707070),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height: 10),
                                                              // 科目名とsvgアイコン。カードからはみ出ないように判定している
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child:
                                                                    LayoutBuilder(
                                                                  builder: (BuildContext
                                                                          context,
                                                                      BoxConstraints
                                                                          constraints) {
                                                                    final maxWidthForText = constraints
                                                                            .maxWidth -
                                                                        16.0 -
                                                                        7.5; // SVGの幅と間隔を引きます

                                                                    return Row(
                                                                      children: [
                                                                        SvgPicture
                                                                            .asset(
                                                                          e.courseofferedby == '共通'
                                                                              ? 'assets/com.svg'
                                                                              : 'assets/other.svg',
                                                                          width:
                                                                              16.0,
                                                                          height:
                                                                              16.0,
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                7.5),
                                                                        ConstrainedBox(
                                                                          constraints:
                                                                              BoxConstraints(
                                                                            maxWidth:
                                                                                maxWidthForText,
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            e.course,
                                                                            overflow:
                                                                                TextOverflow.ellipsis, // テキストが長すぎて表示できない場合、末尾に...を表示します
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w700,
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
                                                      ],
                                                    ),
                                                  ),
                                                ));
                                            return SizedBox();
                                          })
                                        ],
                                      );
                                    },
                                  ).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
