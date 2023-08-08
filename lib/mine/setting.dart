import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/mine/article_detail.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_label.dart';
import 'package:path_provider/path_provider.dart';

import '../util/cache_utils.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  double _cache = 0;
  @override
  void initState() {
    super.initState();
    getSize();
  }

  getSize() async {
    final tempDir = await getTemporaryDirectory();
    _cache = await CacheUtils.getTotalSizeOfFilesInDir(tempDir);
    print(CacheUtils.renderSize(_cache));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgColor,
      appBar: MyAppBar(
        title: '设置',
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(30.w),
        itemBuilder: (ctx, index) {
          return [
            _bgWidget(CustomLabel(
              label: '清除缓存',
              input: '点击清除APP内的缓存',
              hasRight: true,
              callback: () async {
                try {
                  EasyLoading.show();
                  final tempDir = await getTemporaryDirectory();
                  await CacheUtils.requestPermissionAndClean(tempDir);

                  EasyLoading.showSuccess(_cache == 0
                      ? '清除成功'
                      : '已清除${CacheUtils.renderSize(_cache)}');
                } catch (err) {
                  print(err);

                  EasyLoading.showError('清除失败');
                }
              },
            )),
            _bgWidget(
              CustomLabel(
                label: '关于我们',
                input: '进一步了解我们',
                hasRight: true,
                callback: () {
                  Get.to(ArticleDetail(type: 3));
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
