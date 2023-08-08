import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/mine/image_gridview.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/widget/custom_appbar.dart';

class FeedbackDetail extends StatefulWidget {
  final int id;
  const FeedbackDetail({Key? key, required this.id}) : super(key: key);

  @override
  State<FeedbackDetail> createState() => _FeedbackDetailState();
}

class _FeedbackDetailState extends State<FeedbackDetail> {
  Map? data;
  @override
  void initState() {
    super.initState();
    getRequest();
  }

  getRequest() {
    ServiceRequest.get(
      'member/feedbackDetail',
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
          : ListView.separated(
              padding: EdgeInsets.all(30.w),
              itemBuilder: (context, index) {
                return itemList()[index];
              },
              separatorBuilder: (context, index) {
                return SizedBox(height: 20.w);
              },
              itemCount: itemList().length),
    );
  }

  List<Widget> itemList() {
    List<Widget> li = [
      _whiteBg(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data!['content'],
            style: TextStyle(
              fontSize: 28.sp,
              color: AppConfig.textMainColor,
            ),
          ),
          ImageGridView(
              isEdit: false, imageList: data!['images'], crossAxisCount: 4),
        ],
      ))
    ];
    if (data!['reply'] != null && data!['reply'].length != 0) {
      li.add(_whiteBg(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '平台回复',
            style: TextStyle(
              fontSize: 26.sp,
              color: const Color(0xff666666),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 15.w),
            padding: EdgeInsets.all(25.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.w),
              color: AppConfig.bgColor,
            ),
            alignment: Alignment.topLeft,
            child: Text(
              data!['reply'],
              style: TextStyle(
                fontSize: 26.sp,
                color: const Color(0xff666666),
              ),
            ),
          ),
        ],
      )));
    }
    return li;
  }

  Widget _whiteBg({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(25.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
      ),
      child: child,
    );
  }
}
