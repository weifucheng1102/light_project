import 'dart:async';

import 'package:ali_iot_plugin/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:light_project/space/connect_wifi.dart';
import 'package:light_project/util/common.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:light_project/widget/custom_dialog.dart';
import 'package:light_project/widget/custom_label.dart';
import 'package:light_project/widget/submit_success.dart';
import 'package:light_project/widget/water_ripples.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/app.dart';

class SearchDevices extends StatefulWidget {
  //final subspace_id;
  const SearchDevices({
    Key? key,
    // required this.subspace_id,
  }) : super(key: key);

  @override
  State<SearchDevices> createState() => _SearchDevicesState();
}

class _SearchDevicesState extends State<SearchDevices> {
  List findDeviceList = [];
  String discoverTypes = '';
  bool isSearching = true;
  Timer? timer;

  ///搜索时间
  int searchTimeCount = 60;

  @override
  void dispose() {
    super.dispose();
    cancelTimer();
    DispatchNetAPI.stopDiscovery();
  }

  @override
  void initState() {
    super.initState();
    startSearch();
  }

  startSearch() async {
    // bool permissions = await requestPermission(Permission.locationAlways);
    // bool permissions1 = await requestPermission(Permission.accessMediaLocation);
    // bool bluetoothPermission =
    bool bluePermission = await requestPermission(Permission.bluetoothScan);
    bool bluePermission1 = await requestPermission(Permission.bluetoothConnect);

    if (!bluePermission || !bluePermission1) {
      showToast('蓝牙权限未开启');
      return;
    }
    bool permission1 = await requestPermission(Permission.location);

    if (!permission1) {
      showToast('定位权限未开启');
      return;
    }
    findDeviceList = [];
    isSearching = true;
    searchTimeCount = 60;
    setState(() {});

    DispatchNetAPI.startDiscovery(
      (discoveryType, deviceList) {
        print('搜索到的设备');
        print(deviceList);
        findDeviceList = deviceList;
        discoverTypes = discoveryType.toString();
        isSearching = false;
        cancelTimer();
        setState(() {});
        if (findDeviceList.isEmpty) {
          noDataDialog();
        }
      },
    );

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      searchTimeCount--;
      if (searchTimeCount <= 0) {
        cancelTimer();
        DispatchNetAPI.stopDiscovery();
        isSearching = false;
        setState(() {});
        noDataDialog();
      }
    });
  }

  cancelTimer() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgColor,
      appBar: MyAppBar(
        title: '自动发现',
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 30.w),
        child: isSearching
            ? WaterRipples(size: 1.sw)
            : ListView.separated(
                padding: EdgeInsets.all(30.w),
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.w),
                      color: Colors.white,
                    ),
                    child: CustomLabel(
                      image: Image.asset(
                        'images/space_index_light_1.png',
                        width: 60.w,
                      ),
                      label: findDeviceList[index]['product_Id'] ?? '1',
                      input: '',
                      hasRight: true,
                      callback: () {
                        DispatchNetAPI.stopDiscovery();
                        Get.to(
                          ConnectWifi(
                            deviceInfo: findDeviceList[index],
                          ),
                        );
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 20.w,
                  );
                },
                itemCount: findDeviceList.length,
              ),
      ),
    );
  }

  noDataDialog() {
    CustomDialog.showCustomDialog(
      context,
      barrierDismissible: false,
      child: SubmitSuccess(
        title: '搜索结果',
        desc: '未发现设备',
        bottomButtons: [
          CustomButton(
            title: '确定',
            width: 220.w,
            height: 84.w,
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          CustomButton(
            title: '重新搜索',
            width: 220.w,
            height: 84.w,
            onTap: () {
              Navigator.pop(context);
              startSearch();
            },
          )
        ],
      ),
    );
  }
}
