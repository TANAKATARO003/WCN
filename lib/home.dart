import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'homecalender.dart';
import 'hometopic.dart';
import 'login.dart';

class HomeCarousel extends StatefulWidget {
  @override
  _HomeCarouselState createState() => _HomeCarouselState();
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
                    child: PopupMenuButton<String>(
                      offset: Offset(0, 40),
                      onSelected: (String result) async {
                        if (result == 'logout') {
                          bool? shouldLogoutResult = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: Row(
                                      children: [
                                        Icon(Icons.warning,
                                            size: 24.0,
                                            color: Colors.red), // アイコンの色を赤色に設定
                                        SizedBox(width: 7.5),
                                        Text('ログアウト確認'),
                                      ],
                                    ),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          Text(
                                              'ログアウトすると、再ログインするまで機能が利用出来ません。ログアウトしますか？'),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                          child: Text('いいえ'),
                                          onPressed: () =>
                                              Navigator.pop(context, false)),
                                      TextButton(
                                          child: Text('はい'),
                                          onPressed: () async {
                                            await FirebaseAuth.instance
                                                .signOut();
                                            Navigator.of(context)
                                                .pushReplacement(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            LoginPage()));
                                          }),
                                    ],
                                  ));
                          bool shouldLogout = shouldLogoutResult ?? false;
                          if (!shouldLogout) {
                            return;
                          }
                        } // 新: ダイアログでのログアウトの確認処理
                        // ここに '登録情報' を選択した際の処理も追加できます。
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'profile',
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.info,
                                  size: 24.0,
                                  color:
                                      Color(0xFF808080)), // アイコンの色を#808080に設定
                              SizedBox(width: 7.5),
                              Text('登録情報', style: TextStyle(fontSize: 16.0)),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.exit_to_app,
                                  size: 24.0,
                                  color:
                                      Color(0xFF808080)), // アイコンの色を#808080に設定
                              SizedBox(width: 7.5),
                              Text('ログアウト', style: TextStyle(fontSize: 16.0)),
                            ],
                          ),
                        ),
                      ],
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
            HomeCarousel(),
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

            // 食堂メニュー
            Container(
              height: 268,
              child: HomeCalendar(),
            ),
            SizedBox(height: 20),
          ],
        ));
  }
}
