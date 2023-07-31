import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'homecalender.dart';
import 'homefacility.dart';
import 'hometopic.dart';
import 'login.dart';

class HomeCarousel extends StatefulWidget {
  @override
  _HomeCarouselState createState() => _HomeCarouselState();
}

// _launchInBrowser関数（デフォルトブラウザで起動）
final Uri _urlToOpen = Uri.parse('https://www.wakayama-u.ac.jp/');

Future<void> _launchUrl(Uri url) async {
  if (!await launch(url.toString())) {
    throw Exception('Could not launch $url');
  }
}

// カルーセルを押すとダイアログが開く
Future<void> _showDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('確認'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('外部ブラウザを起動して和歌山大学ホームページを表示しますが、よろしいですか？'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('キャンセル'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('はい'),
            onPressed: () {
              _launchUrl(_urlToOpen);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// スイッチの状態を保存したり更新したりするための関数
class PreferencesHelper {
  static Future<void> setSwitchState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('switchState', value);
  }

  static Future<bool> getSwitchState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('switchState') ?? false;
  }
}

// スイッチのためのセクション
class SwitchSection extends StatefulWidget {
  @override
  _SwitchSectionState createState() => _SwitchSectionState();
}

class _SwitchSectionState extends State<SwitchSection>
    with TickerProviderStateMixin {
  bool _isSwitched = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // 初期化時に保存されたスイッチの状態を取得する
    PreferencesHelper.getSwitchState().then((value) {
      setState(() {
        _isSwitched = value;
      });
    });

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticIn,
    ))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      child: Row(
        children: [
          Transform.rotate(
            angle: _animation.value,
            child: Icon(
              Icons.notifications,
              color: _isSwitched ? Colors.blue : Color(0xFF808080),
              size: 24,
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Text(
              'プッシュ通知',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          Switch(
            value: _isSwitched,
            onChanged: (value) {
              setState(() {
                _isSwitched = value;
              });

              // スイッチの状態を変更する度に保存
              PreferencesHelper.setSwitchState(value);

              _controller.forward(from: 0);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// 設定ページ
class SettingsPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final User user = _auth.currentUser!;
    final String email = user.email ?? 'No email found';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          // 戻るボタンの実装
          icon: Icon(Icons.arrow_back_ios, color: Colors.black), // ここで色を黒に指定
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "設定",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        shadowColor: Colors.grey.withOpacity(0.5),
        backgroundColor: Colors.white,
        elevation: 1.5,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(16.0, 18.0, 16.0, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // これにより、子ウィジェットは縦方向の中央に配置されます
                    children: [
                      Icon(Icons.info, color: Color(0xFF808080), size: 24),
                      SizedBox(width: 10.0),
                      Text(
                        '登録情報',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center, // 中央揃えに配置
                    children: [
                      Container(
                        height: 26,
                        width: 107,
                        color: Color(0xFF96825a),
                        child: Align(
                          alignment: Alignment.center, // テキストを中央揃えに配置
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 8.0),
                            child: Text(
                              'メールアドレス',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w500, // FontWeightをw500に変更
                                fontSize: 13, // フォントサイズを調整
                                color: Color(0xFFFFFFFF), // テキストの色を#FFFFFFに設定
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0), // テキストとメールアドレスの間を追加
                      Expanded(
                        child: Text(
                          _auth.currentUser?.email ?? 'No email found',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  FutureBuilder<DocumentSnapshot>(
                    future: _firestore.collection('users').doc(user.uid).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (!snapshot.hasData) {
                          return Text('データが見つかりません');
                        }
                        final data = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 26,
                                  width: 107,
                                  color: Color(0xFF96825a),
                                  child: Align(
                                    alignment: Alignment.center, // テキストを中央揃えに配置
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2.0, horizontal: 8.0),
                                      child: Text(
                                        '学部',
                                        style: TextStyle(
                                          fontWeight: FontWeight
                                              .w500, // FontWeightをw500に変更
                                          fontSize: 13, // フォントサイズを調整
                                          color: Color(
                                              0xFFFFFFFF), // テキストの色を#FFFFFFに設定
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.0), // テキストと学部の間を追加
                                Text(
                                  '${data['faculty'] ?? '情報なし'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              children: [
                                Container(
                                  height: 26,
                                  width: 107,
                                  color: Color(0xFF96825a),
                                  child: Align(
                                    alignment: Alignment.center, // テキストを中央揃えに配置
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2.0, horizontal: 8.0),
                                      child: Text(
                                        '学年',
                                        style: TextStyle(
                                          fontWeight: FontWeight
                                              .w500, // FontWeightをw500に変更
                                          fontSize: 13, // フォントサイズを調整
                                          color: Color(
                                              0xFFFFFFFF), // テキストの色を#FFFFFFに設定
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.0), // テキストと学年の間を追加
                                Text(
                                  '${data['year'] ?? '情報なし'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      return Container();
                    },
                  ),
                ],
              ),
            ),
            Divider(color: Colors.black45),

            // 新しく追加するコード
            SwitchSection(),
            Divider(color: Colors.black45),

            GestureDetector(
              onTap: () async {
                bool? shouldLogoutResult = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.warning, size: 24.0, color: Colors.red),
                        SizedBox(width: 7.5),
                        Text('ログアウト確認'),
                      ],
                    ),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text('ログアウトすると、再ログインするまで機能が利用出来ません。ログアウトしますか？'),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                          child: Text('キャンセル'),
                          onPressed: () => Navigator.pop(context, false)),
                      TextButton(
                          child: Text('はい'),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                          }),
                    ],
                  ),
                );
                bool shouldLogout = shouldLogoutResult ?? false;
                if (!shouldLogout) {
                  return;
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.red,
                      size: 24,
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        'ログアウト',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(color: Colors.black45),
          ],
        ),
      ),
    );
  }
}

class _HomeCarouselState extends State<HomeCarousel> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  final List<String> imgList = [
    'assets/image1.png',
    'assets/image2.png',
    'assets/image3.png',
    'assets/image4.png',
    'assets/image5.png',
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double imageWidth = screenWidth > 480.0 ? 480.0 : screenWidth;
    final double imageHeight = imageWidth / 3.4;

    return Stack(
      children: <Widget>[
        CarouselSlider(
          carouselController: _controller,
          options: CarouselOptions(
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 5),
            height: imageHeight,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          items: imgList
              .map((item) => Builder(
                    builder: (BuildContext context) {
                      return Image.asset(item,
                          width: imageWidth,
                          height: imageHeight,
                          fit: BoxFit.cover);
                    },
                  ))
              .toList(),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imgList.map((url) {
              int index = imgList.indexOf(url);
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == index
                      ? Color(0xffed6102)
                      : Color.fromRGBO(0, 0, 0, 0.4),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF0F0F0),
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(75.0), // AppBarの高さを「75」に変更
            child: AppBar(
              actions: [
                Padding(
                    padding: EdgeInsets.only(
                        top: 10.0, right: 20.0), // ログアウト用アイコンの位置調整
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage()),
                        );
                      },
                      child: CircleAvatar(
                        child: Icon(
                          Icons.account_circle,
                          size: 30.0, // アイコンの高さを30に設定
                        ),
                      ),
                    ))
              ],
              leading: Container(
                width: 245,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, left: 20.0), // ロゴの位置を「10」下に調整、そして左から「5」に設定
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                    height: 32.5, // ロゴの高さを「32.5」に設定
                  ),
                ),
              ),
              leadingWidth: 285,

              backgroundColor: Colors.white, // AppBarの色を白色に設定
              elevation: 0.0, // AppBarの影を削除
              centerTitle: false,
            )),
        body: ListView(
          children: [
            // カルーセル
            GestureDetector(
                onTap: () {
                  _showDialog(context);
                },
                child: HomeCarousel()),
            SizedBox(height: 20),

            // トピック
            Container(
              height: 268,
              child: NewsList(),
            ),
            SizedBox(height: 20),

            // 本日の予定
            Container(
              height: 268,
              child: HomeCalendar(),
            ),
            SizedBox(height: 20),

            // 施設利用可能時間
            Container(
              height: 268,
              child: HomeFacility(),
            ),
            SizedBox(height: 20),
          ],
        ));
  }
}
