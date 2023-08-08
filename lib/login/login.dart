import 'dart:async';
import 'dart:ui';

import 'package:ali_iot_plugin/index.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/config/get_box.dart';
import 'package:light_project/config/nav_key.dart';
import 'package:light_project/login/forget_password.dart';
import 'package:light_project/login/register.dart';
import 'package:light_project/main/navigation_page.dart';
import 'package:light_project/mine/article_detail.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:light_project/widget/custom_label.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  TabController? controller;
  TextEditingController phoneCon = TextEditingController(text: '');
  TextEditingController codeCon = TextEditingController(text: '');
  TextEditingController passwordCon = TextEditingController(text: '');
  RxBool canSubmit = false.obs;

  var tabs = <Tab>[];
  int tabIndex = 0;
  Timer? _timer;
  var downTimerState;
  int _countdownTime = 0;
  bool xieyiSelect = false;
  var xieyiState;
  @override
  void initState() {
    super.initState();
    getBox.remove('token');
    Future.delayed(Duration.zero).then((value) async {
      tabs = const <Tab>[
        Tab(
          text: '验证码登录',
        ),
        Tab(
          text: '账号密码登录',
        ),
      ];
      controller = TabController(
          initialIndex: tabIndex, length: tabs.length, vsync: this);
      setState(() {});
    });
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
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          children: [
            _loginImage(),
            _inputWidget(),
          ],
        ),
      ),
    );
  }

  ///登录logo
  Widget _loginImage() {
    return Padding(
      padding: EdgeInsets.only(top: 50.w),
      child: Column(
        children: [
          Image.asset(
            'images/login_logo.png',
            width: 264.w,
          ),
        ],
      ),
    );
  }

  ///信息输入
  Widget _inputWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 37.w, left: 30.w, right: 30.w),
      child: Container(
        padding:
            EdgeInsets.only(left: 37.w, right: 37.w, top: 30.w, bottom: 60.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.w),
          color: Colors.white,
        ),
        child: controller == null
            ? SizedBox()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tabBarWidget(),
                  _phoneWidget(),
                  tabIndex == 0
                      ? _codeWidget()
                      : Column(
                          children: [
                            _passwordWidget(),
                            _forgetAndRegist(),
                          ],
                        ),
                  _xieyiText(),
                  _loginBtn(),
                  _wechatLoginWidget(),
                ],
              ),
      ),
    );
  }

  Widget _tabBarWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      child: TabBar(
        tabs: tabs,
        controller: controller,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: AppConfig.textMainColor,
        indicatorColor: AppConfig.mainColor,
        indicatorWeight: 2.w,
        labelStyle: TextStyle(
          fontSize: 30.sp,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelColor: AppConfig.textSecondColor,
        unselectedLabelStyle: TextStyle(
          fontSize: 28.sp,
        ),
        onTap: (index) {
          if (index != tabIndex) {
            tabIndex = index;
            codeCon.text = '';
            passwordCon.text = '';
            _countdownTime = 0;
            _inputChangeAction();
            setState(() {});
          }
        },
      ),
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

  Widget _phoneWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 48.w),
      child: CustomButton(
        bgColor: AppConfig.bgColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: TextField(
            controller: phoneCon,
            keyboardType: TextInputType.number,
            decoration: InputDecoration.collapsed(
              hintText: '请输入手机号',
              hintStyle: TextStyle(
                fontSize: 30.sp,
                color: const Color(0xff999999),
              ),
            ),
            onChanged: (res) {
              _inputChangeAction();
            },
          ),
        ),
      ),
    );
  }

  Widget _codeWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 48.w),
      child: CustomButton(
        bgColor: AppConfig.bgColor,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: TextField(
                    decoration: InputDecoration.collapsed(
                      hintText: '请输入验证码',
                      hintStyle: TextStyle(
                        fontSize: 30.sp,
                        color: AppConfig.textSecondColor,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    controller: codeCon,
                    onChanged: (res) {
                      _inputChangeAction();
                    },
                  )),
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
              child: StatefulBuilder(builder: (context, state) {
                downTimerState = state;
                return Container(
                  width: 220.w,
                  alignment: Alignment.center,
                  child: Text(
                    _countdownTime > 0 ? '$_countdownTime' 's' : '获取验证码',
                    style: TextStyle(
                      fontSize: 30.sp,
                      color: _countdownTime > 0
                          ? Colors.black
                          : AppConfig.mainColor,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 48.w),
      child: CustomButton(
        bgColor: AppConfig.bgColor,
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: TextField(
              controller: passwordCon,
              obscureText: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration.collapsed(
                hintText: '请输入密码',
                hintStyle: TextStyle(
                  fontSize: 30.sp,
                  color: AppConfig.textSecondColor,
                ),
              ),
              onChanged: (res) {
                _inputChangeAction();
              },
            )),
      ),
    );
  }

  ///登录按钮
  Widget _loginBtn() {
    return Padding(
      padding: EdgeInsets.only(top: 16.w),
      child: Obx(
        () => CustomButton(
          title: '登录',
          textColor: canSubmit.value
              ? AppConfig.textMainColor
              : const Color(0xff6e7793),
          bgColor:
              canSubmit.value ? AppConfig.mainColor : const Color(0xfff1f1f1),
          onTap: () {
            if (canSubmit.value) {
              loginRequest();
            }
          },
        ),
      ),
    );
  }

  Widget _forgetAndRegist() {
    return Padding(
      padding: EdgeInsets.only(top: 18.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(ForgetPassword(
                isReset: false,
              ));
            },
            child: Text(
              '忘记密码',
              style: TextStyle(
                fontSize: 26.sp,
                color: AppConfig.textSecondColor,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.to(const Register());
            },
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '还没有账号，',
                    style: TextStyle(
                      color: AppConfig.textSecondColor,
                      fontSize: 26.sp,
                    ),
                  ),
                  TextSpan(
                    text: '立即注册',
                    style: TextStyle(
                      color: AppConfig.mainColor,
                      fontSize: 26.sp,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  ///微信登录按钮
  Widget _wechatLoginWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 80.w),
      child: InkWell(
        onTap: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/login_wechat.png',
              width: 68.w,
            ),
            SizedBox(width: 28.w),
            Text(
              '微信登录',
              style: TextStyle(
                fontSize: 30.sp,
                color: AppConfig.textMainColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _xieyiClick() async {
    xieyiSelect = !xieyiSelect;
    _inputChangeAction();
    xieyiState(() {});
  }

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
        'type': 2,
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
    if (xieyiSelect && phoneCon.text.isNotEmpty) {
      if ((tabIndex == 0 && codeCon.text.isNotEmpty) ||
          tabIndex == 1 && passwordCon.text.isNotEmpty) {
        canSubmit.value = true;
      } else {
        canSubmit.value = false;
      }
    } else {
      canSubmit.value = false;
    }
  }

  loginRequest() {
    String path = '';
    Map<String, dynamic> map = {'phone': phoneCon.text};
    if (tabIndex == 1) {
      path = 'member/accountLogin';
      map.addAll({'password': passwordCon.text});
    } else {
      path = 'member/login';
      map.addAll({'code': codeCon.text});
    }
    ServiceRequest.post(
      path,
      data: map,
      success: (res) async {
        bool? loginSuccess =
            await CommonAPI.authCodeLogin(res['data']['authcode']);
        if (loginSuccess != null && loginSuccess) {
          getBox.write('token', res['data']['token']);
          getBox.write('authcode', res['data']['authcode']);
          getBox.write('user_type', res['data']['user_type']);
          getBox.write('have_space', res['data']['space_num']);
          NavKey.navKey.currentState!.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const NavigationPage(),
              ),
              (route) => route == null);
        } else {
          print('object');
        }
      },
      error: (errer) {},
    );
  }
}
