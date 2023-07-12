import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:holiday_jp/holiday_jp.dart' as holiday_jp;
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
              isScrollable: false,
              labelColor: Colors.black,
              unselectedLabelColor: Color(0xff808080),
              labelPadding: EdgeInsets.all(0),
              tabs: List<Widget>.generate(
                5,
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
    );
  }
}
