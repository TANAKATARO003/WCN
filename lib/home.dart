import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'login.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
    final double imageWidth =
        screenWidth > 400.0 ? 400.0 : screenWidth; // 最大幅400pxに設定
    final double imageHeight = imageWidth / 3.4; // アスペクト比に基づいて画像の高さを計算

    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0), // 背景色を「#f0f0f0」に設定
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75.0), // AppBarの高さを「75」に変更
        child: AppBar(
          actions: [
            Padding(
              padding:
                  EdgeInsets.only(top: 10.0, right: 20.0), // ログアウト用アイコンの位置調整
              child: InkWell(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }));
                },
                child: CircleAvatar(
                  child: Icon(
                    Icons.account_circle,
                    size: 30.0, // アイコンの高さを30に設定
                  ),
                ),
              ),
            )
          ],
          title: Padding(
            padding: EdgeInsets.only(
                top: 10.0, left: 5.0), // ロゴの位置を「10」下に調整、そして左から「5」に設定
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
              height: 32.5, // ロゴの高さを「32.5」に設定
            ),
          ),
          backgroundColor: Colors.white, // AppBarの色を白色に設定
          elevation: 0.0, // AppBarの影を削除
          centerTitle: false, // ロゴ画像をセンターから外す
        ),
      ),
      body: Stack(
        // Stackを使用してインジケータとカルーセルを重ねる
        children: <Widget>[
          CarouselSlider(
            carouselController: _controller,
            options: CarouselOptions(
              viewportFraction: 1.0, // カルーセルアイテムはビューポートの幅全体を占める
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 5), // 5秒ごとにスライド
              height: imageHeight, // アスペクト比に基づいて設定した高さ
              onPageChanged: (index, reason) {
                // 追加：ページが変わったときに現在のインデックスを更新
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
            // Positionedウィジェットを使用してインジケータの位置を制御する
            left: 0,
            right: 0,
            bottom: -5, // 画像の下限から-5の距離に設定
            child: Row(
              // インジケータの表示
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
                        ? Color(0xffed6102) // インジケータの色を「#ed6102」に変更
                        : Color.fromRGBO(0, 0, 0, 0.4),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
