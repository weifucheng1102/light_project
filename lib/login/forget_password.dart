import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_label.dart';
import 'package:oktoast/oktoast.dart';

import '../widget/custom_button.dart';

class ForgetPassword extends StatefulWidget {
  ///是否是重置密码
  final bool isReset;
  const ForgetPassword({Key? key, required this.isReset}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  RxBool canSubmit = false.obs;
  TextEditingController phoneCon = TextEditingController(text: '');
  TextEditingController codeCon = TextEditingController(text: '');
  TextEditingController passwordCon = TextEditingController(text: '');
  TextEditingController repasswordCon = TextEditingController(text: '');

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
      backgroundColor: AppConfig.bgColor,
      appBar: MyAppBar(
        title: widget.isReset ? '修改密码' : '忘记密码',
      ),
      body: ListView(
        padding: EdgeInsets.all(30.w),
        physics: const ClampingScrollPhysics(),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.w),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                _phoneField(),
                _codeField(),
                _passwordField(),
                _repasswordField(),
                SizedBox(height: 104.w),
                Obx(
                  () => CustomButton(
                    title: '确认修改',
                    height: 90.w,
                    textColor: canSubmit.value
                        ? AppConfig.textMainColor
                        : const Color(0xff6e7793),
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
                SizedBox(height: 96.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _phoneField() {
    return CustomLabel(
      label: '手机号',
      input: '',
      height: 120.w,
      tip: '请输入手机号',
      textCon: phoneCon,
      hasBottomLine: true,
      onChanged: (res) {
        _inputChangeAction();
      },
    );
  }

  _codeField() {
    return CustomLabel(
      label: '验证码',
      input: '',
      height: 120.w,
      hasBottomLine: true,
      rightWidget: Expanded(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                textAlign: TextAlign.right,
                controller: codeCon,
                keyboardType: TextInputType.number,
                decoration: InputDecoration.collapsed(
                  hintText: '请输入验证码',
                  hintStyle: TextStyle(
                    fontSize: 28.sp,
                    color: AppConfig.textSecondColor,
                  ),
                ),
                onChanged: (res) {
                  _inputChangeAction();
                },
              ),
            ),
            SizedBox(
              width: 30.w,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30.w),
              child: Container(
                color: AppConfig.mainColor,
                width: 2.w,
              ),
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
                            ? AppConfig.textSecondColor
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
    );
  }

  _passwordField() {
    return CustomLabel(
      label: '密码',
      input: '',
      height: 120.w,
      tip: '请输入密码',
      textCon: passwordCon,
      isObscure: true,
      hasBottomLine: true,
      keyboardType: TextInputType.emailAddress,
      onChanged: (res) {
        _inputChangeAction();
      },
    );
  }

  _repasswordField() {
    return CustomLabel(
      label: '确认密码',
      input: '',
      height: 120.w,
      tip: '请再次输入密码',
      textCon: repasswordCon,
      isObscure: true,
      hasBottomLine: true,
      keyboardType: TextInputType.emailAddress,
      onChanged: (res) {
        _inputChangeAction();
      },
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
      'member/send',
      data: {
        'phone': phoneCon.text,
        'type': 3,
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
    if (phoneCon.text.isNotEmpty &&
        codeCon.text.isNotEmpty &&
        passwordCon.text.isNotEmpty &&
        repasswordCon.text.isNotEmpty) {
      canSubmit.value = true;
    } else {
      canSubmit.value = false;
    }
  }

  ///请求
  registRequest() {
    Map<String, dynamic> map = {
      'password': passwordCon.text,
      'phone': phoneCon.text,
      'code': codeCon.text,
      'next_pw': repasswordCon.text,
    };

    ServiceRequest.post(
      'member/changePw',
      data: map,
      success: (res) {
        Get.back();
      },
      error: (errer) {},
    );
  }
}
