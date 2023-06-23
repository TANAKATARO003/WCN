import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class User extends StatefulWidget {
  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> with SingleTickerProviderStateMixin {
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

  // 投稿を送信するメソッド
  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate() &&
        _image != null &&
        _selectedAttribute != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('post_images')
          .child(DateTime.now().toString() + '.jpg');
      await ref.putFile(_image!);
      final imageUrl = await ref.getDownloadURL();

      FirebaseFirestore.instance.collection('posts').add({
        'title': _titleController.text,
        'content': _contentController.text,
        'attribute': _selectedAttribute,
        'imageUrl': imageUrl,
        'timestamp': Timestamp.now(),
      });

      _titleController.clear();
      _contentController.clear();
      setState(() {
        _image = null;
        _selectedAttribute = null;
      });
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
                    '調査/投票',
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
            padding: EdgeInsets.only(top: 15.0), // 一番上の記事カードとタブバーの間の隙間
            child: _buildPostsList("新着"),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15.0), // 一番上の記事カードとタブバーの間の隙間
            child: _buildPostsList("イベント"),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15.0), // 一番上の記事カードとタブバーの間の隙間
            child: _buildPostsList("調査/投票"),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15.0), // 一番上の記事カードとタブバーの間の隙間
            child: _buildPostsList("学作紹介"),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15.0), // 一番上の記事カードとタブバーの間の隙間
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
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final post = snapshot.data!.docs[index];
            return Card(
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
                            color: Color(0xFFF0F0F0), // 背景色を#F0F0F0に設定
                            child: Padding(
                              padding: EdgeInsets.all(2.0), // テキストと四角の間の余白を設定
                              child: Text(
                                post['attribute'],
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.w500, // FontWeightをw500に変更
                                  fontSize: 13, // フォントサイズを調整
                                  color: Color(0xFF808080), // テキストの色を#808080に設定
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
                            '投稿日：${(post['timestamp'] as Timestamp).toDate().toString().split(' ')[0]}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
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
        return AlertDialog(
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_image != null) Image.file(_image!),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.image),
                    label: Text('画像を追加'),
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
                  TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(labelText: '内容'),
                    maxLength: 400,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '内容を入力してください';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField(
                    value: _selectedAttribute,
                    items: [
                      DropdownMenuItem(
                        child: Text("イベント"),
                        value: "イベント",
                      ),
                      DropdownMenuItem(
                        child: Text("調査/投票"),
                        value: "調査/投票",
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
                  ElevatedButton(
                    onPressed: () {
                      _submitPost();
                      Navigator.of(context).pop();
                    },
                    child: Text('投稿する'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
