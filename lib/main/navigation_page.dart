import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/config/get_box.dart';
import 'package:light_project/control/control_index.dart';
import 'package:light_project/group/group_index.dart';
import 'package:light_project/mine/mine_index.dart';
import 'package:light_project/space/space_index.dart';
import 'package:light_project/util/common.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/application.dart';
import '../util/event.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({Key? key}) : super(key: key);

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  Widget getPage() {
    bool have_space = getBox.read('have_space') ?? false;
    if (have_space) {
      switch (_currentIndex) {
        case 0:
          return const SpaceIndex();
        case 1:
          return const GroupIndex();
        case 2:
          return const ControlIndex();
        case 3:
          return const MineIndex();

        default:
          return Container();
      }
    } else {
      switch (_currentIndex) {
        case 0:
          return const ControlIndex();
        case 1:
          return const MineIndex();

        default:
          return Container();
      }
    }
  }

  List<BottomNavigationBarItem> getbottomItems() {
    bool have_space = getBox.read('have_space') ?? false;
    if (have_space) {
      return [
        iconWidget('空间', 'images/tab_0.png', 'images/tab_0_sel.png'),
        iconWidget('群组', 'images/tab_1.png', 'images/tab_1_sel.png'),
        iconWidget('智控', 'images/tab_2.png', 'images/tab_2_sel.png'),
        iconWidget('我的', 'images/tab_3.png', 'images/tab_3_sel.png'),
      ];
    } else {
      return [
        iconWidget('智控', 'images/tab_2.png', 'images/tab_2_sel.png'),
        iconWidget('我的', 'images/tab_3.png', 'images/tab_3_sel.png'),
      ];
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    appl!.tabbarChanged = tabbarChange;
    getPermission();
  }

  getPermission() async {
    await requestPermission(Permission.bluetooth);
    await requestPermission(Permission.bluetoothScan);
    await requestPermission(Permission.bluetoothConnect);
  }

  tabbarChange(int selectIndex, [dynamic result]) {
    _currentIndex = selectIndex;
    print(_currentIndex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getPage(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: AppConfig.textMainColor,
        unselectedItemColor: AppConfig.textSecondColor,
        selectedFontSize: 20.sp,
        unselectedFontSize: 20.sp,
        onTap: (index) {
          _currentIndex = index;
          setState(() {});
        },
        items: getbottomItems(),
      ),
    );
  }

  BottomNavigationBarItem iconWidget(title, imageUrl, selImageUrl) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        imageUrl,
        width: 48.w,
      ),
      activeIcon: Image.asset(
        selImageUrl,
        width: 48.w,
      ),
      label: title,
      tooltip: '',
    );
  }
}
