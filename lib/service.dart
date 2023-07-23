import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
                    '食堂メニュー',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                Tab(
                  child: Text(
                    '施設利用可能時間',
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DaiichiPage()));
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => GenkiCafeteriaPage()));
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
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => GenkiPage()));
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
            Container(), // '施設利用可能時間'タブのための空のコンテナ
          ],
        ),
      ),
    );
  }
}

// Firestoreのgenkiコレクションから全メニューカテゴリのデータを取得する関数
Future<Map<String, List<Map<String, dynamic>>>> getAllGenkiCategories() async {
  DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('genki').doc('genki').get();
  Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

  Map<String, List<Map<String, dynamic>>> categories = {};

  for (var category in [
    'maindish',
    'sidedish',
    'noodles',
    'ricebowlcurry',
    'dessert'
  ]) {
    categories[category] =
        List<Map<String, dynamic>>.from(data?[category] ?? []);
  }

  return categories;
}

// Firestoreのdaiichiコレクションから全メニューカテゴリのデータを取得する関数
Future<Map<String, List<Map<String, dynamic>>>>
    getAllDaiichiCategories() async {
  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('daiichi')
      .doc('daiichi')
      .get();
  Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

  Map<String, List<Map<String, dynamic>>> categories = {};

  for (var category in [
    'maindish',
    'sidedish',
    'noodles',
    'ricebowlcurry',
    'dessert'
  ]) {
    categories[category] =
        List<Map<String, dynamic>>.from(data?[category] ?? []);
  }

  return categories;
}

// 各カテゴリごとのアイコン判定
IconData getIconForCategory(String category) {
  switch (category) {
    case '主菜／Main dish':
      return Icons.restaurant_menu;
    case '副菜／Side dish':
      return Icons.restaurant_menu;
    case '麺類／Noodles':
      return Icons.dinner_dining;
    case '丼・カレー／Rice bowl & Curry':
      return Icons.rice_bowl;
    case 'デザート／Dessert':
      return Icons.cake;
    default:
      return Icons.restaurant_menu; // これがデフォルトのアイコン
  }
}

// カテゴリ名の対応を保持するマップ
Map<String, String> categoryNames = {
  'maindish': '主菜／Main dish',
  'sidedish': '副菜／Side dish',
  'noodles': '麺類／Noodles',
  'ricebowlcurry': '丼・カレー／Rice bowl & Curry',
  'dessert': 'デザート／Dessert'
};

// メニュー名から「(※)」もしくは「（※）」を削除する関数
String removeSpecialTag(String name) {
  // 「(※)」を含む場合はそれを削除し、含まない場合はそのままの文字列を返す
  String updatedName = name.replaceAll(RegExp(r'\(※\)|（※）'), '').trim();
  return updatedName;
}

// ＧＥＮＫＩ食堂のページ
class GenkiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "ＧＥＮＫＩ食堂",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        shadowColor: Colors.grey.withOpacity(0.5),
        backgroundColor: Colors.white,
        elevation: 1.5,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: getAllGenkiCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // ローディング表示を画面中央に配置
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Data Found'));
          } else {
            List<Widget> items = [];
            for (var category in [
              'maindish',
              'sidedish',
              'noodles',
              'ricebowlcurry',
              'dessert'
            ]) {
              var dataList = snapshot.data![category]!;
              if (dataList.isNotEmpty) {
                // カテゴリの中身がある場合のみカテゴリ名と内容を追加
                items.add(SizedBox(height: 15)); // カテゴリー名とその１個上の要素の間のスペース
                items.add(Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Icon(getIconForCategory(categoryNames[category]!),
                            color: Color(0xFFed6102), size: 24.0),
                        SizedBox(width: 5.0),
                        Text(
                          categoryNames[category]!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
                for (var item in dataList) {
                  items.add(
                    Card(
                      shadowColor: Colors.grey.withOpacity(0.5),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      child: Container(
                        height: 100,
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Image.asset(
                                'assets/noimage.png',
                                width: 120,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    removeSpecialTag(item['name']),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2.5),
                                  Text(
                                    item['english'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 7.5),
                                  Text(
                                    item['price'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                // 各カテゴリの最後のカードの後にSizedBoxを追加
                items.add(SizedBox(height: 20.0));
              }
            }

            return ListView(children: items);
          }
        },
      ),
    );
  }
}

// 第一食堂のページ
class DaiichiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "第一食堂",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        shadowColor: Colors.grey.withOpacity(0.5),
        backgroundColor: Colors.white,
        elevation: 1.5,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: getAllDaiichiCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // ローディング表示を画面中央に配置
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Data Found'));
          } else {
            List<Widget> items = [];
            for (var category in [
              'maindish',
              'sidedish',
              'noodles',
              'ricebowlcurry',
              'dessert'
            ]) {
              var dataList = snapshot.data![category]!;
              if (dataList.isNotEmpty) {
                // カテゴリの中身がある場合のみカテゴリ名と内容を追加
                items.add(SizedBox(height: 15)); // カテゴリー名とその１個上の要素の間のスペース
                items.add(Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Icon(getIconForCategory(categoryNames[category]!),
                            color: Color(0xFFed6102), size: 24.0),
                        SizedBox(width: 5.0),
                        Text(
                          categoryNames[category]!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
                for (var item in dataList) {
                  items.add(
                    Card(
                      shadowColor: Colors.grey.withOpacity(0.5),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      child: Container(
                        height: 100,
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Image.asset(
                                'assets/noimage.png',
                                width: 120,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    removeSpecialTag(item['name']),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2.5),
                                  Text(
                                    item['english'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 7.5),
                                  Text(
                                    item['price'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                // 各カテゴリの最後のカードの後にSizedBoxを追加
                items.add(SizedBox(height: 20.0));
              }
            }

            return ListView(children: items);
          }
        },
      ),
    );
  }
}
