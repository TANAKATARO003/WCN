import 'package:flutter/material.dart';
import 'package:home/home.dart';
import 'package:home/calendar.dart';
import 'package:home/tab_logo_icons.dart';
import 'package:home/user.dart';
import 'package:home/topic.dart';
import 'package:home/service.dart';

class BottomTabPage extends StatefulWidget {
  const BottomTabPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BottomTabPageState();
  }
}

class _BottomTabPageState extends State<BottomTabPage> {
  int _currentIndex = 0;
  final _pageWidgets = [
    Home(),
    const Calendar(),
    User(),
    Topic(),
    Service(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageWidgets.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 11, // 下タブのフォントサイズ（選択して大きくなった時）
        unselectedFontSize: 10, // 下タブのフォントサイズ（非選択時）
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold), // 選択されたタブのフォントを太く設定
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(TabLogo.home), label: 'ホーム'),
          const BottomNavigationBarItem(
              icon: Icon(TabLogo.calendar), label: 'カレンダー'),
          const BottomNavigationBarItem(
              icon: Icon(TabLogo.user), label: 'ユーザー投稿'),
          const BottomNavigationBarItem(
              icon: Icon(TabLogo.topic), label: 'トピック'),
          const BottomNavigationBarItem(
              icon: Icon(TabLogo.service), label: 'サービス'),
        ],
        currentIndex: _currentIndex,
        fixedColor: const Color(0xFFED6102), // 下タブの色を「#ed6102」に指定
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  void _onItemTapped(int index) => setState(() => _currentIndex = index);
}
