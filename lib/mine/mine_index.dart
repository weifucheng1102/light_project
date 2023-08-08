import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/config/application.dart';
import 'package:light_project/config/nav_key.dart';
import 'package:light_project/login/login.dart';
import 'package:light_project/mine/feedback_list.dart';
import 'package:light_project/mine/help_center.dart';
import 'package:light_project/mine/safe_management.dart';
import 'package:light_project/mine/setting.dart';
import 'package:light_project/mine/space_management.dart';
import 'package:light_project/mine/user_info_edit.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/util/event.dart';
import 'package:light_project/widget/custom_label.dart';
import 'package:light_project/widget/custom_refresh.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/get_box.dart';
import '../widget/custom_appbar.dart';
import 'article_detail.dart';

class MineIndex extends StatefulWidget {
  const MineIndex({Key? key}) : super(key: key);

  @override
  State<MineIndex> createState() => _MineIndexState();
}

class _MineIndexState extends State<MineIndex> {
  String appversion = '';
  Map? userInfo;
  @override
  void dispose() {
    super.dispose();
    bus.off('updateUserInfo');
  }

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    getUserInfo();
    bus.on('updateUserInfo', (arg) {
      getUserInfo();
    });
  }

  getUserInfo() {
    ServiceRequest.post(
      'member/memberInfo',
      data: {},
      showProgress: false,
      success: (res) {
        if (mounted) {
          userInfo = res['data'];
          bool have_space = res['data']['space_num'];
          getBox.write('user_type', res['data']['user_type']);

          ///修改底部tabbar 数量
          if (getBox.read('have_space') != have_space) {
            getBox.write('have_space', have_space);
            if (have_space) {
              appl!.tabbarChanged!(3);
            } else {
              appl!.tabbarChanged!(1);
            }
          }

          setState(() {});
        }
      },
      error: (error) {},
    );
  }

  _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appversion = '版本${packageInfo.version}';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgColor,
      appBar: MyAppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
            alignment: Alignment.bottomCenter,
            image: AssetImage('images/mine_bg_1.png'),
            fit: BoxFit.fitWidth,
          )),
        ),
        backIconShow: false,
      ),
      body: CustomRefresh(
        count: 1,
        onRefresh: () async {
          getUserInfo();
        },
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return _imageBg();
          },
          itemCount: 1,
        ),
      ),
    );
  }

  Widget _imageBg() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      decoration: const BoxDecoration(
        image: DecorationImage(
          alignment: Alignment.topCenter,
          image: AssetImage(
            'images/mine_bg_2.png',
          ),
          fit: BoxFit.fitWidth,
        ),
      ),
      child: Column(
        children: [
          _userInfoWidget(),
          SizedBox(
            height: 32.w,
          ),
          _menuList(),
        ],
      ),
    );
  }

  Widget _userInfoWidget() {
    return userInfo == null
        ? SizedBox()
        : InkWell(
            onTap: () {
              Get.to(UserInfoEdit(
                data: userInfo,
              ))!
                  .then((res) {
                if (res != null) {
                  getUserInfo();
                }
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: Image.network(
                        userInfo!['avatar'],
                        width: 120.w,
                        height: 120.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 22.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userInfo!['nickname'],
                          style: TextStyle(
                            fontSize: 36.sp,
                            color: AppConfig.textMainColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.w),
                        Text(
                          userInfo!['mobile'],
                          style: TextStyle(
                            fontSize: 26.sp,
                            color: const Color(0xff666666),
                          ),
                        ),
                        SizedBox(height: 4.w),
                        Row(
                          children: [
                            Text(
                              'ID:${userInfo!['id_number']}',
                              style: TextStyle(
                                fontSize: 26.sp,
                                color: const Color(0xff666666),
                              ),
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            Image.asset(
                              'images/mine_qr.png',
                              width: 38.w,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: Image.asset(
                    'images/grey_right.png',
                    width: 14.w,
                  ),
                ),
              ],
            ),
          );
  }

  Widget _menuList() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.w),
        color: Colors.white,
      ),
      padding: EdgeInsets.only(left: 25.w, right: 25.w, top: 34.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '常用功能',
            style: TextStyle(
              fontSize: 30.sp,
              color: AppConfig.textMainColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10.w,
          ),
          CustomLabel(
            image: Image.asset(
              'images/mine_menu_1.png',
              width: 36.w,
            ),
            label: '空间管理',
            input: '',
            hasRight: true,
            callback: () {
              Get.to(const SpaceManagement());
            },
          ),
          CustomLabel(
            image: Image.asset(
              'images/mine_menu_2.png',
              width: 36.w,
            ),
            label: '安全管理',
            input: '',
            hasRight: true,
            callback: () {
              Get.to(SafeManagement());
            },
          ),
          CustomLabel(
            image: Image.asset(
              'images/mine_menu_3.png',
              width: 36.w,
            ),
            label: '设置',
            input: '',
            hasRight: true,
            callback: () {
              Get.to(Setting());
            },
          ),
          CustomLabel(
            image: Image.asset(
              'images/mine_menu_4.png',
              width: 36.w,
            ),
            label: '意见反馈',
            input: '',
            hasRight: true,
            callback: () {
              Get.to(FeedbackList());
            },
          ),
          CustomLabel(
            image: Image.asset(
              'images/mine_menu_5.png',
              width: 36.w,
            ),
            label: '用户协议',
            input: '',
            hasRight: true,
            callback: () {
              Get.to(ArticleDetail(
                type: 1,
              ));
            },
          ),
          CustomLabel(
            image: Image.asset(
              'images/mine_menu_6.png',
              width: 36.w,
            ),
            label: '帮助中心',
            input: '',
            hasRight: true,
            callback: () {
              Get.to(HelpCenter());
            },
          ),
          CustomLabel(
            image: Image.asset(
              'images/mine_menu_7.png',
              width: 36.w,
            ),
            label: '版本信息',
            input: appversion,
            callback: () {
              //CommonAPI.requestApi("/uc/listBindingByAccount", "1.0.2");
            },
            inputStyle: TextStyle(
              fontSize: 26.sp,
              color: AppConfig.textMainColor,
            ),
          ),
          CustomLabel(
            image: Image.asset(
              'images/mine_menu_8.png',
              width: 36.w,
            ),
            label: '退出登录',
            input: '',
            callback: () {
              getBox.remove('token');
              NavKey.navKey.currentState!.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const Login(),
                  ),
                  (route) => route == null);
            },
          ),
        ],
      ),
    );
  }
}
