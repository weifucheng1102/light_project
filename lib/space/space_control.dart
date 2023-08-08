import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:light_project/widget/custom_label.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../util/common.dart';

class SpaceControl extends StatefulWidget {
  const SpaceControl({Key? key}) : super(key: key);

  @override
  State<SpaceControl> createState() => _SpaceControlState();
}

class _SpaceControlState extends State<SpaceControl> {
  List itemList = [];
  int selectIndex = -1;
  double tempData = 0;
  bool switchData = true;
  double lightData = 0;
  bool lightSwitch = false;
  @override
  void initState() {
    super.initState();
    getRequest();
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            alignment: Alignment.topCenter,
            fit: BoxFit.fitWidth,
            image: AssetImage(
              'images/space_control_bg.png',
            ),
          ),
        ),
        child: Column(
          children: [
            MyAppBar(
              title: '一键调控',
              backgroundColor: Colors.transparent,
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(30.w),
                itemBuilder: (context, index) {
                  return listWidget()[index];
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 40.w,
                  );
                },
                itemCount: listWidget().length,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _submitButton(),
    );
  }

  _sceneWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '使用场景快捷控制',
          style: TextStyle(
            fontSize: 30.sp,
            color: AppConfig.textMainColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 46.w,
        ),
        Container(
          height: 395.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.w),
            color: Colors.white,
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(30.w),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  if (selectIndex != index) {
                    selectIndex = index;
                    setState(() {});
                  }
                },
                child: SizedBox(
                  width: 180.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.w),
                        child: Image.network(
                          itemList[index]['image'],
                          width: 180.w,
                          height: 220.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        itemList[index]['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 26.sp,
                          color: AppConfig.textMainColor,
                        ),
                      ),
                      Image.asset(
                        selectIndex == index
                            ? 'images/sel.png'
                            : 'images/sel_un.png',
                        width: 34.w,
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(
                width: 24.w,
              );
            },
            itemCount: itemList.length,
          ),
        ),
      ],
    );
  }

  List<Widget> listWidget() {
    List<Widget> list = [];
    if (itemList.isNotEmpty) {
      list.add(_sceneWidget());
    }
    list.addAll([
      _tempWidget(),
      _lightWidget(),
    ]);
    return list;
  }

  _tempWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '色温调节',
          style: TextStyle(
            fontSize: 30.sp,
            color: AppConfig.textMainColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 20.w,
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 36.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.w),
          ),
          child: SleekCircularSlider(
            initialValue: tempData,
            min: 0,
            max: 1000,
            appearance: CircularSliderAppearance(
              size: 306.w,
              customWidths: CustomSliderWidths(
                trackWidth: 40.w,
                progressBarWidth: 40.w,
                handlerSize: 16.w,
                shadowWidth: 0.w,
              ),
              customColors: CustomSliderColors(
                dotColor: Colors.white,
                hideShadow: true,
                trackColors: [
                  const Color(0xff9edfff),
                  const Color(0xfffefaf3),
                  AppConfig.mainColor,
                ],
                progressBarColors: [
                  const Color(0xff9edfff),
                  const Color(0xfffefaf3),
                  AppConfig.mainColor,
                ],
              ),
            ),
            onChangeEnd: (double value) {
              tempData = value;
              setState(() {});
            },
            innerWidget: (double value) {
              return Center(
                child: InkWell(
                  onTap: () {
                    lightSwitch = !lightSwitch;
                    setState(() {});
                  },
                  child: Image.asset(
                    lightSwitch
                        ? 'images/light_on.png'
                        : 'images/light_off.png',
                    width: 127.w,
                  ),
                ),
              );
              //   return Container(
              //     width: 100.w,
              //     child: Image.asset(
              //       'images/light_on.png',
              //       width: 117.w,
              //       fit: BoxFit.fill,
              //     ),
              //   );
            },
          ),
        ),
      ],
    );
  }

  _lightWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '亮度调节',
          style: TextStyle(
            fontSize: 30.sp,
            color: AppConfig.textMainColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 20.w,
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 36.w, horizontal: 24.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.w),
          ),
          child: Row(
            children: [
              Image.asset(
                'images/light_sun.png',
                width: 36.w,
              ),
              Expanded(
                child: Slider(
                  activeColor: AppConfig.mainColor,
                  inactiveColor: Color(0xffDFE0DF),
                  thumbColor: Colors.white,
                  min: 0,
                  max: 100,
                  value: lightData,
                  onChanged: (res) {
                    lightData = res;
                    setState(() {});
                  },
                ),
              ),
              SizedBox(
                width: 100.w,
                child: Text(
                  lightData.toInt().toString() + '%',
                  style: TextStyle(
                    fontSize: 26.sp,
                    color: AppConfig.textMainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20.w,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.w),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: CustomLabel(
            height: 100.w,
            label: '批量关闭/开启',
            input: '',
            rightWidget: CupertinoSwitch(
              value: switchData,
              onChanged: (res) {
                switchData = res;
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }

  _submitButton() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              width: 686.w,
              height: 88.w,
              title: '确定',
            ),
          ],
        ),
      ),
    );
  }
}
