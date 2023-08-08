import 'dart:io';

import 'package:ali_iot_plugin/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/space/connect_devices.dart';
import 'package:light_project/util/event.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:light_project/widget/custom_dialog.dart';
import 'package:light_project/widget/custom_label.dart';
import 'package:light_project/widget/submit_success.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/app.dart';
import '../util/common.dart';

class ConnectWifi extends StatefulWidget {
  final Map deviceInfo;
  const ConnectWifi({
    Key? key,
    required this.deviceInfo,
  }) : super(key: key);

  @override
  State<ConnectWifi> createState() => _ConnectWifiState();
}

class _ConnectWifiState extends State<ConnectWifi> with WidgetsBindingObserver {
  String? wifiName;
  String? wifiSsid;
  TextEditingController passwordCon = TextEditingController(text: '');
  bool passwordOpen = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        print('活动');
        break;
      case AppLifecycleState.resumed:
        print('进入前台');

        getWifiInfo();

        break;
      case AppLifecycleState.paused:
        print('进入后台');
        break;
      case AppLifecycleState.detached:
        print('杀死');
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    getWifiInfo();
    WidgetsBinding.instance.addObserver(this);
  }

  getWifiInfo() async {
    bool isSuccess = await requestPermission(Permission.location);
    if (isSuccess) {
      final info = NetworkInfo();
      wifiName = await info.getWifiName();
      if (Platform.isAndroid &&
          wifiName != null &&
          wifiName!.startsWith("") &&
          wifiName!.endsWith("")) {
        wifiName = wifiName!.substring(1, wifiName!.length - 1);
      }
      wifiSsid = await info.getWifiBSSID();
      setState(() {});
    } else {
      showToast('定位权限未通过');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgColor,
      appBar: MyAppBar(
        title: '连接Wi-Fi',
      ),
      body: ListView(
        padding: EdgeInsets.all(30.w),
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(24.w, 44.w, 24.w, 105.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.w),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '连接Wi-Fi',
                  style: TextStyle(
                    fontSize: 36.sp,
                    color: AppConfig.textMainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 13.w,
                ),
                Row(
                  children: [
                    Image.asset(
                      'images/wifi_notice.png',
                      width: 26.w,
                    ),
                    Text(
                      ' 只支持2.4G Wi-Fi 网络',
                      style: TextStyle(
                        fontSize: 26.sp,
                        color: AppConfig.textSecondColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 100.w,
                ),
                CustomLabel(
                  label: 'Wi-Fi名称',
                  input: wifiName ?? '',
                  inputStyle: TextStyle(
                    fontSize: 28.sp,
                    color: AppConfig.textMainColor,
                  ),
                  tip: '切换Wi-Fi',
                  hasBottomLine: true,
                  rightImage: Image.asset(
                    'images/wifi_change.png',
                    width: 40.w,
                  ),
                  callback: () {
                    DispatchNetAPI.openSystemWiFi();
                  },
                ),
                CustomLabel(
                  label: 'Wi-Fi密码',
                  input: '',
                  tip: '请输入Wi-Fi密码',
                  hasBottomLine: true,
                  textCon: passwordCon,
                  isObscure: !passwordOpen,
                  rightImage: GestureDetector(
                    onTap: () {
                      passwordOpen = !passwordOpen;
                      setState(() {});
                    },
                    child: Image.asset(
                      passwordOpen
                          ? 'images/wifi_open.png'
                          : 'images/wifi_close.png',
                      width: 40.w,
                    ),
                  ),
                ),
                SizedBox(
                  height: 200.w,
                ),
                CustomButton(
                  title: '下一步',
                  onTap: () async {
                    if (wifiSsid == null) {
                      showToast('请链接Wi-Fi');
                      return;
                    }
                    if (passwordCon.text.isEmpty) {
                      CustomDialog.showCustomDialog(
                        context,
                        child: SubmitSuccess(
                          title: '提示',
                          desc: '当前Wi-Fi不需要输入密码？',
                          bottomButtons: [
                            CustomButton(
                              title: '取消',
                              width: 220.w,
                              height: 84.w,
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                            CustomButton(
                              title: '确定',
                              width: 220.w,
                              height: 84.w,
                              onTap: () {
                                Navigator.pop(context);
                                toToConnectDevices();
                              },
                            )
                          ],
                        ),
                      );
                      return;
                    }
                    toToConnectDevices();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  toToConnectDevices() {
    ServiceRequest.post(
      'lamp/getProductKey',
      data: {'Product_ID': widget.deviceInfo['productId']},
      success: (res) {
        Get.to(
          ConnectDevices(
            ssid: wifiSsid!,
            password: passwordCon.text,
            deviceInfo: widget.deviceInfo,
            productKey: res['data'],
          ),
        );
      },
      error: (error) {},
    );
  }
}
