import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

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

Future<void> _launchUrl(Uri url) async {
  if (!await launch(url.toString())) {
    throw Exception('Could not launch $url');
  }
}

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

class Topic extends StatefulWidget {
  @override
  _TopicState createState() => _TopicState();
}

class _TopicState extends State<Topic> with SingleTickerProviderStateMixin {
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
      backgroundColor: Color(0xFFF0F0F0), // 背景色を「#f0f0f0」に設定
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: AppBar(
          title: Text(
            "トピック",
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
                    'お知らせ',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                // 就職活動タブ
                Tab(
                  child: Text(
                    'イベント',
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
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 0.0), // 一番上の記事カードとタブバーの間の隙間
            child: _buildTopicList("all"),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.0), // 一番上の記事カードとタブバーの間の隙間
            child: _buildTopicList("attrNotice date"),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.0), // 一番上の記事カードとタブバーの間の隙間
            child: _buildTopicList("attrEvent date"),
          ),
        ],
      ),
    );
  }

  Future<String> getImageUrl(String dateClass) async {
    final imageUrl = await firebase_storage.FirebaseStorage.instance
        .ref()
        .child('topic/$dateClass.jpg')
        .getDownloadURL();

    return imageUrl;
  }

  Widget _buildTopicList(String attribute) {
    Query query = FirebaseFirestore.instance.collection('hp');

    return StreamBuilder(
      stream: query.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('エラーが発生しました'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<Map<String, dynamic>> news = [];

        // attributeが "all" の場合はすべての情報を表示する
        if (attribute == "all") {
          // Firestoreから取得したデータを適切な型にキャストする
          news = (snapshot.data!.docs.first['news'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
        } else {
          // "all" 以外の場合は、dateClass属性に基づいてフィルタリングする
          final allNews = snapshot.data!.docs.first['news'] as List<dynamic>;
          news = allNews
              .where((item) => item['dateClass'] == attribute)
              .toList()
              .cast<Map<String, dynamic>>();
        }

        return ListView.builder(
          padding: EdgeInsets.only(bottom: 20),
          itemCount: news.length,
          itemBuilder: (context, index) {
            final newsItem = news[index]; // news 配列の各要素を取得

            final dateClass = newsItem['dateClass'];
            final dateText = newsItem['dateText'];
            final text = newsItem['text'];

            return FutureBuilder(
              future: getImageUrl(dateClass), // 画像のURLを非同期で取得します
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // 画像のURLの取得が完了するまで、プレースホルダーやローディングウィジェットを表示します
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  // 画像のURLの取得にエラーがある場合、エラーウィジェットを表示できます
                  return Text('画像の読み込みエラー');
                }

                final imageUrl = snapshot.data as String; // 取得した画像のURLを取得します

                return GestureDetector(
                  onTap: () async {
                    final Uri newsUrl = Uri.parse(
                        'https://www.wakayama-u.ac.jp/' + newsItem['url']);
                    _showDialog(context, newsUrl);
                  },
                  child: Card(
                    shadowColor: Colors.grey.withOpacity(0.5),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Image.network(
                              imageUrl, // 取得した画像のURLを使います
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
                                Container(
                                  color:
                                      getContainerColor(newsItem['dateClass']),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2.0, horizontal: 8.0),
                                    child: Text(
                                      getText(newsItem['dateClass']),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.5),
                                Text(
                                  text,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 7.5),
                                Text(
                                  dateText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
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
              },
            );
          },
        );
      },
    );
  }
}
