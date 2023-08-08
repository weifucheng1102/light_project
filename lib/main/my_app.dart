import 'package:flutter/cupertino.dart';
import 'package:light_project/util/event.dart';

import 'launch_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  // ///请求新版本request
  // updateVersionRequest() async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   String verStr = packageInfo.version.replaceAll('.', '');
  //   int version = int.parse(verStr);
  //   print('版本号：$version');
  //   ServiceRequest.get(
  //     'index/app_version',
  //     data: {},
  //     success: (res) {
  //       String temp = res['data']['app_version'];
  //       print(temp);
  //       if (int.parse(temp) > version) {
  //         updateApp(res['data']);
  //       }
  //     },
  //     error: (res) {},
  //   );
  // }

  // updateApp(Map data) async {
  //   showCupertinoDialog(
  //       context: context,
  //       builder: (ctx) {
  //         return CupertinoAlertDialog(
  //           title: Text('有新版本可更新啦~'),
  //           // content: Column(
  //           //   children: [
  //           //     SizedBox(
  //           //       height: 20.w,
  //           //     ),
  //           //     Align(
  //           //       child: Text(data['content'] ?? ''),
  //           //       alignment: Alignment(0, 0),
  //           //     )
  //           //   ],
  //           // ),
  //           actions: [
  //             CupertinoDialogAction(
  //               child: Text('取消'),
  //               onPressed: () {
  //                 Navigator.pop(ctx);
  //               },
  //             ),
  //             CupertinoDialogAction(
  //               child: Text('更新'),
  //               onPressed: () {
  //                 Navigator.pop(ctx);
  //                 showDialog(
  //                     context: context,
  //                     barrierDismissible: false,
  //                     builder: (BuildContext context) {
  //                       return Update(url: data['down_url']);
  //                     });
  //               },
  //             )
  //           ],
  //         );
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    return LaunchPage();
  }
}
