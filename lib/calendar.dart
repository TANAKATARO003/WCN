import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// カレンダーのウィジェット
class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    // 5つのタブを持つTabControllerを初期化
    _tabController = TabController(length: 5, vsync: this);
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // TabControllerをdispose（解放）する
    _tabController?.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  // 英語の曜日を日本語の短縮形に変換
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
    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0), // 背景色を設定。色を変えたい場合はこの値を変更
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: AppBar(
          title: Text(
            "カレンダー",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black), // タイトルのスタイル設定
          ),
          shadowColor: Colors.grey.withOpacity(0.5), // 影の色と透明度を設定
          backgroundColor: Colors.white, // AppBarの背景色を設定
          elevation: 1.5, // AppBarの影の高さを「1.5」に設定
          centerTitle: true, // タイトルを中央に配置
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Color(0xffed6102), // インジケータの色を設定
              indicatorSize: TabBarIndicatorSize.tab, // インジケータのサイズを設定
              indicatorWeight: 3.0, // インジケータの太さを設定
              isScrollable: false, // スクロール可能かを設定
              labelColor: Colors.black, // ラベルの色を設定
              unselectedLabelColor: Color(0xff808080), // 未選択ラベルの色を設定
              labelPadding: EdgeInsets.all(0), // タブラベル周辺の余白を削除
              tabs: List<Widget>.generate(
                5, // タブの数を設定
                (index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final weekdayInJapaneseShort =
                      getWeekdayInJapaneseShort(date.weekday);
                  final monthDay = "${date.month}/${date.day}";

                  return Container(
                    width:
                        MediaQuery.of(context).size.width / 5, // スクリーンの幅を5で割る
                    child: Tab(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: '${monthDay.split('/')[0]}/', // 月日の月部分を設定
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                            TextSpan(
                              text: '${monthDay.split('/')[1]}', // 月日の日部分を設定
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            ),
                            TextSpan(
                              text: '\u2009($weekdayInJapaneseShort)', // 曜日を設定
                              style:
                                  TextStyle(fontSize: 10, color: Colors.black),
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
      body: Container(
        child: TabBarView(
          controller: _tabController,
          children: [
            Container(),
            Container(),
            Container(),
            Container(),
            Container(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddPostDialog(context);
          myFocusNode.requestFocus();
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xffed6102), // 任意のカラーコードを設定
      ),
    );
  }

  void _showAddPostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('講義の登録'),
                  TextFormField(
                    focusNode: myFocusNode,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: '講義名',
                    ),
                    onChanged: (text) async {
                      await FirebaseFirestore.instance
                          .collection('classes')
                          .add({
                        'name': '$text',
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
