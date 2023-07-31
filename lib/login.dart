import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home/signup.dart';
import 'bottom_tab_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  String _email = '', _password = '';

  checkAuthentication() async {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return BottomTabPage();
        }));
      }
    });
  }

  navigateToSignUpScreen() {
    Navigator.pushReplacementNamed(context, "/SignUp");
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
  }

  void login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        UserCredential user = await _auth.signInWithEmailAndPassword(
            email: _email, password: _password);
      } catch (e) {
        showError(e.toString());
      }
    }
  }

  String getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'ユーザーが見つかりません。ログインに失敗しました。';
      case 'wrong-password':
        return 'パスワードが間違っています。ログインに失敗しました。';
      case 'invalid-email':
        return '無効なメールアドレス形式です。ログインに失敗しました。';
      default:
        return '未知のエラーが発生し、ログインに失敗しました。';
    }
  }

  void showError(String error) {
    String errorMessage = getErrorMessage(error);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning,
                  size: 24.0, color: Colors.red), // アイコンの色を赤色に設定
              SizedBox(width: 7.5),
              Text('ログイン失敗'),
            ],
          ),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('閉じる'),
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
      backgroundColor: const Color(0xFFf0f0f0),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10.0,
                offset: Offset(0, 0),
              ),
            ],
          ),
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'ログイン',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 25.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'アカウントIDまたはEmail',
                    style: TextStyle(
                        fontSize: 14.5,
                        color: Colors.black,
                        fontWeight: FontWeight.w500), // テキストの太さをW500に設定
                  ),
                ),
                SizedBox(height: 5.0), // テキストと入力フィールドの間の隙間を作る
                TextFormField(
                  style: TextStyle(height: 0.75), // heightの値を調整して入力フィールドの縦幅を変更
                  validator: (input) {
                    if (input!.isEmpty) return 'アカウントIDまたはEmailを入力してください';
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
                SizedBox(height: 10.0), // 入力フィールド同士のスペース幅
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'パスワード',
                    style: TextStyle(
                        fontSize: 14.5,
                        color: Colors.black,
                        fontWeight: FontWeight.w500), // テキストの太さをW500に設定
                  ),
                ),
                SizedBox(height: 5.0), // テキストと入力フィールドの間の隙間を作る
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(height: 0.75),
                  validator: (input) {
                    if (input!.length < 6) return 'パスワードを入力してください';
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFe8e8e8),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_passwordVisible,
                  onSaved: (input) => _password = input!,
                ),
                SizedBox(height: 15), // 入力フィールドとログインするのスペース幅
                SizedBox(
                  width: double.infinity,
                  height: 55.0,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFFed6102),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(0.0),
                    ),
                    onPressed: login,
                    child: Text(
                      'ログインする',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => SignUpPage(),
                          ),
                        );
                      },
                      child: Text(
                        'アカウント登録はこちら',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFed6102),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.0), // テキストの後のスペース幅
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
