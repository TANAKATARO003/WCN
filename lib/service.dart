import 'package:flutter/material.dart';

class Service extends StatefulWidget {
  @override
  _ServiceState createState() => _ServiceState();
}

class _ServiceState extends State<Service> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    // 3つのタブを持つTabControllerを初期化
    _tabController = TabController(length: 3, vsync: this);
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
      backgroundColor: Color(0xFFF0F0F0),  // 背景色を「#f0f0f0」に設定
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: AppBar(
          title: Text(
            "サービス",
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
                // 図書館タブ
                Tab(
                  child: Text(
                    '図書館',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                // 購買タブ
                Tab(
                  child: Text(
                    '購買',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                // 食堂タブ
                Tab(
                  child: Text(
                    '食堂',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          Center(child: Text('図書館', style: TextStyle(fontSize: 50))),
          Center(child: Text('購買', style: TextStyle(fontSize: 50))),
          Center(child: Text('食堂', style: TextStyle(fontSize: 50))),
        ],
      ),
    );
  }
}
