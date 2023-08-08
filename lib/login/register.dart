import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/config/get_box.dart';
import 'package:light_project/config/nav_key.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:oktoast/oktoast.dart';

import '../main/navigation_page.dart';
import '../mine/article_detail.dart';
import '../service/service_request.dart';
import '../widget/custom_button.dart';
import '../widget/custom_label.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  RxBool canSubmit = false.obs;
  TextEditingController phoneCon = TextEditingController();
  TextEditingController codeCon = TextEditingController();
  TextEditingController passwordCon = TextEditingController();
  TextEditingController repasswordCon = TextEditingController();
  Timer? _timer;

  int _countdownTime = 0;
  var downTimerState;

  bool xieyiSelect = false;
  var xieyiState;

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
      appBar: const MyAppBar(
        title: '注册',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _xieyiText(),
                    SizedBox(
                      height: 19.w,
                    ),
                    Obx(
                      () => CustomButton(
                        height: 90.w,
                        title: '确认注册',
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
                  ],
                ),
                SizedBox(height: 18.w),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '已有账号，',
                          style: TextStyle(
                            color: AppConfig.textSecondColor,
                            fontSize: 26.sp,
                          ),
                        ),
                        TextSpan(
                          text: '立即登录',
                          style: TextStyle(
                            color: AppConfig.mainColor,
                            fontSize: 26.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 85.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _bottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          child: Text(
            '立即登录',
            style: TextStyle(
              fontSize: 28.sp,
              color: const Color(0xffaaaeb9),
            ),
          ),
          onTap: () {
            Get.back();
          },
        ),
      ],
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

  Widget _xieyiText() {
    return Padding(
      padding: EdgeInsets.only(top: 54.w),
      child: StatefulBuilder(builder: (context, cta) {
        xieyiState = cta;

        return Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {
                    _xieyiClick();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: xieyiSelect
                        ? Icon(
                            Icons.check_circle,
                            size: 36.w,
                            color: AppConfig.mainColor,
                          )
                        : Icon(
                            Icons.radio_button_off,
                            size: 36.w,
                            color: AppConfig.textSecondColor,
                          ),
                  ),
                ),
                alignment: PlaceholderAlignment.middle,
              ),
              TextSpan(
                  text: '同意并阅读',
                  style: TextStyle(
                    color: AppConfig.textSecondColor,
                    fontSize: 26.sp,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _xieyiClick();
                    }),
              TextSpan(
                  text: '《用户协议》',
                  style: TextStyle(
                    color: AppConfig.mainColor,
                    fontSize: 26.sp,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Get.to(
                        const ArticleDetail(
                          type: 1,
                        ),
                      );
                    }),
              TextSpan(
                  text: '和',
                  style: TextStyle(
                    color: AppConfig.textSecondColor,
                    fontSize: 26.sp,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _xieyiClick();
                    }),
              TextSpan(
                  text: '《隐私政策》',
                  style: TextStyle(
                    color: AppConfig.mainColor,
                    fontSize: 26.sp,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Get.to(
                        const ArticleDetail(
                          type: 2,
                        ),
                      );
                    })
            ],
          ),
          style: TextStyle(
            color: const Color(0xffaaaeb9),
            fontSize: 26.sp,
          ),
        );
      }),
    );
  }

  void _xieyiClick() {
    xieyiSelect = !xieyiSelect;
    _inputChangeAction();
    xieyiState(() {});
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
        'type': 1,
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
        repasswordCon.text.isNotEmpty &&
        xieyiSelect) {
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
      'member/register',
      data: map,
      success: (res) {
        getBox.write('token', res['data']['token']);
        getBox.write('user_type', res['data']['user_type']);
        getBox.write('have_space', res['data']['space_num']);
        NavKey.navKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const NavigationPage(),
            ),
            (route) => route == null);
      },
      error: (errer) {},
    );
  }
}
