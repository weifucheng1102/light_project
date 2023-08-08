import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/login/register.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:light_project/widget/custom_label.dart';

import '../login/forget_password.dart';

class SafeManagement extends StatefulWidget {
  const SafeManagement({Key? key}) : super(key: key);

  @override
  State<SafeManagement> createState() => _SafeManagementState();
}

class _SafeManagementState extends State<SafeManagement> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgColor,
      appBar: MyAppBar(
        title: '安全管理',
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(30.w),
        itemBuilder: (ctx, index) {
          return [
            _bgWidget(CustomLabel(
              label: '微信',
              input: '',
              rightWidget: CustomButton(
                title: '去绑定',
                width: 142.w,
                height: 72.w,
                font: 28.sp,
              ),
            )),
            _bgWidget(
              CustomLabel(
                label: '修改密码',
                input: '修改登录密码',
                hasRight: true,
                callback: () {
                  Get.to(const ForgetPassword(
                    isReset: true,
                  ));
                },
              ),
            ),
          ][index];
        },
        separatorBuilder: (ctx, index) {
          return SizedBox(
            height: 20.w,
          );
        },
        itemCount: 2,
      ),
    );
  }

  Widget _bgWidget(Widget child) {
    return Container(
      height: 120.w,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.w),
        color: Colors.white,
      ),
      child: child,
    );
  }
}
