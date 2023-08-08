import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:light_project/widget/custom_dialog.dart';
import 'package:light_project/widget/custom_label.dart';
import 'package:permission_handler/permission_handler.dart';

/// 申请定位权限
/// 授予定位权限返回true， 否则返回false
Future<bool> requestLocationPermission() async {
  print('正在获取当前权限状态..');
  //获取当前的权限
  var status = await Permission.location.status;
  print('↓↓↓权限状态↓↓↓');
  print(status);
  if (status == PermissionStatus.granted) {
    //已经授权

    return true;
  } else {
    //未授权则发起一次申请
    status = await Permission.location.request();

    if (status == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }
}

Future<bool> requestPermission(Permission permission) async {
  print('正在获取当前权限状态..');
  //获取当前的权限
  var status = await permission.status;
  print('↓↓↓权限状态↓↓↓');
  print(status);
  if (status == PermissionStatus.granted) {
    //已经授权

    return true;
  } else {
    //未授权则发起一次申请
    print('重新请求定位');
    status = await permission.request();
    print('↓↓↓重新请求权限状态↓↓↓');
    print(status);
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }
}

///上传图片接口
upLoadFile({
  required String filePath,
  required Function(String imgUrl, String fullImgUrl) callback,
}) async {
  List<int> imgData = File(filePath).readAsBytesSync();
  var img =
      dio.MultipartFile.fromBytes(imgData, filename: filePath.split('/').last);

  ServiceRequest.upload(
    'common/upload',
    data: {
      'file': img,
    },
    success: (res) {
      callback(res['data']['url'], res['data']['fullurl']);
    },
    error: (error) {},
  );
}

///根据space_type_id 获取  类型名称
String getSpaceNameWithType(int type) {
  switch (type) {
    case 1:
      return '园区';
    case 2:
      return '楼宇';
    case 3:
      return '园区公共区域';
    case 4:
      return '楼层';
    case 5:
      return '楼层公共区域';
    case 6:
      return '公司/房间';
    default:
      return '';
  }
}

///底部安全区域高度
double paddingSizeBottom(BuildContext context) {
  final MediaQueryData data = MediaQuery.of(context);
  EdgeInsets padding = data.padding;
  padding = padding.copyWith(bottom: data.viewPadding.bottom);
  return padding.bottom;
}

///顶部安全区域高度
double paddingSizeTop(BuildContext context) {
  final MediaQueryData data = MediaQuery.of(context);
  EdgeInsets padding = data.padding;
  padding = padding.copyWith(bottom: data.viewPadding.top);
  return padding.top;
}

showParentNameEditDialog(
  context, {
  required String name,
  required ValueChanged onTap,
}) {
  TextEditingController parentNameCon = TextEditingController(text: name);
  CustomDialog.showCustomDialog(
    context,
    child: Container(
      width: 600.w,
      height: 551.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.w),
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(horizontal: 37.w, vertical: 43.w),
      child: Column(
        children: [
          Text(
            '编辑名称',
            style: TextStyle(
              fontSize: 30.sp,
              color: AppConfig.textMainColor,
            ),
          ),
          Expanded(
            child: Center(
              child: CustomLabel(
                label: '',
                input: '',
                height: 100.w,
                hasBottomLine: true,
                rightWidget: Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          autofocus: true,
                          style: TextStyle(
                            fontSize: 28.sp,
                            color: AppConfig.textMainColor,
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            counterText: '',
                            border: InputBorder.none,
                            hintText: '请输入名称',
                            hintStyle: TextStyle(
                              fontSize: 28.sp,
                              color: AppConfig.textSecondColor,
                            ),
                          ),
                          controller: parentNameCon,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          CustomButton(
            title: '确认修改',
            height: 80.w,
            width: 500.w,
            onTap: () {
              onTap(parentNameCon.text);
            },
          ),
          SizedBox(
            height: 36.w,
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text(
              '取消',
              style: TextStyle(
                fontSize: 26.sp,
                color: AppConfig.textSecondColor,
              ),
            ),
          )
        ],
      ),
    ),
  );
}
