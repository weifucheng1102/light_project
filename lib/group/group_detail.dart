import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:light_project/widget/custom_label.dart';

class GroupDetail extends StatefulWidget {
  final int id;
  const GroupDetail({Key? key, required this.id}) : super(key: key);

  @override
  State<GroupDetail> createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {
  Map? data;
  @override
  void initState() {
    super.initState();
    getRequest();
  }

  getRequest() {
    ServiceRequest.post(
      'property/groupMemberDetail',
      data: {'id': widget.id},
      success: (res) {
        data = res['data'];
        setState(() {});
      },
      error: (error) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgColor,
      appBar: MyAppBar(
        title: '详情',
      ),
      body: data == null
          ? SizedBox()
          : ListView(
              padding: EdgeInsets.all(30.w),
              children: [
                _userInfoWidget(),
                SizedBox(
                  height: 20.w,
                ),
                _areaInfoWidget(),
              ],
            ),
      bottomNavigationBar: data == null || data!['type'] != 2
          ? SizedBox()
          : Container(
              margin: EdgeInsets.only(bottom: 200.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    title: '删除',
                    width: 585.w,
                    height: 90.w,
                    onTap: () => _delRquest(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _userInfoWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
      ),
      padding: EdgeInsets.all(25.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: Image.network(
              data!['avatar'],
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
                data!['nickname'],
                style: TextStyle(
                  fontSize: 28.sp,
                  color: AppConfig.textMainColor,
                ),
              ),
              Text(
                data!['space_title'],
                style: TextStyle(
                  fontSize: 26.sp,
                  color: AppConfig.textSecondColor,
                ),
              ),
              Text(
                data!['mobile'],
                style: TextStyle(
                  fontSize: 26.sp,
                  color: AppConfig.textSecondColor,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _areaInfoWidget() {
    List<Widget> list = [];
    if (data!['park_title'] != null) {
      list.add(_titleInfo('园区', data!['park_title']));
    }
    if (data!['build_title'] != null) {
      list.add(_titleInfo('楼宇', data!['build_title']));
    }
    if (data!['area_title'] != null) {
      list.add(_titleInfo('园区公共区域', data!['area_title']));
    }

    if (data!['floor_title'] != null) {
      list.add(_titleInfo('楼层', data!['floor_title']));
    }
    if (data!['room_title'] != null) {
      list.add(_titleInfo('房间/公共区域', data!['room_title']));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
      ),
      padding: EdgeInsets.all(25.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '位置信息',
            style: TextStyle(
              fontSize: 28.sp,
              color: AppConfig.textMainColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 18.w,
          ),
          Column(
            children: list,
          ),
        ],
      ),
    );
  }

  Widget _titleInfo(title, desc) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 26.sp,
              color: AppConfig.textSecondColor,
            ),
          ),
          Text(
            desc,
            style: TextStyle(
              fontSize: 26.sp,
              color: AppConfig.textSecondColor,
            ),
          )
        ],
      ),
    );
  }

  _delRquest() {
    ServiceRequest.post(
      'Property/delGroup',
      data: {
        'id': widget.id,
      },
      success: (res) {
        EasyLoading.showSuccess('删除成功', duration: Duration(seconds: 1));
        Future.delayed(Duration(seconds: 1), () {
          Get.back(result: true);
        });
      },
      error: (error) {},
    );
  }
}
