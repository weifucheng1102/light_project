import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/mine/image_gridview.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/util/common.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:light_project/widget/custom_image_picker.dart';
import 'package:light_project/widget/custom_label.dart';

import '../util/precision_limit_formatter.dart';

class ControlCustomAdd extends StatefulWidget {
  const ControlCustomAdd({Key? key}) : super(key: key);

  @override
  State<ControlCustomAdd> createState() => _ControlCustomAddState();
}

class _ControlCustomAddState extends State<ControlCustomAdd> {
  TextEditingController nameCon = TextEditingController(text: '');
  TextEditingController lightCon = TextEditingController(text: '');
  TextEditingController cTempCon = TextEditingController(text: '');

  List imageList = [];
  List uploadList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgColor,
      appBar: MyAppBar(
        title: '自定义场景库',
      ),
      body: ListView(
        padding: EdgeInsets.all(30.w),
        children: [
          Container(
            padding: EdgeInsets.only(left: 25.w, right: 25.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.w),
              color: Colors.white,
            ),
            child: Column(
              children: [
                CustomLabel(
                  height: 120.w,
                  label: '场景名称',
                  input: '',
                  tip: '请输入场景名称',
                  textCon: nameCon,
                  hasBottomLine: true,
                ),
                CustomLabel(
                  height: 120.w,
                  label: '照度',
                  input: '',
                  tip: '请输入场景照度参数',
                  textCon: lightCon,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter(RegExp("[0-9]|."), allow: true),
                    CustomTextFieldFormatter(digit: 2),
                  ],
                  hasBottomLine: true,
                ),
                CustomLabel(
                  height: 120.w,
                  label: '色温',
                  input: '',
                  tip: '请输入场景色温参数',
                  textCon: cTempCon,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter(RegExp("[0-9]|."), allow: true),
                    CustomTextFieldFormatter(digit: 2),
                  ],
                  hasBottomLine: true,
                ),
                ImageGridView(
                  isEdit: true,
                  imageList: imageList,
                  crossAxisCount: 4,
                  maxImageLength: 1,
                  delectCallBack: (index) {
                    imageList.removeAt(index);
                    uploadList.removeAt(index);
                    setState(() {});
                  },
                  addCallBack: () {
                    CustomImagePicker.pickImage(context, isMulty: false,
                        pickerCallback: (res) {
                      res.forEach((element) async {
                        upLoadFile(
                            filePath: element.path,
                            callback: (url, fullUrl) {
                              imageList.add(fullUrl);
                              uploadList.add(url);
                              setState(() {});
                            });
                      });
                    });
                  },
                ),
                SizedBox(
                  height: 40.w,
                ),
                CustomButton(
                  title: '确认修改',
                  height: 90.w,
                  onTap: () {
                    addRequest();
                  },
                ),
                SizedBox(
                  height: 76.w,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  addRequest() {
    if (nameCon.text.isEmpty ||
        lightCon.text.isEmpty ||
        cTempCon.text.isEmpty ||
        uploadList.isEmpty) {
      EasyLoading.showError('信息不完整');
      return;
    }
    ServiceRequest.post(
      'scene/chooseScene',
      data: {
        'type': 2,
        'title': nameCon.text,
        'light': lightCon.text,
        'c_temp': cTempCon.text,
        'image': uploadList.first,
      },
      success: (res) {
        EasyLoading.showSuccess('添加成功', duration: Duration(seconds: 1));
        Future.delayed(Duration(seconds: 1), () {
          Get.back(result: true);
          Get.back(result: true);
        });
      },
      error: (error) {},
    );
  }
}
