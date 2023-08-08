import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/util/common.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:light_project/widget/custom_image_picker.dart';
import 'package:light_project/widget/custom_label.dart';

class UserInfoEdit extends StatefulWidget {
  final Map? data;

  const UserInfoEdit({Key? key, required this.data}) : super(key: key);

  @override
  State<UserInfoEdit> createState() => _UserInfoEditState();
}

class _UserInfoEditState extends State<UserInfoEdit> {
  String? imageUrl;
  TextEditingController namecon = TextEditingController(text: '');
  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      imageUrl = widget.data!['avatar'];
      namecon.text = widget.data!['nickname'];

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgColor,
      appBar: MyAppBar(
        title: '个人信息',
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(30.w),
          children: [
            _infoWidget(),
            SizedBox(
              height: 94.w,
            ),
            Column(
              children: [
                CustomButton(
                  height: 90.w,
                  title: '确认修改',
                  onTap: () {
                    updateInfoRequest();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _infoWidget() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.w),
          color: Colors.white,
        ),
        child: ListView(
          padding: EdgeInsets.only(left: 20.w, right: 20.w),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            CustomLabel(
              label: '头像',
              input: '',
              height: 124.w,
              rightWidget: Container(
                width: 88.w,
                height: 88.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(42.w),
                  color: Colors.white,
                  image: imageUrl == null
                      ? null
                      : DecorationImage(
                          image: NetworkImage(
                            imageUrl!,
                          ),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              hasRight: true,
              hasBottomLine: true,
              callback: () {
                CustomImagePicker.pickImage(
                  context,
                  isMulty: false,
                  pickerCallback: (image) async {
                    upLoadFile(
                        filePath: image.first.path,
                        callback: (url, fullUrl) {
                          imageUrl = fullUrl;
                          setState(() {});
                        });
                  },
                );
              },
            ),
            CustomLabel(
              label: '昵称',
              input: '',
              height: 120.w,
              hasBottomLine: true,
              textCon: namecon,
              textfieldStyle: TextStyle(
                fontSize: 28.sp,
                color: AppConfig.textMainColor,
              ),
              tip: '请输入昵称',
              callback: () {},
              hasRight: true,
            ),
            CustomLabel(
              label: '手机号',
              height: 120.w,
              input: widget.data == null ? '' : widget.data!['mobile'],
              hasBottomLine: true,
            ),
            CustomLabel(
              label: 'ID',
              height: 120.w,
              input: widget.data == null ? '' : widget.data!['id_number'],
              hasBottomLine: true,
            ),
            qrcodeWidget(),
          ],
        ));
  }

  Widget qrcodeWidget() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 72.w, bottom: 19.w),
          padding: EdgeInsets.all(12.w),
          width: 210.w,
          height: 210.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.w),
            border: Border.all(width: 1.w, color: AppConfig.mainColor),
          ),
          child: widget.data == null
              ? SizedBox()
              : Image.network(
                  widget.data!['user_code'],
                  fit: BoxFit.fill,
                ),
        ),
        Text(
          '我的二维码',
          style: TextStyle(
            fontSize: 28.sp,
            color: AppConfig.textMainColor,
          ),
        ),
        SizedBox(height: 67.w)
      ],
    );
  }

  updateInfoRequest() {
    if (imageUrl == null || namecon.text.isEmpty) {
      EasyLoading.showError('信息不完整');
      return;
    }

    ServiceRequest.post(
      'member/updateInfo',
      data: {
        'nickname': namecon.text,
        'avatar': imageUrl,
      },
      success: (res) {
        EasyLoading.showSuccess('修改成功', duration: Duration(seconds: 1));
        Future.delayed(Duration(seconds: 1), () {
          Get.back(result: true);
        });
      },
      error: (error) {},
    );
  }
}
