import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/mine/article_detail.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:light_project/widget/custom_refresh.dart';

import '../service/service_request.dart';

class HelpCenter extends StatefulWidget {
  const HelpCenter({Key? key}) : super(key: key);

  @override
  State<HelpCenter> createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {
  int page = 1;
  bool hasMore = true;
  List itemList = [];
  @override
  void initState() {
    super.initState();
    getRequest();
  }

  getRequest() {
    ServiceRequest.post(
      'homepage/helpList',
      data: {
        'page': page,
      },
      success: (res) {
        hasMore = res['data']['next_page'];
        itemList =
            page == 1 ? res['data']['list'] : itemList + res['data']['list'];
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
        title: '帮助中心',
      ),
      body: SafeArea(
        child: _listContainer(),
      ),
    );
  }

  Widget _listContainer() {
    return Container(
      margin: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.w),
        color: Colors.white,
      ),
      child: CustomRefresh(
        onRefresh: () async {
          page = 1;
          getRequest();
        },
        onLoad: !hasMore
            ? null
            : () async {
                page++;
                getRequest();
              },
        count: itemList.length,
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Get.to(ArticleDetail(
                  type: 4,
                  id: itemList[index]['id'],
                ));
              },
              child: SizedBox(
                height: 120.w,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        itemList[index]['title'],
                        style: TextStyle(
                          fontSize: 28.sp,
                          color: AppConfig.textMainColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    Image.asset(
                      'images/grey_right.png',
                      width: 14.w,
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return Divider(height: 1.w, color: AppConfig.lineColor);
          },
          itemCount: itemList.length,
        ),
      ),
    );
  }
}
