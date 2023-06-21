import 'package:flutter/material.dart';

// ユーザー投稿ウィジェット
class User extends StatefulWidget {
  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    // 5つのタブを持つTabControllerを初期化
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    // TabControllerをdispose（解放）する
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0),  // 背景色を設定。色を変えたい場合はこの値を変更
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: AppBar(
          title: Text(
            "ユーザー投稿",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),  // タイトルのスタイル設定
          ),
          shadowColor: Colors.grey.withOpacity(0.5),  // 影の色と透明度を設定
          backgroundColor: Colors.white,  // AppBarの背景色を設定
          elevation: 1.5,  // AppBarの影の高さを「1.5」に設定
          centerTitle: true,  // タイトルを中央に配置
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Color(0xffed6102),  // インジケータの色を設定
              indicatorSize: TabBarIndicatorSize.tab,  // インジケータのサイズを設定
              indicatorWeight: 3.0,  // インジケータの太さを設定
              isScrollable: false,  // スクロール可能かを設定
              labelColor: Colors.black,  // ラベルの色を設定
              unselectedLabelColor: Color(0xff808080),  // 未選択ラベルの色を設定
              labelPadding: EdgeInsets.all(0),  // タブラベル周辺の余白を削除
              // タブの設定
              tabs: <Widget>[
                // 新着タブ
                Tab(
                  child: Text(
                    '新着',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                // イベントタブ
                Tab(
                  child: Text(
                    'イベント',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                // 調査/投票タブ
                Tab(
                  child: Text(
                    '調査/投票',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                // 学作紹介タブ
                Tab(
                  child: Text(
                    '学作紹介',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                // 課外活動タブ
                Tab(
                  child: Text(
                    '課外活動',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: Text(
          "user",
          style: TextStyle(fontSize: 20),  // テキストのスタイルを設定
        ),
      ),
    );
  }
}
