import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/widget/custom_appbar.dart';

import '../service/service_request.dart';

class ArticleDetail extends StatefulWidget {
  final int? id;

  ///1=用户协议,2=注册协议,3=关于我们,4=帮助中心
  final int type;
  const ArticleDetail({
    Key? key,
    required this.type,
    this.id,
  }) : super(key: key);

  @override
  State<ArticleDetail> createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<ArticleDetail> {
  Map? htmlMap;

  @override
  void initState() {
    super.initState();
    httpRequest();
  }

  httpRequest() {
    ServiceRequest.post(
      'homepage/articleDetail',
      data: {
        'id': widget.id ?? '',
        'type': widget.type,
      },
      success: (res) {
        htmlMap = res['data'];
        if (mounted) {
          setState(() {});
        }
      },
      error: (error) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgColor,
      appBar: MyAppBar(
        title: htmlMap == null ? '' : htmlMap!['title'],
      ),
      body: htmlMap == null
          ? const SizedBox()
          : SafeArea(
              child: Container(
                margin: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.w),
                  color: Colors.white,
                ),
                child: ListView(
                  padding: EdgeInsets.all(20.w),
                  shrinkWrap: true,
                  children: [
                    HtmlWidget(htmlMap!['content']),
                  ],
                ),
              ),
            ),
    );
  }
}
