import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/mine/feedback_add.dart';
import 'package:light_project/mine/feedback_detail.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:light_project/widget/custom_refresh.dart';

class FeedbackList extends StatefulWidget {
  const FeedbackList({Key? key}) : super(key: key);

  @override
  State<FeedbackList> createState() => _FeedbackListState();
}

class _FeedbackListState extends State<FeedbackList> {
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
      'member/feedbackList',
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
        title: '意见反馈',
      ),
      body: _listContainer(),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
            child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 32.w),
          child: CustomButton(
            height: 90.w,
            onTap: () {
              Get.to(FeedbackAdd())!.then((res) {
                if (res != null) {
                  page = 1;
                  getRequest();
                }
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/mine_feedback.png',
                  width: 60.w,
                ),
                SizedBox(
                  width: 8.w,
                ),
                Text(
                  '意见反馈',
                  style: TextStyle(
                    fontSize: 30.sp,
                    color: AppConfig.textMainColor,
                  ),
                ),
              ],
            ),
          ),
        )),
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
                    Get.to(FeedbackDetail(id: itemList[index]['id']));
                  },
                  child: SizedBox(
                    height: 120.w,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            itemList[index]['content'],
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
              itemCount: itemList.length),
        ));
  }
}
