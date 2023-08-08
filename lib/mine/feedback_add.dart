import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/mine/image_gridview.dart';
import 'package:light_project/util/common.dart';
import 'package:light_project/widget/custom_image_picker.dart';

import 'package:oktoast/oktoast.dart';

import '../../widget/custom_appbar.dart';
import '../service/service_request.dart';
import '../widget/custom_button.dart';

class FeedbackAdd extends StatefulWidget {
  const FeedbackAdd({Key? key}) : super(key: key);

  @override
  State<FeedbackAdd> createState() => _FeedbackAddState();
}

class _FeedbackAddState extends State<FeedbackAdd> {
  List imageList = [];
  List uploadImageList = [];
  TextEditingController textCon = TextEditingController(text: '');
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgColor,
      appBar: const MyAppBar(
        title: '意见反馈',
      ),
      body: ListView(
        // shrinkWrap: true,
        // physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.all(30.w),
        children: listItems(),
      ),
    );
  }

  List<Widget> listItems() {
    return [
      commentWidget(),
      SizedBox(
        height: 134.w,
      ),
      Column(
        children: [
          CustomButton(
            height: 90.w,
            width: 686.w,
            title: '提交',
            onTap: () {
              submitRequest();
            },
          ),
        ],
      ),
    ];
  }

  commentWidget() {
    return Container(
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
      ),
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(
              minHeight: 400.w,
            ),
            alignment: Alignment.topCenter,
            child: TextField(
              focusNode: focusNode,
              decoration: InputDecoration(
                isCollapsed: true,
                counterText: '',
                border: InputBorder.none,
                hintText: '您的反馈，是我们最大的动力',
                hintMaxLines: 3,
                hintStyle: TextStyle(
                  fontSize: 28.sp,
                  color: AppConfig.textSecondColor,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              controller: textCon,
            ),
          ),
          imageGridView(),
        ],
      ),
    );
  }

  imageGridView() {
    return ImageGridView(
      isEdit: true,
      imageList: imageList,
      crossAxisCount: 4,
      delectCallBack: (index) {
        imageList.removeAt(index);
        uploadImageList.removeAt(index);
        setState(() {});
      },
      addCallBack: () {
        focusNode.unfocus();
        CustomImagePicker.pickImage(context, isMulty: true,
            pickerCallback: (res) {
          res.forEach((element) async {
            upLoadFile(
                filePath: element.path,
                callback: (url, fullUrl) {
                  imageList.add(fullUrl);
                  uploadImageList.add(url);
                  setState(() {});
                });
          });
        });
      },
    );
  }

  submitRequest() {
    if (textCon.text.isEmpty) {
      showToast('请输入反馈信息');
      return;
    }
    if (uploadImageList.isEmpty) {
      showToast('请上传图片');
      return;
    }

    ServiceRequest.post(
      'member/feedbackPost',
      data: {
        'images': uploadImageList.join(','),
        'content': textCon.text,
      },
      success: (res) {
        EasyLoading.showSuccess('提交成功', duration: Duration(seconds: 1));
        Future.delayed(Duration(seconds: 1), () {
          Get.back(result: true);
        });
      },
      error: (error) {},
    );
  }
}
