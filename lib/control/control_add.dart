import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/picker_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/control/control_custom_add.dart';
import 'package:light_project/mine/help_center.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_dialog.dart';

class ControlAdd extends StatefulWidget {
  const ControlAdd({Key? key}) : super(key: key);

  @override
  State<ControlAdd> createState() => _ControlAddState();
}

class _ControlAddState extends State<ControlAdd> {
  List itemList = [];

  Map pickerData = {};

  chooseSceneRequest(id) {
    ServiceRequest.post('scene/chooseScene', data: {
      'type': 1,
      'scene_id': id,
    }, success: (res) {
      EasyLoading.showSuccess('添加成功', duration: Duration(seconds: 1));
      Future.delayed(Duration(seconds: 1), () {
        Get.back(result: true);
      });
    }, error: (error) {});
  }

  @override
  void initState() {
    super.initState();
    getRequest();
  }

  getRequest() {
    ServiceRequest.post(
      'scene/sceneCate',
      data: {},
      success: (res) {
        itemList = res['data'];
        getData();
      },
      error: (error) {},
    );
  }

  getData() {
    itemList.forEach((element) {
      String keystr = element['name'];
      Map dic = {keystr: {}};
      pickerData.addAll(dic);
      List secondList = element['sec_cate'];
      secondList.forEach((element) {
        String secondkeystr = element['name'];
        List thirdList = element['third_cate'];
        Map secondDic = {
          secondkeystr: thirdList.map((e) => e['name']).toList(),
        };
        pickerData[keystr].addAll(secondDic);
      });
    });

    print(pickerData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgColor,
      appBar: MyAppBar(
        title: '添加场景',
        actions: [
          _rightButton(),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(30.w),
        children: [
          Image.asset('images/control_banner.png'),
          SizedBox(
            height: 30.w,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.w),
              color: Colors.white,
            ),
            child: Column(
              children: [
                _selectItem(
                    color: Color(0xfffff9eb),
                    titleColor: Color(0xffD5B364),
                    leftImg: 'images/control_left_1.png',
                    title: '选择场景',
                    desc: '从系统场景库选择场景',
                    rightImg: 'images/control_right_1.png',
                    onTap: () {
                      Pickers.showMultiLinkPicker(
                        context,
                        data: pickerData,
                        columeNum: 3,
                        pickerStyle: PickerStyle(
                          textSize: 28.sp,
                        ),
                        onConfirm: (List p, index) {
                          print(index);

                          int id = itemList[index[0]]['sec_cate'][index[1]]
                              ['third_cate'][index[2]]['id'];
                          print(id);
                          chooseSceneRequest(id);
                        },
                      );
                    }),
                SizedBox(
                  height: 30.w,
                ),
                _selectItem(
                    color: Color(0xffF1FBE0),
                    titleColor: Color(0xff8FBD36),
                    leftImg: 'images/control_left_2.png',
                    title: '自定义场景',
                    desc: '根据自身的需要自定义场景',
                    rightImg: 'images/control_right_2.png',
                    onTap: () {
                      Get.to(ControlCustomAdd());
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectItem(
      {required Color color,
      required Color titleColor,
      required String leftImg,
      required String title,
      required String desc,
      required String rightImg,
      void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            EdgeInsets.only(left: 39.w, right: 24.w, top: 45.w, bottom: 45.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.w),
          color: color,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  leftImg,
                  width: 69.w,
                ),
                SizedBox(
                  width: 20.w,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 30.sp,
                        color: AppConfig.textMainColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 26.sp,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Image.asset(
              rightImg,
              width: 36.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _rightButton() {
    return Padding(
      padding: EdgeInsets.only(right: 10.w),
      child: TextButton(
        onPressed: () {
          Get.to(HelpCenter());
        },
        child: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: AppConfig.textMainColor,
              size: 36.w,
            ),
            SizedBox(
              width: 4.w,
            ),
            Text(
              '帮助',
              style: TextStyle(
                fontSize: 26.sp,
                color: AppConfig.textMainColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
