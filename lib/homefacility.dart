import 'package:flutter/material.dart';
import 'package:home/facilitytime_data.dart';
import 'bottom_tab_page.dart';
import 'main.dart';

class HomeFacility extends StatefulWidget {
  @override
  _HomeFacilityState createState() => _HomeFacilityState();
}

class _HomeFacilityState extends State<HomeFacility>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F0F0),
      body: showFacilityTime(facilitytimedata),
    );
  }

  Widget showFacilityTime(List<FacilityTimeData> facilitytimedata) {
    final nowdate = DateTime.now();
    List<FacilityTimeData> todayData = facilitytimedata
        .where((data) =>
            data.date.year == nowdate.year &&
            data.date.month == nowdate.month &&
            data.date.day == nowdate.day)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 縦方向の配置を左寄せに設定
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 0),
          child: Text(
            '施設利用時間',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 5), // テキストとカードリストの間のスペース
        Expanded(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowGlow();
              return true;
            },
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: todayData.length,
              itemBuilder: (BuildContext context, int index) {
                final data = todayData[index];
                return Row(
                  children: [
                    if (index == 0) SizedBox(width: 10), // 最初のカードの前に追加
                    if (data.library.isNotEmpty)
                      createFacilityCard('図書館', data.library),
                    if (data.daiiti.isNotEmpty)
                      createFacilityCard('第一食堂', data.daiiti),
                    if (data.genki.isNotEmpty)
                      createFacilityCard('ＧＥＮＫＩ食堂', data.genki),
                    if (data.takeout.isNotEmpty)
                      createFacilityCard('テイクアウトショップ', data.takeout),
                    if (data.syoseki.isNotEmpty)
                      createFacilityCard('書籍購買店', data.syoseki),
                    if (data.seikyou.isNotEmpty)
                      createFacilityCard('生協本部', data.seikyou),
                    if (index == todayData.length - 1)
                      SizedBox(width: 15), // 最後のカードの後に追加
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget createFacilityCard(String facilityName, String time) {
    final now = DateTime.now();
    Widget statusIcon;
    Color statusColor;
    String statusText;
    String endTimeText = "";

    if (time == "Closed") {
      statusColor = Colors.red;
      statusIcon = Icon(Icons.remove_circle, color: statusColor, size: 20);
      statusText = "営業時間外";
    } else {
      final times = time.split(' - ');
      final startTime = DateTime(now.year, now.month, now.day,
          int.parse(times[0].split(':')[0]), int.parse(times[0].split(':')[1]));
      final endTime = DateTime(now.year, now.month, now.day,
          int.parse(times[1].split(':')[0]), int.parse(times[1].split(':')[1]));

      if (now.isAfter(startTime) && now.isBefore(endTime)) {
        statusColor = Colors.green;
        statusIcon = Icon(Icons.check_circle, color: statusColor, size: 20);
        statusText = "営業中";
        endTimeText = "営業終了: ${times[1]}"; // 終了時間を追加
      } else {
        statusColor = Colors.red;
        statusIcon = Icon(Icons.remove_circle, color: statusColor, size: 20);
        statusText = "営業時間外";
      }
    }

    return Container(
      width: 320.0,
      height: 240.0,
      margin: EdgeInsets.only(
        left: 5,
        top: 0,
        bottom: 0,
      ),
      child: GestureDetector(
        onTap: () {
          BottomTabPage.selectServiceTab(context);
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
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
                child: Image.asset(
                  'assets/${facilityName}.png',
                  width: 320,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$facilityName',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(), // これを入れると、次のRow内のウィジェットが右端に寄せられる
                        Text(
                          '$time',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        statusIcon,
                        SizedBox(width: 5.0),
                        Text(statusText,
                            style: TextStyle(color: statusColor, fontSize: 15)),
                        if (endTimeText.isNotEmpty) ...[
                          SizedBox(width: 10.0),
                          Text(endTimeText,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15)),
                        ]
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
