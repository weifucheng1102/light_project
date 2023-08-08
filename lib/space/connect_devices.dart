import 'dart:async';

import 'package:ali_iot_plugin/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:light_project/widget/custom_dialog.dart';
import 'package:light_project/widget/submit_success.dart';
import 'package:light_project/widget/water_ripples.dart';

class ConnectDevices extends StatefulWidget {
  final String ssid;
  final String password;
  final Map deviceInfo;
  final String productKey;
  const ConnectDevices({
    Key? key,
    required this.ssid,
    required this.password,
    required this.deviceInfo,
    required this.productKey,
  }) : super(key: key);

  @override
  State<ConnectDevices> createState() => _ConnectDevicesState();
}

class _ConnectDevicesState extends State<ConnectDevices> {
  bool isConnecting = true;
  String str = '';

  Timer? completeTimer;
  int completeTimeCount = 0;

  List messageList = [];

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    addDevice();
  }

  addDevice() {
    DispatchNetAPI.startAddDevice(
      //widget.deviceInfo['linkType'],
      //'ForceAliLinkTypeBroadcast',
      'ForceAliLinkTypeBLE',
      (stage, stageData) {
        messageList.add('$stage状态$stageData');
        setState(() {});

        ///配网结果
        // if (stage == 'onProvisionedResult') {
        //   finishAddDevice(
        //     connectSuccess: stageData['isSuccess'],
        //     info: stageData,
        //   );
        // }
      },
      productId: widget.deviceInfo['productId'],
      productKey: widget.productKey,
      // protocolVersion: widget.deviceInfo['protocolVersion'],
      //productKey: 'a1e8VfGF03x',
      // id: widget.deviceInfo['id'],
      getWifi: () async {
        return {'ssid': widget.ssid, 'password': widget.password};
      },
    );
    // completeTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
    //   completeTimeCount++;
    //   setState(() {});
    //   if (completeTimeCount >= 100) {
    //     stopAddDevice();
    //   }
    // });
  }

  stopAddDevice() {
    stopTimer();
    isConnecting = false;
    setState(() {});
    finishAddDevice(connectSuccess: false);
  }

  stopTimer() {
    DispatchNetAPI.stopAddDevice();
    if (completeTimer != null) {
      completeTimer!.cancel();
      completeTimer = null;
    }
  }

  finishAddDevice({
    required bool connectSuccess,
    Map? info,
  }) async {
    if (connectSuccess) {
      ///绑定设备与token
      dynamic strrrr = await DispatchNetAPI.bindByToken(
          info!['deviceInfo']['productKey'],
          info['deviceInfo']['deviceName'],
          info['deviceInfo']['token']);
      messageList.add(strrrr);
      setState(() {});
    }
    // stopTimer();

    // ignore: use_build_context_synchronously
    CustomDialog.showCustomDialog(
      context,
      barrierDismissible: false,
      child: SubmitSuccess(
        title: '配网结果',
        desc: connectSuccess ? '设备配网成功' : '设备配网失败',
        buttonText: connectSuccess ? '确定' : '重新配网',
        onTap: () {
          if (connectSuccess) {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
          } else {
            Navigator.pop(context);
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: '设备配网',
      ),
      body: !isConnecting
          ? SizedBox()
          : Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100.w,
                  ),
                  Text(
                    '设备添加中...',
                    style: TextStyle(
                      fontSize: 40.sp,
                      color: AppConfig.textMainColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                      child: ListView(
                    children:
                        messageList.map((e) => Text(e.toString())).toList(),
                  )),
                  // Expanded(
                  //     child: Stack(
                  //   alignment: Alignment.center,
                  //   children: [
                  //     WaterRipples(size: 1.sw),
                  //     Container(
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(100.w),
                  //         color: Colors.blue,
                  //       ),
                  //       alignment: Alignment.center,
                  //       width: 200.w,
                  //       height: 200.w,
                  //       child: Text.rich(TextSpan(
                  //         children: [
                  //           TextSpan(
                  //             text: completeTimeCount.toString(),
                  //             style: TextStyle(
                  //               fontSize: 65.sp,
                  //               fontFamily: 'HarmonyOS',
                  //               fontWeight: FontWeight.bold,
                  //               color: Colors.white,
                  //             ),
                  //           ),
                  //           TextSpan(
                  //             text: ' %',
                  //             style: TextStyle(
                  //               color: Colors.white,
                  //               fontSize: 30.sp,
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //           ),
                  //         ],
                  //       )),
                  //     ),
                  //   ],
                  // ))
                ],
              ),
            ),
    );
  }
}
