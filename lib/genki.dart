import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Genki extends StatefulWidget {
  @override
  _GenkiState createState() => _GenkiState();
}

class _GenkiState extends State<Genki> with SingleTickerProviderStateMixin {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: AppBar(
          title: Text(
            "生協食堂",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          shadowColor: Colors.grey.withOpacity(0.5),
          backgroundColor: Colors.white,
          elevation: 1.5,
          centerTitle: true,
        ),
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
}
