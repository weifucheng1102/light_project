import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/config/get_box.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:oktoast/oktoast.dart';

import '../service/service_request.dart';
import '../widget/custom_appbar.dart';


class BindPhone extends StatefulWidget {
  final dynamic id;
  const BindPhone({Key? key, required this.id}) : super(key: key);

  @override
  State<BindPhone> createState() => _BindPhoneState();
}

class _BindPhoneState extends State<BindPhone> {
  RxBool canSubmit = false.obs;
  TextEditingController phoneCon = TextEditingController();
  TextEditingController codeCon = TextEditingController();
  Timer? _timer;

  int _countdownTime = 0;
  var downTimerState;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: '绑定手机号',
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120.w,
            ),
            _phoneField(),
            _codeField(),
            SizedBox(
              height: 100.w,
            ),
            Obx(
              () => CustomButton(
                height: 88.w,
                width: 1.sw - 60.w,
                title: '确定',
                textColor:
                    canSubmit.value ? Colors.white : const Color(0xff6e7793),
                bgColor: canSubmit.value
                    ? AppConfig.mainColor
                    : const Color(0xfff1f1f1),
                onTap: () {
                  if (canSubmit.value) {
                    registRequest();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _phoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 40.w),
          child: TextField(
            controller: phoneCon,
            keyboardType: TextInputType.number,
            decoration: InputDecoration.collapsed(
              hintText: '请输入手机号',
              hintStyle: TextStyle(
                fontSize: 28.sp,
                color: const Color(0xffc6c7cb),
              ),
            ),
            onChanged: (res) {
              _inputChangeAction();
            },
          ),
        ),
        Divider(
          height: 1.w,
          color: AppConfig.lineColor,
        )
      ],
    );
  }

  _codeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 40.w),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: codeCon,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration.collapsed(
                    hintText: '请输入验证码',
                    hintStyle: TextStyle(
                      fontSize: 28.sp,
                      color: const Color(0xffB7BFD0),
                    ),
                  ),
                  onChanged: (res) {
                    _inputChangeAction();
                  },
                ),
              ),
              SizedBox(
                width: 10.w,
              ),
              GestureDetector(
                onTap: () {
                  getSmsCodeRequest();
                },
                child: StatefulBuilder(
                  builder: (context, state) {
                    downTimerState = state;
                    return Container(
                      width: 164.w,
                      alignment: Alignment.center,
                      child: Text(
                        _countdownTime > 0 ? '$_countdownTime' 's' : '获取验证码',
                        style: TextStyle(
                          fontSize: 28.sp,
                          color: _countdownTime > 0
                              ? const Color(0xffB7BFD0)
                              : AppConfig.mainColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1.w,
          color: AppConfig.lineColor,
        )
      ],
    );
  }

  //*============================================================================================================================*//
  ///获取验证码
  getSmsCodeRequest() {
    if (_countdownTime != 0) {
      return;
    }

    if (phoneCon.text.isEmpty) {
      showToast('请输入手机号');
      return;
    }
    ServiceRequest.post(
      'sms_send',
      data: {
        'mobile': phoneCon.text,
        'event': 'bind',
      },
      success: (res) {
        showToast(res['msg'], duration: const Duration(seconds: 3));
        startCountdownTimer();
      },
      error: (errer) {},
    );
  }

  void startCountdownTimer() {
    _countdownTime = 60;

    _timer = Timer.periodic(
        const Duration(seconds: 1),
        (Timer timer) => {
              downTimerState(() {
                if (_countdownTime < 1) {
                  _timer!.cancel();
                } else {
                  _countdownTime = _countdownTime - 1;
                }
              })
            });
  }

  _inputChangeAction() {
    if (phoneCon.text.isNotEmpty && codeCon.text.isNotEmpty) {
      canSubmit.value = true;
    } else {
      canSubmit.value = false;
    }
  }

  ///请求
  registRequest() {
    Map<String, dynamic> map = {
      'mobile': phoneCon.text,
      'captcha': codeCon.text,
      'captcha_type': 'bind',
      'uid': widget.id,
    };

    ServiceRequest.post(
      'bindmobile',
      data: map,
      success: (res) {
        getBox.write('token', res['data']['token']);
        // NavKey.navKey.currentState!.pushAndRemoveUntil(
        //     MaterialPageRoute(
        //       builder: (context) => const NavigationPage(),
        //     ),
        //     (route) => route == null);
      },
      error: (errer) {},
    );
  }
}
