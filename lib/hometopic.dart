import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

Future<Uint8List?> fetchurlimage(String name) async {
  return FirebaseStorage.instance.ref('topic/$name.jpg').getData();
}

// dateClassの内容判定
String getText(String dateClass) {
  switch (dateClass) {
    case 'attrNotice date':
      return 'お知らせ';
    case 'attrEvent date':
      return 'イベント';
    case 'attrAdmission date':
      return '入試';
    case 'attrPress date':
      return 'プレス';
    case 'attrPublic-offering date':
      return '公募';
    default:
      return dateClass;
  }
}

// dateClassの色判定
Color getContainerColor(String dateClass) {
  switch (dateClass) {
    case 'attrNotice date':
      return Color(0xFF96825a);
    case 'attrEvent date':
      return Color(0xFF7d7d7d);
    case 'attrAdmission date':
      return Color(0xFF616d5b);
    case 'attrPress date':
      return Color(0xFF856964);
    case 'attrPublic-offering date':
      return Color(0xFF31517b);
    default:
      return Color(0xFFF0F0F0);
  }
}

// _launchInBrowser関数（デフォルトブラウザで起動）
final Uri _urlToOpen = Uri.parse('https://www.wakayama-u.ac.jp/');

Future<void> _launchUrl(Uri url) async {
  if (!await launch(url.toString())) {
    throw Exception('Could not launch $url');
  }
}

// 各カードを押すとダイアログが開く
Future<void> _showDialog(BuildContext context, Uri url) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('確認'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('外部ブラウザを起動して記事を表示しますが、よろしいですか？'),
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
              _launchUrl(url); // ここでUriオブジェクトを使用
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class NewsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hpDocRef = FirebaseFirestore.instance.collection("hp").doc("hp");

    return StreamBuilder<DocumentSnapshot>(
      stream: hpDocRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final dataMap = snapshot.data?.data() as Map<String, dynamic>?;
        if (dataMap == null || !dataMap.containsKey("news")) {
          return Container();
        }
        List<Map<String, dynamic>> newsEntries =
            List<Map<String, dynamic>>.from(dataMap["news"] ?? []);
        List<Map<String, dynamic>> limitedNewsEntries =
            newsEntries.sublist(0, min(5, newsEntries.length));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 縦方向の配置を左寄せに設定
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'トピック',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 5), // トピックという文字と、次の要素の間のスペース
            NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
                return true;
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: limitedNewsEntries.map<Widget>((news) {
                    // カードの枚数のインデックスを指定して、それぞれ最初と最後にだけ余白を付けたしている
                    int index = limitedNewsEntries.indexOf(news);
                    bool isFirstCard = index == 0;
                    bool isLastCard = index == 4;

                    return Container(
                      width: 320.0,
                      height: 240.0,
                      margin: EdgeInsets.only(
                        left: isFirstCard ? 15 : 5,
                        right: isLastCard ? 15 : 0,
                        top: 0,
                        bottom: 0,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          final Uri newsUrl = Uri.parse(
                              'https://www.wakayama-u.ac.jp/' + news['url']);
                          _showDialog(context, newsUrl);
                        },
                        child: Card(
                          shadowColor: Colors.grey.withOpacity(0.5),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 画像表示部分
                              FutureBuilder<Uint8List?>(
                                future: fetchurlimage(news['dateClass']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasData &&
                                        snapshot.data != null) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15.0),
                                          topRight: Radius.circular(15.0),
                                        ),
                                        child: Image.memory(
                                          snapshot.data!,
                                          width: 320,
                                          height: 140,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    } else {
                                      // Firebase Storageからnoimage.pngを試みる
                                      return FutureBuilder<Uint8List?>(
                                        future: fetchurlimage("noimage.png"),
                                        builder: (context, secondarySnapshot) {
                                          if (secondarySnapshot
                                                  .connectionState ==
                                              ConnectionState.done) {
                                            if (secondarySnapshot.hasData &&
                                                secondarySnapshot.data !=
                                                    null) {
                                              return Image.memory(
                                                secondarySnapshot.data!,
                                                width: 320,
                                                height: 140,
                                                fit: BoxFit.cover,
                                              );
                                            } else {
                                              // assetsからnoimage.pngを試みる
                                              return Image.asset(
                                                'assets/noimage.png',
                                                width: 320,
                                                height: 140,
                                                fit: BoxFit.cover,
                                              );
                                            }
                                          } else {
                                            return Container(
                                              width: 320,
                                              height: 140,
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              child: Center(child: Container()),
                                            );
                                          }
                                        },
                                      );
                                    }
                                  } else {
                                    return Container(
                                      width: 320,
                                      height: 140,
                                      color: Colors.grey.withOpacity(0.5),
                                      child: Center(child: Container()),
                                    );
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 68,
                                          color: getContainerColor(
                                              news['dateClass']),
                                          child: Align(
                                            alignment: Alignment
                                                .center, // テキストを中央揃えに配置
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 2.0,
                                                  horizontal: 8.0),
                                              child: Text(
                                                getText(news['dateClass']),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Spacer(), // これを入れると、次のRow内のウィジェットが右端に寄せられる
                                        Text(
                                          '投稿日：' + news['dateText'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      news['text'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
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
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
