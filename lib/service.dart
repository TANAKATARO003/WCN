import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:home/facilitytime_data.dart';
import 'package:home/main.dart';

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

  // 施設利用可能時間を表示するモノ
  Widget showFacilityTime(List<FacilityTimeData> facilitytimedata) {
    // 現在の日付を取得
    final nowdate = DateTime.now();

    // 今日の施設利用可能時間を取得
    List<FacilityTimeData> todayData = facilitytimedata
        .where((data) =>
            data.date.year == nowdate.year &&
            data.date.month == nowdate.month &&
            data.date.day == nowdate.day)
        .toList();

    // カードリストを作成
    List<Widget> cards = [];

    // カードの一番上に追加する要素
    cards.add(SizedBox(height: 15)); // カードとAppBarの間のスペース

    // 各施設ごとにカードを作成してリストに追加
    if (todayData.isNotEmpty) {
      if (todayData.first.library.isNotEmpty) {
        cards.add(createFacilityCard('図書館', todayData.first.library));
      }
      if (todayData.first.daiiti.isNotEmpty) {
        cards.add(createFacilityCard('第一食堂', todayData.first.daiiti));
      }
      if (todayData.first.genki.isNotEmpty) {
        cards.add(createFacilityCard('ＧＥＮＫＩ食堂', todayData.first.genki));
      }
      if (todayData.first.takeout.isNotEmpty) {
        cards.add(createFacilityCard('テイクアウトショップ', todayData.first.takeout));
      }
      if (todayData.first.syoseki.isNotEmpty) {
        cards.add(createFacilityCard('書籍購買店', todayData.first.syoseki));
      }
      if (todayData.first.seikyou.isNotEmpty) {
        cards.add(createFacilityCard('生協本部', todayData.first.seikyou));
      }
    }

    // 最後のカードの後に20の隙間を追加
    cards.add(SizedBox(height: 20));

    return ListView(
      children: cards,
    );
  }

  // 施設利用可能時間を表示するカードを作成する関数
  Widget createFacilityCard(String facilityName, String time) {
    // 現在の時間を取得
    final now = DateTime.now();

    Widget statusIcon;
    Color statusColor;
    String statusText;
    String endTimeText = "";

    if (time == "Closed") {
      statusColor = Colors.red;
      statusIcon = Icon(Icons.remove_circle, color: statusColor, size: 20);
      statusText = "営業時間外";
    } else {
      final times = time.split(' - ');
      final startTime = DateTime(now.year, now.month, now.day,
          int.parse(times[0].split(':')[0]), int.parse(times[0].split(':')[1]));
      final endTime = DateTime(now.year, now.month, now.day,
          int.parse(times[1].split(':')[0]), int.parse(times[1].split(':')[1]));

      if (now.isAfter(startTime) && now.isBefore(endTime)) {
        statusColor = Colors.green;
        statusIcon = Icon(Icons.check_circle, color: statusColor, size: 20);
        statusText = "営業中";
        endTimeText = "営業終了: ${times[1]}"; // 終了時間を追加
      } else {
        statusColor = Colors.red;
        statusIcon = Icon(Icons.remove_circle, color: statusColor, size: 20);
        statusText = "営業時間外";
      }
    }

    return Card(
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
            // 左側に配置する画像
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.asset(
                'assets/${facilityName}.png',
                width: 120,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10), // 画像とテキストの間のスペース
            // 右側に配置するテキスト
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$facilityName',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 2.5),
                  Text(
                    '$time',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  // 3行目の営業中かどうか書くところ
                  SizedBox(height: 5.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      statusIcon,
                      SizedBox(width: 5.0),
                      Text(statusText,
                          style: TextStyle(color: statusColor, fontSize: 15)),
                      if (endTimeText.isNotEmpty) ...[
                        // 営業中の場合のみ追加テキストを表示
                        SizedBox(width: 10.0),
                        Text(endTimeText,
                            style: TextStyle(color: Colors.grey, fontSize: 15)),
                      ]
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                    '食堂メニュー',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[
            // ここで施設利用可能時間を表示
            showFacilityTime(facilitytimedata),
            // ここで食堂を表示
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width - 40,
                    height: 80,
                    child: ElevatedButton(
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
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // 縦方向の中央に配置
                              children: [
                                Text(
                                  '第一食堂',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '（月～金）11:00 - 19:00　（土）11:00 - 13:30',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
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
                  ),

                  // ボタン間のスペース
                  SizedBox(height: 15.0),

                  Container(
                    width: MediaQuery.of(context).size.width - 40,
                    height: 80,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GenkiPage()));
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => GenkiCafeteriaPage()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // 縦方向の中央に配置
                              children: [
                                Text(
                                  'ＧＥＮＫＩ食堂',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '（月～金）11:00 - 13:30',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
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

// ハッシュ
String generateHashId(String menuName) {
  var bytes = utf8.encode(menuName);
  var digest = sha256.convert(bytes);
  return digest.toString();
}

// Storageからメニュー名と一致する画像urlを取得
Future<Uint8List?> fetchurlimage(String name) async {
  return FirebaseStorage.instance.ref('menu/$name.jpg').getData();
}

// ratingsの平均を算出
Future<Map<String, dynamic>> fetchratings(String name) async {
  String docId = generateHashId(name);
  final DocumentSnapshot documentSnapshot =
      await FirebaseFirestore.instance.collection('ratings').doc(docId).get();
  final data = documentSnapshot.data() as Map<String, dynamic>?;
  final ratings = data?['ratings'] as Map<String, dynamic>?;
  final ratinglist = ratings?.values.map((e) => e as double).toList() ?? [];

  double average = 0.0;
  if (ratinglist.isNotEmpty) {
    average = (((ratinglist.reduce((value, element) => value + element) /
                    ratinglist.length) *
                100)
            .roundToDouble()) /
        100;
  }
  return {'average': average.toString(), 'total': ratinglist.length};
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
                    GestureDetector(
                      onTap: () async {
                        double? rating = 3.0; // 初期値を設定
                        TextEditingController ratingController =
                            TextEditingController(text: '3.0'); // 初期値を設定
                        String? errorMessage;

                        await showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  title: Column(
                                    children: [
                                      Text(
                                          '品名：' +
                                              removeSpecialTag(item['name']),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blue)),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Text('星をタップして評価してください。',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      RatingBar.builder(
                                        initialRating: rating ?? 3.0,
                                        minRating: 1,
                                        maxRating: 5,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemSize: 40.0,
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Color(0xFFed6102),
                                        ),
                                        onRatingUpdate: (newRating) {
                                          setState(() {
                                            rating = newRating;
                                            ratingController.text =
                                                newRating.toString();
                                          });
                                        },
                                      ),
                                      SizedBox(height: 20),
                                      TextFormField(
                                        controller: ratingController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: '評価値を入力',
                                          errorText: errorMessage,
                                        ),
                                        onChanged: (value) {
                                          bool isValidFormat = RegExp(
                                                  r'^(\d(\.\d{1,2})?|5(\.0{1,2})?)$')
                                              .hasMatch(value);
                                          double? parsedValue =
                                              double.tryParse(value);

                                          if (!isValidFormat ||
                                              parsedValue == null ||
                                              parsedValue < 1 ||
                                              parsedValue > 5) {
                                            setState(() {
                                              errorMessage = !isValidFormat
                                                  ? '少数第2位まで入力してください。'
                                                  : '1から5の範囲で入力してください。';
                                              rating = null;
                                            });
                                          } else {
                                            setState(() {
                                              errorMessage = null;
                                              rating = parsedValue;
                                            });
                                          }
                                        },
                                      ),
                                      SizedBox(height: 20),
                                      ElevatedButton(
                                        child: Text('登録する'),
                                        style: ElevatedButton.styleFrom(
                                          primary: Color(0xFFed6102),
                                        ),
                                        onPressed: rating != null
                                            ? () {
                                                Navigator.pop(context);

                                                // 現在のユーザーのUIDを取得 (ここではFirebase Authenticationの例を使用しています)
                                                final userUID = FirebaseAuth
                                                    .instance.currentUser!.uid;

                                                String docId = generateHashId(
                                                    removeSpecialTag(
                                                        item['name']));

                                                // ratingsの中にユーザーのUIDをキーとして評価を保存（1人1評価だけ。上書きは可能）
                                                FirebaseFirestore.instance
                                                    .collection('ratings')
                                                    .doc(docId)
                                                    .set({
                                                  'name': removeSpecialTag(
                                                      item['name']),
                                                  'ratings': {
                                                    userUID: rating,
                                                  }
                                                }, SetOptions(merge: true));
                                              }
                                            : null,
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Card(
                        shadowColor: Colors.grey.withOpacity(0.5),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: FutureBuilder(
                                    future: fetchurlimage(
                                        removeSpecialTag(item['name'])),
                                    builder: (context, snapshot) {
                                      final bytes = snapshot.data;
                                      if (bytes != null) {
                                        return Image.memory(
                                          bytes,
                                          width: 120,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                      return Image.asset(
                                        'assets/noimage.png',
                                        width: 120,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      );
                                    }),
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
                                    Text(
                                      item['english'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(height: 5.0),
                                    FutureBuilder<Map<String, dynamic>>(
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          if (snapshot.hasData) {
                                            final double ratingValue =
                                                double.parse(
                                                    snapshot.data!['average']
                                                        as String);
                                            final int totalRatings =
                                                snapshot.data!['total'] as int;
                                            return Row(
                                              children: [
                                                Text(
                                                  ratingValue
                                                      .toStringAsFixed(2),
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                SizedBox(width: 5.0), // 星と文字の間
                                                RatingBarIndicator(
                                                  rating: ratingValue,
                                                  itemBuilder:
                                                      (context, index) => Icon(
                                                    Icons.star,
                                                    color: Color(0xffed6102),
                                                  ),
                                                  itemCount: 5,
                                                  itemSize: 15.0,
                                                  direction: Axis.horizontal,
                                                ),
                                                SizedBox(width: 5.0),
                                                Text(
                                                  '($totalRatings)',
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                              ],
                                            );
                                          }
                                          if (snapshot.hasError) {
                                            return Text(
                                                'エラー: ${snapshot.error}');
                                          }
                                        }
                                        return SizedBox();
                                      },
                                      future: fetchratings(
                                          removeSpecialTag(item['name'])),
                                    ),
                                    SizedBox(height: 5.0),
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
                    GestureDetector(
                      onTap: () async {
                        double? rating = 3.0; // 初期値を設定
                        TextEditingController ratingController =
                            TextEditingController(text: '3.0'); // 初期値を設定
                        String? errorMessage;

                        await showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  title: Column(
                                    children: [
                                      Text(
                                          '品名：' +
                                              removeSpecialTag(item['name']),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blue)),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Text('星をタップして評価してください。',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      RatingBar.builder(
                                        initialRating: rating ?? 3.0,
                                        minRating: 1,
                                        maxRating: 5,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemSize: 40.0,
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Color(0xFFed6102),
                                        ),
                                        onRatingUpdate: (newRating) {
                                          setState(() {
                                            rating = newRating;
                                            ratingController.text =
                                                newRating.toString();
                                          });
                                        },
                                      ),
                                      SizedBox(height: 20),
                                      TextFormField(
                                        controller: ratingController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: '評価値を入力',
                                          errorText: errorMessage,
                                        ),
                                        onChanged: (value) {
                                          bool isValidFormat = RegExp(
                                                  r'^(\d(\.\d{1,2})?|5(\.0{1,2})?)$')
                                              .hasMatch(value);
                                          double? parsedValue =
                                              double.tryParse(value);

                                          if (!isValidFormat ||
                                              parsedValue == null ||
                                              parsedValue < 1 ||
                                              parsedValue > 5) {
                                            setState(() {
                                              errorMessage = !isValidFormat
                                                  ? '少数第2位まで入力してください。'
                                                  : '1から5の範囲で入力してください。';
                                              rating = null;
                                            });
                                          } else {
                                            setState(() {
                                              errorMessage = null;
                                              rating = parsedValue;
                                            });
                                          }
                                        },
                                      ),
                                      SizedBox(height: 20),
                                      ElevatedButton(
                                        child: Text('登録する'),
                                        style: ElevatedButton.styleFrom(
                                          primary: Color(0xFFed6102),
                                        ),
                                        onPressed: rating != null
                                            ? () {
                                                Navigator.pop(context);

                                                // 現在のユーザーのUIDを取得 (ここではFirebase Authenticationの例を使用しています)
                                                final userUID = FirebaseAuth
                                                    .instance.currentUser!.uid;

                                                String docId = generateHashId(
                                                    removeSpecialTag(
                                                        item['name']));

                                                // ratingsの中にユーザーのUIDをキーとして評価を保存（1人1評価だけ。上書きは可能）
                                                FirebaseFirestore.instance
                                                    .collection('ratings')
                                                    .doc(docId)
                                                    .set({
                                                  'name': removeSpecialTag(
                                                      item['name']),
                                                  'ratings': {
                                                    userUID: rating,
                                                  }
                                                }, SetOptions(merge: true));
                                              }
                                            : null,
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Card(
                        shadowColor: Colors.grey.withOpacity(0.5),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: FutureBuilder(
                                    future: fetchurlimage(
                                        removeSpecialTag(item['name'])),
                                    builder: (context, snapshot) {
                                      final bytes = snapshot.data;
                                      if (bytes != null) {
                                        return Image.memory(
                                          bytes,
                                          width: 120,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                      return Image.asset(
                                        'assets/noimage.png',
                                        width: 120,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      );
                                    }),
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
                                    Text(
                                      item['english'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(height: 5.0),
                                    FutureBuilder<Map<String, dynamic>>(
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          if (snapshot.hasData) {
                                            final double ratingValue =
                                                double.parse(
                                                    snapshot.data!['average']
                                                        as String);
                                            final int totalRatings =
                                                snapshot.data!['total'] as int;
                                            return Row(
                                              children: [
                                                Text(
                                                  ratingValue
                                                      .toStringAsFixed(2),
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                                SizedBox(width: 5.0), // 星と文字の間
                                                RatingBarIndicator(
                                                  rating: ratingValue,
                                                  itemBuilder:
                                                      (context, index) => Icon(
                                                    Icons.star,
                                                    color: Color(0xffed6102),
                                                  ),
                                                  itemCount: 5,
                                                  itemSize: 15.0,
                                                  direction: Axis.horizontal,
                                                ),
                                                SizedBox(width: 5.0),
                                                Text(
                                                  '($totalRatings)',
                                                  style:
                                                      TextStyle(fontSize: 15.0),
                                                ),
                                              ],
                                            );
                                          }
                                          if (snapshot.hasError) {
                                            return Text(
                                                'エラー: ${snapshot.error}');
                                          }
                                        }
                                        return SizedBox();
                                      },
                                      future: fetchratings(
                                          removeSpecialTag(item['name'])),
                                    ),
                                    SizedBox(height: 5.0),
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
