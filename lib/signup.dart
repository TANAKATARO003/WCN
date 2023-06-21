import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = '',
      _password = '',
      _confirmPassword = '',
      _year = '',
      _faculty = '';

  // ログイン画面への遷移
  navigateToLoginScreen() {
    Navigator.pushReplacementNamed(context, "/Login");
  }

  // サインアップメソッド
  void signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_password == _confirmPassword) {
        try {
          UserCredential user = await _auth.createUserWithEmailAndPassword(
              email: _email, password: _password);

          await _db.collection('users').doc(user.user!.uid).set({
            'year': _year,
            'faculty': _faculty,
          });

          navigateToLoginScreen();
        } catch (e) {
          showError(e.toString());
        }
      } else {
        showError("Passwords do not match.");
      }
    }
  }

  // エラーメッセージを表示
  void showError(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('エラー'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFffffff),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Text(
                    'アカウント登録',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20.0), // テキストとロゴの間の隙間を作る
                  Image.asset(
                    'assets/logo.png',
                    height: 45,
                  ),

                  // 学年のプルダウンメニュー
                  SizedBox(height: 25.0), // ロゴと入力フィールドの間の隙間を作る
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ご自身の学年を選択してください',
                      style: TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(height: 5.0), // ロゴと入力フィールドの間の隙間を作る
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFe8e8e8),
                    ),
                    items: ['1年', '2年', '3年', '4年']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _year = newValue!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your year.';
                      }
                      return null;
                    },
                  ),

                  // 学部のプルダウンメニュー
                  SizedBox(height: 10.0), // 入力フィールド同士の間の隙間を作る
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ご自身の所属学部を選択してください',
                      style: TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(height: 5.0), // ロゴと入力フィールドの間の隙間を作る
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFe8e8e8),
                    ),
                    items: ['教育学部', '経済学部', 'システム工学部', '観光学部', '社会インフォマティクス学環']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _faculty = newValue!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your faculty.';
                      }
                      return null;
                    },
                  ),

                  // メールアドレス入れるところ
                  SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14.5,
                        color: Colors.black,
                        fontWeight: FontWeight.w500, // テキストの太さをW500に設定
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0), // テキストと入力フィールドの間の隙間を作る
                  TextFormField(
                    style:
                        TextStyle(height: 0.75), // heightの値を調整して入力フィールドの縦幅を変更
                    validator: (input) {
                      if (input!.isEmpty)
                        return 'Emailを入力してください';
                      else if (!input.contains('@'))
                        return '有効なEmailアドレスを入力してください';
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFe8e8e8), // フィールドの背景色を#e8e8e8に変更
                      border: InputBorder.none, // 入力フィールドの縁を削除
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none, // 縁無しを指定
                        borderRadius:
                            BorderRadius.circular(10.0), // 角を丸くする値を10.0に設定
                      ),
                    ),
                    onSaved: (input) => _email = input!,
                  ),

                  // Password input
                  SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'パスワード',
                      style: TextStyle(
                        fontSize: 14.5,
                        color: Colors.black,
                        fontWeight: FontWeight.w500, // テキストの太さをW500に設定
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0), // テキストと入力フィールドの間の隙間を作る
                  TextFormField(
                    style: TextStyle(height: 0.75),
                    // heightの値を調整して入力フィールドの縦幅を変更
                    validator: (input) {
                      if (input!.isEmpty)
                        return 'パスワードを入力してください';
                      else if (input.length < 6) return 'パスワードは最低6文字以上です';
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFe8e8e8), // フィールドの背景色を#e8e8e8に変更
                      border: InputBorder.none, // 入力フィールドの縁を削除
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none, // 縁無しを指定
                        borderRadius:
                            BorderRadius.circular(10.0), // 角を丸くする値を10.0に設定
                      ),
                    ),
                    obscureText: true,
                    onSaved: (input) => _password = input!,
                  ),

                  // Confirm Password input
                  SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'パスワード（確認）',
                      style: TextStyle(
                        fontSize: 14.5,
                        color: Colors.black,
                        fontWeight: FontWeight.w500, // テキストの太さをW500に設定
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0), // テキストと入力フィールドの間の隙間を作る
                  TextFormField(
                    style: TextStyle(height: 0.75),
                    // heightの値を調整して入力フィールドの縦幅を変更
                    validator: (input) {
                      if (input!.isEmpty)
                        return 'パスワード（確認）を入力してください';
                      else if (input.length < 6) return 'パスワードは最低6文字以上です';
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFe8e8e8), // フィールドの背景色を#e8e8e8に変更
                      border: InputBorder.none, // 入力フィールドの縁を削除
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none, // 縁無しを指定
                        borderRadius:
                            BorderRadius.circular(10.0), // 角を丸くする値を10.0に設定
                      ),
                    ),
                    obscureText: true,
                    onSaved: (input) => _confirmPassword = input!,
                  ),
                  //  登録ボタン
                  SizedBox(height: 15), // 入力フィールドと登録するのスペース幅
                  SizedBox(
                    width: double.infinity,
                    height: 55.0,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFFed6102),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        elevation: MaterialStateProperty.all<double>(0.0),
                      ),
                      onPressed: signUp,
                      child: Text(
                        '登録する',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // ログイン画面へのリンク
                  TextButton(
                    onPressed: navigateToLoginScreen,
                    child: Text(
                      'すでにアカウントをお持ちの方はこちら',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFed6102),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
