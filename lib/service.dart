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

    // タブコントローラの初期化
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: AppBar(
          title: Text(
            "サービス",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          shadowColor: Colors.grey.withOpacity(0.5),
          backgroundColor: Colors.white,
          elevation: 1.5,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: TabBar(
              controller: _tabController,

              // タブインジケータの色
              indicatorColor: Color(0xffed6102),

              // タブインジケータのサイズ
              indicatorSize: TabBarIndicatorSize.tab,

              // タブインジケータの太さ
              indicatorWeight: 3.0,

              // タブスクロールの有効化
              isScrollable: false,

              // 選択されたタブのテキスト色
              labelColor: Colors.black,

              // 選択されていないタブのテキスト色
              unselectedLabelColor: Color(0xff808080),
              labelPadding: EdgeInsets.all(0),
              tabs: <Widget>[
                Tab(
                  child: Text(
                    '施設利用可能時間',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
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
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Container(), // '施設利用可能時間'タブのための空のコンテナ
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      // 第一食堂ページに移動
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => FirstCafeteriaPage()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '第一食堂',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),

                        // 右端から20の位置に配置される矢印アイコン
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),

                      // ボタンの背景色
                      primary: Colors.white,

                      // ボタン内のテキスト色
                      onPrimary: Colors.black,

                      // ボタンの幅をパディングを除いた領域まで拡張
                      minimumSize: Size(
                        double.infinity,
                        50,
                      ),
                    ),
                  ),

                  // ボタン間のスペース
                  SizedBox(height: 20.0),

                  ElevatedButton(
                    onPressed: () {
                      // GENKI食堂ページに移動
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => GenkiCafeteriaPage()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'ＧＥＮＫＩ食堂',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),

                        // 右端から20の位置に配置される矢印アイコン
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),

                      // ボタンの背景色
                      primary: Colors.white,

                      // ボタン内のテキスト色
                      onPrimary: Colors.black,

                      // ボタンの幅をパディングを除いた領域まで拡張
                      minimumSize: Size(
                        double.infinity,
                        50,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
