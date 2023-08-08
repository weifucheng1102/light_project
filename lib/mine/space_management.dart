import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/config/get_box.dart';
import 'package:light_project/mine/space_management_add.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/util/common.dart';
import 'package:light_project/util/event.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:light_project/widget/custom_label.dart';
import 'package:oktoast/oktoast.dart';

class SpaceManagement extends StatefulWidget {
  const SpaceManagement({Key? key}) : super(key: key);

  @override
  State<SpaceManagement> createState() => _SpaceManagementState();
}

class _SpaceManagementState extends State<SpaceManagement> {
  ///物业管理员 类型 可用
  int adminCreatType = 1;

  TextEditingController nameCon = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgColor,
      appBar: MyAppBar(
        title: '空间管理',
      ),
      body: ListView(
        padding: EdgeInsets.all(30.w),
        children: itemList(),
      ),
    );
  }

  List<Widget> itemList() {
    return [
      Text(
        '请创建您需要管理的空间',
        style: TextStyle(
          fontSize: 30.sp,
          fontWeight: FontWeight.bold,
          color: AppConfig.textMainColor,
        ),
      ),
      SizedBox(
        height: 30.w,
      ),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.w),
          color: Colors.white,
        ),
        padding: EdgeInsets.only(top: 40.w, bottom: 86.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                '选择空间类型',
                style: TextStyle(
                  fontSize: 28.sp,
                  color: AppConfig.textMainColor,
                ),
              ),
            ),
            _spaceItems(),
            _nameTextField(),
            Padding(
              padding: EdgeInsets.only(
                  left: 24.w, right: 24.w, top: 25.w, bottom: 98.w),
              child: Text(
                '注：如需创建更多空间类型，请联系绿大科技获取授权。',
                style: TextStyle(
                  fontSize: 24.sp,
                  color: AppConfig.textSecondColor,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  title: '确定创建',
                  width: 585.w,
                  height: 90.w,
                  onTap: () => _submitRequest(),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  Widget _spaceItems() {
    return Container(
      height: 200.w,
      margin: EdgeInsets.only(top: 30.w),
      child: getBox.read('user_type') == 1
          ? Padding(
              padding: EdgeInsets.only(left: 24.w),
              child: Image.asset('images/space_manage_6.png'),
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (adminCreatType != index + 1) {
                      adminCreatType = index + 1;
                      nameCon.text = '';
                      setState(() {});
                    }
                  },
                  child: SizedBox(
                    width: 180.w,
                    child: Image.asset(
                      'images/space_manage${adminCreatType - 1 == index ? "" : "_un"}_${index + 1}.png',
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  width: 20.w,
                );
              },
              itemCount: 6,
            ),
    );
  }

  Widget _nameTextField() {
    return Padding(
      padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 70.w),
      child: CustomLabel(
        label: '',
        input: '',
        height: 90.w,
        hasBottomLine: true,
        rightWidget: Expanded(
          child: TextField(
            style: TextStyle(
              fontSize: 28.sp,
              color: AppConfig.textMainColor,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              counterText: '',
              border: InputBorder.none,
              hintText: '请输入${_getNameWithSelect()}名称',
              hintStyle: TextStyle(
                fontSize: 28.sp,
                color: AppConfig.textSecondColor,
              ),
            ),
            controller: nameCon,
          ),
        ),
      ),
    );
  }

  String _getNameWithSelect() {
    ///普通用户只能创建 公司/房间
    if (getBox.read('user_type') == 1) {
      return '公司/房间名称';
    }
    return getSpaceNameWithType(adminCreatType);
  }

  String _getRequestUrlWithSelect() {
    ///普通用户只能创建 公司/房间
    if (getBox.read('user_type') == 1) {
      return 'property/createSpace';
    }
    switch (adminCreatType) {
      case 1:
        return 'property/createPark';
      case 2:
        return 'property/createBuild';
      case 3:
        return 'property/createParkArea';
      case 4:
        return 'property/createFloor';
      case 5:
        return 'property/createSpace';
      case 6:
        return 'property/createSpace';
      default:
        return '';
    }
  }

  _submitRequest() {
    if (nameCon.text.isEmpty) {
      showToast('请输入名称');
      return;
    }
    Map<String, dynamic> map = {
      'title': nameCon.text,
    };
    if (getBox.read('user_type') == 1) {
      ///普通用户只能添加6（房间）
      map.addAll({'space_type': 6});
    } else {
      if (adminCreatType == 5 || adminCreatType == 6) {
        map.addAll({'space_type': adminCreatType});
      }
    }

    ServiceRequest.post(
      _getRequestUrlWithSelect(),
      data: map,
      success: (res) {
        bus.emit('updateUserInfo');
        EasyLoading.showSuccess('创建成功', duration: Duration(milliseconds: 500));
        Future.delayed(Duration(milliseconds: 500), () {
          ///普通用户直接返回， 物业管理员 创建type=3或者 type=5或者6 直接返回， else:    跳到下一页继续创建子控件
          if (getBox.read('user_type') == 1 ||
              adminCreatType == 3 ||
              adminCreatType == 5 ||
              adminCreatType == 6) {
            Get.back();
          } else {
            Get.offUntil(
                GetPageRoute(page: () => SpaceManagementAdd(data: res['data'])),
                (route) {
              if (route.runtimeType.toString() ==
                  'MaterialPageRoute<dynamic>') {
                return true;
              } else {
                return false;
              }
            });
          }
        });
      },
      error: (error) {},
    );
  }
}
