import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/widget/custom_bottom_sheet.dart';
import 'package:light_project/group/group_detail.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/util/qrscanner_page.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:light_project/widget/custom_dialog.dart';
import 'package:light_project/widget/custom_label.dart';
import 'package:oktoast/oktoast.dart';

class GroupIndex extends StatefulWidget {
  const GroupIndex({Key? key}) : super(key: key);

  @override
  State<GroupIndex> createState() => _GroupIndexState();
}

class _GroupIndexState extends State<GroupIndex> {
  List list = [];

  List ownSpageList = [];

  var dialogState;

  Map? selectSpace;

  TextEditingController numCon = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();

    getRequest();
  }

  getRequest() {
    ServiceRequest.post(
      'property/groupMember',
      data: {},
      showProgress: false,
      success: (res) {
        list = res['data'];
        if (mounted) setState(() {});
      },
      error: (error) {},
    );
  }

  getOwnSpage() {
    ServiceRequest.post(
      'property/manageSpace',
      data: {},
      success: (res) {
        ownSpageList = res['data'];
        _addGroupAdmin();
      },
      error: (error) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgColor,
      appBar: MyAppBar(
        title: '群组',
        backIconShow: false,
        actions: [
          _addButton(),
        ],
      ),
      body: SafeArea(
        child: _groupItemListWidget(),
      ),
    );
  }

  Widget _addButton() {
    return Padding(
        padding: EdgeInsets.only(right: 10.w),
        child: TextButton(
          onPressed: () {
            getOwnSpage();
          },
          child: Row(
            children: [
              Image.asset(
                'images/group_add.png',
                width: 30.w,
              ),
              SizedBox(
                width: 8.w,
              ),
              Text(
                '添加',
                style: TextStyle(
                  fontSize: 26.sp,
                  color: AppConfig.textMainColor,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _groupItemListWidget() {
    return ListView.separated(
      padding: EdgeInsets.all(30.w),
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              list[index]['space_title'],
              style: TextStyle(
                fontSize: 30.sp,
                color: AppConfig.textMainColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            _itemListView(list[index]['space']),
          ],
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 36.w,
        );
      },
      itemCount: list.length,
    );
  }

  Widget _itemListView(List personList) {
    return Container(
      margin: EdgeInsets.only(top: 22.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
      ),
      child: ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return _personItem(personList[index]);
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 1.w,
            color: AppConfig.lineColor,
          );
        },
        itemCount: personList.length,
      ),
    );
  }

  Widget _personItem(item) {
    return InkWell(
      onTap: () {
        Get.to(GroupDetail(id: item['id']))!.then((res) {
          if (res != null) {
            getRequest();
          }
        });
      },
      child: Padding(
        padding: EdgeInsets.all(25.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ClipOval(
                  child: Image.network(
                    item['user_avatar'],
                    width: 88.w,
                    height: 88.w,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: 29.w,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['user_name'],
                      style: TextStyle(
                        fontSize: 28.sp,
                        color: AppConfig.textMainColor,
                      ),
                    ),
                    SizedBox(
                      height: 5.w,
                    ),
                    Text(
                      item['type_title'],
                      style: TextStyle(
                        fontSize: 26.sp,
                        color: AppConfig.textSecondColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Image.asset(
              'images/grey_right.png',
              width: 14.w,
            ),
          ],
        ),
      ),
    );
  }

  _addGroupAdmin() {
    CustomDialog.showCustomDialog(context, child: _addAdminWidget());
  }

  Widget _addAdminWidget() {
    selectSpace = null;
    numCon.text = '';
    return StatefulBuilder(builder: (context, state) {
      dialogState = state;
      return Container(
        width: 600.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.w),
          color: Colors.white,
        ),
        padding: EdgeInsets.symmetric(horizontal: 37.w, vertical: 43.w),
        child: Column(
          children: [
            Text(
              '添加管理人员',
              style: TextStyle(
                fontSize: 30.sp,
                color: AppConfig.textMainColor,
              ),
            ),
            SizedBox(
              height: 50.w,
            ),
            CustomLabel(
              label: '',
              input: '',
              height: 120.w,
              callback: () {
                _showOwnSpaceList();
              },
              hasBottomLine: true,
              rightWidget: Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectSpace == null ? '请选择空间' : selectSpace!['title'],
                      style: TextStyle(
                        fontSize: 28.sp,
                        color: selectSpace == null
                            ? AppConfig.textSecondColor
                            : AppConfig.textMainColor,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xff707070),
                    ),
                  ],
                ),
              ),
            ),
            CustomLabel(
              label: '',
              input: '',
              height: 120.w,
              hasBottomLine: true,
              rightWidget: Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          fontSize: 28.sp,
                          color: AppConfig.textMainColor,
                        ),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          counterText: '',
                          border: InputBorder.none,
                          hintText: '请输入管理人员ID或扫码',
                          hintStyle: TextStyle(
                            fontSize: 28.sp,
                            color: AppConfig.textSecondColor,
                          ),
                        ),
                        controller: numCon,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(QRScannerPage())!.then((res) {
                          if (res != null) {
                            numCon.text = res;
                          }
                        });
                      },
                      child: Image.asset(
                        'images/qr_scan.png',
                        width: 68.w,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 87.w,
            ),
            CustomButton(
              title: '确认添加',
              height: 80.w,
              width: 500.w,
              onTap: () {
                _addAdminRequest();
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
      );
    });
  }

  _showOwnSpaceList() {
    CustomButtomSheet.showText(
      context,
      dataArr: ownSpageList.map((e) => e['title'].toString()).toList(),
      clickCallback: (i, str) {
        selectSpace = ownSpageList[i];
        dialogState(() {});
      },
    );
  }

  _addAdminRequest() {
    if (selectSpace == null || numCon.text.isEmpty) {
      showToast('信息不完整');
      return;
    }
    ServiceRequest.post(
      'property/addGroup',
      data: {
        'space_id': selectSpace!['space_id'],
        'user_number': numCon.text,
      },
      success: (res) {
        EasyLoading.showSuccess('添加成功', duration: Duration(seconds: 1));
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
          getRequest();
        });
      },
      error: (error) {},
    );
  }
}
