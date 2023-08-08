import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:light/light.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/control/control_add.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/util/flutter_ble_mannager.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:light_project/widget/custom_dialog.dart';

class ControlIndex extends StatefulWidget {
  const ControlIndex({Key? key}) : super(key: key);

  @override
  State<ControlIndex> createState() => _ControlIndexState();
}

class _ControlIndexState extends State<ControlIndex> {
  List itemList = [];
  int selectIndex = -1;
  late Light _light;
  late StreamSubscription _subscription;
  @override
  void initState() {
    super.initState();
    getRequest();
    // initBle();
    // startBle();
  }

  getRequest() {
    ServiceRequest.post(
      'scene/memberScene',
      data: {},
      showProgress: false,
      success: (res) {
        itemList = res['data'];
        setState(() {});
      },
      error: (error) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgColor,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        decoration: _bgImage(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _textWidget(),
            Expanded(child: _sceneListContainer()),
            Padding(
              padding: EdgeInsets.only(top: 48.w, bottom: 30.w),
              child: CustomButton(
                width: 529.w,
                height: 90.w,
                title: '一键执行',
                onTap: () => startListening(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textWidget() {
    return Container(
      padding: EdgeInsets.only(top: 150.w),
      alignment: Alignment.centerLeft,
      child: Text(
        '选择需要运用的场景',
        style: TextStyle(
          fontSize: 30.sp,
          fontWeight: FontWeight.bold,
          color: AppConfig.textMainColor,
        ),
      ),
    );
  }

  Widget _sceneListContainer() {
    return Container(
      margin: EdgeInsets.only(top: 48.w),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.w),
        color: Colors.white,
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          StaggeredGrid.count(
            crossAxisCount: 3,
            mainAxisSpacing: 38.w,
            crossAxisSpacing: 16.w,
            children: gridList(),
          )
        ],
      ),
    );
  }

  List<Widget> gridList() {
    List<Widget> li = [];
    for (var i = 0; i < itemList.length; i++) {
      li.add(
        _gridItem(i),
      );
    }

    li.add(
      Padding(
        padding: EdgeInsets.only(top: 9.w, right: 9.w),
        child: GestureDetector(
          onTap: () {
            Get.to(ControlAdd())!.then((res) {
              if (res != null) {
                getRequest();
              }
            });
          },
          child: Image.asset(
            'images/control_add.png',
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
    return li;
  }

  Widget _gridItem(index) {
    Map item = itemList[index];
    bool hasDel = false;
    bool hasSelected = false;
    return StatefulBuilder(builder: (context, state) {
      return GestureDetector(
        onLongPress: () {
          hasDel = true;
          state(() {});
        },
        onTap: () {
          if (hasDel) {
            hasDel = false;
          }
          selectIndex = index;
          setState(() {});
        },
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: 9.w, right: 9.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                border: Border.all(
                    color: selectIndex == index
                        ? AppConfig.mainColor
                        : Colors.transparent,
                    width: 4.w),
              ),
              child: Column(
                children: [
                  Container(
                    height: 220.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.w),
                      image: DecorationImage(
                        image: NetworkImage(
                          item['image'],
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.w),
                  Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 26.sp,
                      color: AppConfig.textMainColor,
                    ),
                  ),
                  SizedBox(height: 10.w),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Visibility(
                visible: hasDel,
                child: GestureDetector(
                  onTap: () {
                    delItem(index);
                  },
                  child: Image.asset(
                    'images/del_image.png',
                    width: 34.w,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  Decoration _bgImage() {
    return const BoxDecoration(
        image: DecorationImage(
      alignment: Alignment.topCenter,
      image: AssetImage(
        'images/control_bg.png',
      ),
      fit: BoxFit.fitWidth,
    ));
  }

  delItem(index) {
    CustomDialog.showCustomDialog(
      context,
      child: Container(
        width: 600.w,
        height: 551.w,
        padding: EdgeInsets.only(bottom: 47.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.w),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                  child: Text(
                '您是否确认删除${itemList[index]['title']}',
                style: TextStyle(
                  fontSize: 30.sp,
                  color: AppConfig.textMainColor,
                ),
              )),
            ),
            Column(
              children: [
                CustomButton(
                  title: '确定',
                  width: 540.w,
                  height: 80.w,
                  onTap: () {
                    delRequest(itemList[index]['id']);
                  },
                ),
                SizedBox(
                  height: 36.w,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    '取消',
                    style: TextStyle(
                      fontSize: 26.sp,
                      color: AppConfig.textSecondColor,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  delRequest(id) {
    ServiceRequest.post(
      'scene/delScene',
      data: {'id': id},
      success: (res) {
        Navigator.pop(context);
        selectIndex = -1;
        getRequest();
      },
      error: (error) {},
    );
  }

  void onData(int luxValue) async {
    print("Lux value: $luxValue");
    setState(() {});
  }

  void stopListening() {
    _subscription.cancel();
  }

  void startListening() {
    _light = Light();
    try {
      _subscription = _light.lightSensorStream.listen(onData);
    } on LightException catch (exception) {
      print('error$exception');
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
