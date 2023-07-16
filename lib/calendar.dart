import 'package:flutter/material.dart';
import 'package:home/main.dart';
import 'package:home/syllabus_scrapingdata.dart';
import 'package:home/userdata.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:holiday_jp/holiday_jp.dart' as holiday_jp;

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // 開講科目名と主担当教員のコントローラー
  final _courseController = TextEditingController();
  final _maininstructorController = TextEditingController();

  // 開講科目名候補のリスト
  final coursePredicts = ValueNotifier<List<SyllabusScrapingdata>>([]);

  // 選択された開講科目を追跡するための ValueNotifier
  final selectedCourse = ValueNotifier<SyllabusScrapingdata?>(null);

  UserData? userdata;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 14, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
        // <-- SingleChildScrollViewを追加します
        child: Column(
          children: <Widget>[
            // 重要なお知らせセクション
            GestureDetector(
              onTap: _launchURL,
              child: Container(
                color: Color(0xFFFFFFFF),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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
                    SizedBox(height: 4),
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
                              Text(
                                '教育サポートシステムでご確認ください。',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // 他のウィジェットをここに追加できます
          ],
        ),
      ),
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
                        labelText: '主担当教員（姓名の間は半角スペース）',
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
                          return '主担当教員を入力してください';
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
                                    selectedCourse.value = coursePredicts
                                        .value[index]; // 選択されたアイテムを保存。これを使用して登録
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
                                            coursePredicts
                                                .value[index].semesteroffered +
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
                      onPressed: () {},
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
            );
          },
        );
      },
    );
  }
}
