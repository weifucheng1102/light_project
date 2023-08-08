import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:light_project/widget/custom_dialog.dart';
import 'package:oktoast/oktoast.dart';

import '../service/service_request.dart';
import '../util/common.dart';
import '../util/event.dart';
import '../widget/custom_label.dart';

class SpaceManagementAdd extends StatefulWidget {
  final Map? data;
  const SpaceManagementAdd({Key? key, required this.data}) : super(key: key);

  @override
  State<SpaceManagementAdd> createState() => _SpaceManagementAddState();
}

class _SpaceManagementAddState extends State<SpaceManagementAdd> {
  TextEditingController nameCon = TextEditingController(text: '');
  String parentName = '';
  int? select_type_id;

  List showSelectItemIDs = [];

  ///获取可以创建的空间
  getShowItems() {
    switch (widget.data!['space_type_id']) {
      //园区 下一级 显示 楼宇和园区公共区域
      case 1:
        showSelectItemIDs = [2, 3];

        break;
      //楼宇下一级 显示楼层
      case 2:
        showSelectItemIDs = [4];
        break;
      //楼层 下一级 显示楼层公共区域 和 公司
      case 4:
        showSelectItemIDs = [5, 6];
        break;
      default:
        [];
    }
  }

  @override
  void initState() {
    super.initState();
    parentName = widget.data!['title'];
    getShowItems();
    select_type_id = showSelectItemIDs.first;
    setState(() {});
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
      _parentSpaceInfo(),
      SizedBox(
        height: 22.w,
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
                '您还可以继续添加',
                style: TextStyle(
                  fontSize: 28.sp,
                  color: AppConfig.textMainColor,
                ),
              ),
            ),
            _spaceItems(),
            _nameTextField(),
            SizedBox(
              height: 102.w,
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

  Widget _parentSpaceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'images/space_add_${widget.data!['space_type_id']}.png',
                  width: 42.w,
                ),
                SizedBox(
                  width: 10.w,
                ),
                Text(
                  parentName,
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                    color: AppConfig.textMainColor,
                  ),
                )
              ],
            ),
            InkWell(
              onTap: () {
                showParentNameEditDialog(
                  context,
                  name: parentName,
                  onTap: (res) {
                    _editNameRequest(res);
                  },
                );
              },
              child: Row(
                children: [
                  Text(
                    '编辑',
                    style: TextStyle(
                      fontSize: 26.sp,
                      color: AppConfig.textSecondColor,
                    ),
                  ),
                  Image.asset(
                    'images/space_edit.png',
                    width: 36.w,
                  ),
                ],
              ),
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 52.w, top: 2.w),
          child: Text(
            getSpaceNameWithType(widget.data!['space_type_id']),
            style: TextStyle(
              fontSize: 26.sp,
              color: AppConfig.textSecondColor,
            ),
          ),
        )
      ],
    );
  }

  Widget _spaceItems() {
    return Container(
      height: 200.w,
      margin: EdgeInsets.only(top: 30.w),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              select_type_id = showSelectItemIDs[index];
              setState(() {});
            },
            child: SizedBox(
              width: 180.w,
              child: Image.asset(
                'images/space_manage${select_type_id == showSelectItemIDs[index] ? "" : "_un"}_${showSelectItemIDs[index]}.png',
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            width: 20.w,
          );
        },
        itemCount: showSelectItemIDs.length,
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
              hintText: '请输入${getSpaceNameWithType(select_type_id!)}名称',
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

  String _getRequestUrlWithSelect() {
    switch (select_type_id) {
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

    if (select_type_id == 5 || select_type_id == 6) {
      map.addAll({
        'space_type': select_type_id,
        'floor_id': widget.data!['id'],
      });
    }
    if (select_type_id == 2 || select_type_id == 3) {
      map.addAll({'park_id': widget.data!['id']});
    }
    if (select_type_id == 4) {
      map.addAll({'build_id': widget.data!['id']});
    }

    ServiceRequest.post(
      _getRequestUrlWithSelect(),
      data: map,
      success: (res) {
        EasyLoading.showSuccess('创建成功', duration: Duration(milliseconds: 500));
        Future.delayed(Duration(milliseconds: 500), () {
          ///普通用户直接返回， 物业管理员 创建type=3或者 type=5或者6 直接返回， else:    跳到下一页继续创建子控件
          if (select_type_id == 3 ||
              select_type_id == 5 ||
              select_type_id == 6) {
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

  _editNameRequest(name) {
    if (name.isEmpty) {
      showToast('请输入名称');
      return;
    }
    ServiceRequest.post(
      'property/editSpace',
      data: {'id': widget.data!['id'], 'title': name},
      success: (res) {
        EasyLoading.showSuccess('修改成功', duration: Duration(milliseconds: 500));
        Future.delayed(Duration(milliseconds: 500), () {
          parentName = name;
          Navigator.pop(context);
          setState(() {});
        });
      },
      error: (res) {},
    );
  }
}
