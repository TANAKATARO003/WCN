import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class User extends StatefulWidget {
  @override
  _UserState createState() => _UserState();
}

String formatDate(DateTime dateTime) {
  return '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
}

// dateClassの色判定
Color getContainerColor(String attribute) {
  switch (attribute) {
    case 'イベント':
      return Color(0xFF7d7d7d);
    case '調査／投票':
      return Color(0xFF31517b);
    case '学作紹介':
      return Color(0xFF96825a);
    case '課外活動':
      return Color(0xFF616d5b);
    default:
      return Color(0xFFF0F0F0);
  }
}

// 記事カードをタップしたら記事ページを開く
class PostDetailPage extends StatelessWidget {
  final DocumentSnapshot post;

  PostDetailPage({required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            // 戻るボタンの実装
            icon: Icon(Icons.arrow_back_ios, color: Colors.black), // ここで色を黒に指定
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            "記事の詳細",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black), // タイトルのスタイル設定
          ),
          shadowColor: Colors.grey.withOpacity(0.5), // 影の色と透明度を設定
          backgroundColor: Colors.white, // AppBarの背景色を設定
          elevation: 1.5, // AppBarの影の高さを「1.5」に設定
          centerTitle: true, // タイトルを中央に配置
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width > 480
                    ? 480
                    : MediaQuery.of(context).size.width,
                height: 320,
                child: Image.network(
                  post['imageUrl'],
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              // ここから内容
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0), // 横方向に10pxのパディングを設定
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 子要素を左揃えに設定
                  children: [
                    SizedBox(height: 20), // 縦に20px間隔を空ける
                    Container(
                      width: 81,
                      color: getContainerColor(post['attribute']),
                      child: Align(
                        alignment: Alignment.center, // テキストを中央揃えに配置
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 8.0),
                          child: Text(
                            post['attribute'],
                            style: TextStyle(
                              fontWeight: FontWeight.w500, // FontWeightをw500に変更
                              fontSize: 13, // フォントサイズを調整
                              color: Color(0xFFFFFFFF), // テキストの色を#FFFFFFに設定
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // 縦に20px間隔を空ける
                    Text(
                      post['title'],
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 20), // 縦に20px間隔を空ける
                    Text(
                      post['content'],
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 40), // 縦に40px間隔を空ける
                    Align(
                      alignment: Alignment.centerRight, // 右揃えに設定
                      child: Text(
                        '投稿日：${formatDate((post['timestamp'] as Timestamp).toDate())}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    SizedBox(height: 20), // 縦に20px間隔を空ける
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

class _UserState extends State<User> with SingleTickerProviderStateMixin {
  // 画像のプレビュー表示のための判定
  bool _dialogOpen = false;

  // タブコントローラー
  TabController? _tabController;

  // 投稿フォームのキー
  final _formKey = GlobalKey<FormState>();

  // タイトルとコンテンツのコントローラー
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // 選択された画像と属性
  File? _image;
  String? _selectedAttribute;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // 画像を選択するメソッド
  Future<void> _pickImage() async {
    setState(() {
      _dialogOpen = true; // 画像プレビューの表示判定
    });

    final pickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  // エラーメッセージを保持する変数を追加
  String? _titleErrorText;
  String? _contentErrorText;
  String? _attributeErrorText;

  // 投稿を送信するメソッド
  Future<bool> _submitPost() async {
    bool isValid = _formKey.currentState!.validate();

    // タイトル、コンテンツ、属性のエラーメッセージをセット
    if (_titleController.text.isEmpty) {
      _titleErrorText = "タイトルを入力してください";
    }

    if (_contentController.text.isEmpty) {
      _contentErrorText = "内容を入力してください";
    }

    if (_selectedAttribute == null) {
      _attributeErrorText = "属性を選択してください";
    }

    String imageUrl;

    final userId = FirebaseAuth.instance.currentUser!.uid;

    if (_image != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('post_images')
          .child(DateTime.now().toString() + '.jpg');

      await ref.putFile(_image!);
      imageUrl = await ref.getDownloadURL();
    } else {
      // 事前にアップロードした noimage.png のURLを使用
      imageUrl =
          "https://firebasestorage.googleapis.com/v0/b/wakayamacampusnavi.appspot.com/o/noimage.png?alt=media&token=bf84791d-c3f8-49bf-9f43-81d0de379c89";
    }

    if (isValid) {
      FirebaseFirestore.instance.collection('posts').add({
        'title': _titleController.text,
        'content': _contentController.text,
        'attribute': _selectedAttribute,
        'imageUrl': imageUrl,
        'timestamp': Timestamp.now(),
        'userId': userId,
      });

      _titleController.clear();
      _contentController.clear();

      _image = null;
      _selectedAttribute = null;

      return true; // 成功を示す true を返す
    } else {
      return false; // 失敗を示す false を返す
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: AppBar(
          title: Text(
            "ユーザー投稿",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          shadowColor: Colors.grey.withOpacity(0.5),
          backgroundColor: Colors.white,
          elevation: 1.5,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Color(0xffed6102),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 3.0,
              isScrollable: false,
              labelColor: Colors.black,
              unselectedLabelColor: Color(0xff808080),
              labelPadding: EdgeInsets.all(0),
              tabs: <Widget>[
                Tab(
                  child: Text(
                    '新着',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                Tab(
                  child: Text(
                    'イベント',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                Tab(
                  child: Text(
                    '調査／投票',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                Tab(
                  child: Text(
                    '学作紹介',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 0.0), // 一番上の記事カードとタブバーの間の隙間
            child: _buildPostsList("新着"),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.0), // 一番上の記事カードとタブバーの間の隙間
            child: _buildPostsList("イベント"),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.0), // 一番上の記事カードとタブバーの間の隙間
            child: _buildPostsList("調査／投票"),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.0), // 一番上の記事カードとタブバーの間の隙間
            child: _buildPostsList("学作紹介"),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0.0), // 一番上の記事カードとタブバーの間の隙間
            child: _buildPostsList("課外活動"),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPostDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Color(0xffed6102), // 任意のカラーコードを設定
      ),
    );
  }

  // 投稿リストを表示するメソッド
  Widget _buildPostsList(String attribute) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('attribute', isEqualTo: attribute == "新着" ? null : attribute)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('エラーが発生しました'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: EdgeInsets.only(top: 15, bottom: 20), //一番最後のカードの後ろに20の余白
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final post = snapshot.data!.docs[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailPage(post: post),
                  ),
                );
              },
              child: Card(
                shadowColor: Colors.grey.withOpacity(0.5),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                margin: EdgeInsets.symmetric(
                    vertical: 5, horizontal: 20), // ここで記事カードのマージンを決定
                child: Container(
                  height: 100,
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.network(
                          post['imageUrl'],
                          width: 100,
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
                              width: 81,
                              color: getContainerColor(post['attribute']),
                              child: Align(
                                alignment: Alignment.center, // テキストを中央揃えに配置
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 2.0, horizontal: 8.0),
                                  child: Text(
                                    post['attribute'],
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.w500, // FontWeightをw500に変更
                                      fontSize: 13, // フォントサイズを調整
                                      color: Color(
                                          0xFFFFFFFF), // テキストの色を#FFFFFFに設定
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 2.5), // 記事属性と記事タイトルの間の隙間
                            Text(
                              post['title'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w500), // FontWeightをw500に変更
                            ),
                            SizedBox(height: 7.5), // 投稿日と記事タイトルの間の隙間
                            Text(
                              '投稿日：${formatDate((post['timestamp'] as Timestamp).toDate())}',
                              style: TextStyle(fontSize: 12),
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
  }

  // 投稿ダイアログを表示するメソッド
  void _showAddPostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Container(
                  width: MediaQuery.of(context).size.width - 20.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        // 使い方の説明
                        'ユーザー投稿の送信',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'イベントや課外活動における告知/募集、調査/アンケートの募集、大学での制作物の紹介など、様々な物に関して記事を作成して投稿できます。',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),

                      SizedBox(height: 20), // 説明と画像選択フィールドの間のスペース

                      if (_image != null) Image.file(_image!),
                      TextButton.icon(
                        onPressed: () async {
                          await _pickImage();
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.image,
                          color: Color(0xffed6102), // アイコンの色を設定
                        ),
                        label: Text(
                          '画像を追加（最大サイズ: 2MB）',
                          style: TextStyle(
                            color: Color(0xffed6102), // ボタンのテキスト色を設定
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(labelText: '記事タイトル'),
                        maxLength: 40,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'タイトルを入力してください';
                          }
                          return null;
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '内容',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xff666666)),
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            controller: _contentController,
                            decoration: InputDecoration(
                              fillColor: Colors.grey[200],
                              filled: true,
                              contentPadding: EdgeInsets.all(8.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            maxLength: 400,
                            maxLines: 5,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '内容を入力してください';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),

                      DropdownButtonFormField(
                        value: _selectedAttribute,
                        items: [
                          DropdownMenuItem(
                            child: Text("イベント"),
                            value: "イベント",
                          ),
                          DropdownMenuItem(
                            child: Text("調査／投票"),
                            value: "調査／投票",
                          ),
                          DropdownMenuItem(
                            child: Text("学作紹介"),
                            value: "学作紹介",
                          ),
                          DropdownMenuItem(
                            child: Text("課外活動"),
                            value: "課外活動",
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedAttribute = value as String?;
                          });
                        },
                        decoration: InputDecoration(labelText: '記事属性'),
                        validator: (value) {
                          if (value == null) {
                            return '属性を選択してください';
                          }
                          return null;
                        },
                      ),

                      // 記事属性とボタンの間のスペース
                      SizedBox(height: 20.0),

                      ElevatedButton(
                        onPressed: () async {
                          bool isSuccessful = await _submitPost();
                          if (isSuccessful) {
                            _dialogOpen = false;
                            Navigator.of(context).pop();
                          }
                          // 失敗した場合は、ダイアログは自動的に閉じられず、エラーメッセージが表示されます。
                        },
                        child: Text(
                          '投稿する',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffed6102),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
