import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oktoast/oktoast.dart';

import 'config/nav_key.dart';
import 'main/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(
    ScreenUtilInit(
        designSize: const Size(750, 1334),
        builder: (context, child) {
          return OKToast(
            child: GetMaterialApp(
              title: '韬光智慧',
              localizationsDelegates: const [
// 本地化代理
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('zh', 'CN')],
              theme: ThemeData(
                ///微软雅黑字体
                //fontFamily: 'msyh',
                scaffoldBackgroundColor: Colors.white,
              ),
              navigatorKey: NavKey.navKey,
              home: const MyApp(),
              builder: EasyLoading.init(
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    child: KeyboardDismissOnTap(
                      dismissOnCapturedTaps: true,
                      child: child!,
                    ),
                  );
                },
              ),
            ),
          );
        }),
  );
}
