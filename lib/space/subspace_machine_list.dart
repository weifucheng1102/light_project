import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/mine/image_gridview.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/space/search_devices.dart';
import 'package:light_project/util/common.dart';
import 'package:light_project/util/event.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:light_project/widget/custom_dialog.dart';
import 'package:light_project/widget/custom_image_picker.dart';
import 'package:light_project/widget/custom_label.dart';
import 'package:oktoast/oktoast.dart';

import '../widget/custom_bottom_sheet.dart';

class SubspaceMachineList extends StatefulWidget {
  final int id;
  const SubspaceMachineList({Key? key, required this.id}) : super(key: key);

  @override
  State<SubspaceMachineList> createState() => _SubspaceMachineListState();
}

class _SubspaceMachineListState extends State<SubspaceMachineList> {
  Map? data;
  TextEditingController textCon = TextEditingController(text: '');

  List imageList = [];
  List uploadList = [];
  @override
  void initState() {
    super.initState();
    getRequest();
  }

  getRequest() {
    ServiceRequest.post(
      'space/machineSub',
      data: {
        'subspace_id': widget.id,
      },
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
        title: data == null ? '' : data!['title'],
        actions: [
          _addButton(),
        ],
      ),
      body: data == null
          ? SizedBox()
          : ListView.separated(
              padding: EdgeInsets.all(30.w),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.w),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: CustomLabel(
                    height: 120.w,
                    image: Image.asset(
                      'images/space_index_light_1.png',
                      width: 78.w,
                    ),
                    label: data!['machine'][index]['title'],
                    input: '',
                    hasRight: true,
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 20.w,
                );
              },
              itemCount: data!['machine'].length,
            ),
    );
  }

  Widget _addButton() {
    return Padding(
        padding: EdgeInsets.only(right: 10.w),
        child: TextButton(
          onPressed: () {
            CustomButtomSheet.showText(
              context,
              dataArr: ['修改', '删除', '添加设备'],
              clickCallback: (index, str) {
                if (index == 0) {
                  _addSubspaceDialog();
                } else if (index == 1) {
                  deleteAlertDialog();
                } else {
                  Get.to(SearchDevices());
                }
              },
            );
          },
          child: Text(
            '编辑',
            style: TextStyle(
              fontSize: 26.sp,
              color: AppConfig.textMainColor,
            ),
          ),
        ));
  }

  void deleteAlertDialog() {
    showDialog(
        context: context,
        builder: (cxt) {
          return CupertinoAlertDialog(
            title: Text(
              '确定要删除${data!['title']}吗？',
              style: TextStyle(fontSize: 30.w, color: const Color(0xff333333)),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('取消',
                    style: TextStyle(
                        fontSize: 28.w, color: const Color(0xff999999))),
                onPressed: () {
                  Navigator.pop(cxt);
                },
              ),
              CupertinoDialogAction(
                child: Text('确定',
                    style: TextStyle(fontSize: 28.w, color: Colors.red)),
                onPressed: () {
                  Navigator.pop(cxt);
                  _delRequest();
                },
              ),
            ],
          );
        });
  }

  _delRequest() {
    ServiceRequest.post(
      'space/delSubspace',
      data: {
        'id': widget.id,
      },
      success: (res) {
        bus.emit('updateSpace2');
        bus.emit('updateSpace1');
        bus.emit('updateSpace');
        EasyLoading.showSuccess('删除成功', duration: Duration(seconds: 1));
        Future.delayed(Duration(seconds: 1), () {
          Get.back();
        });
      },
      error: (error) {},
    );
  }

  _addSubspaceDialog() {
    textCon.text = data!['title'];
    imageList = [data!['full_image']];
    uploadList = [data!['image']];
    CustomDialog.showCustomDialog(
      context,
      child: StatefulBuilder(builder: (context, state) {
        return Container(
          width: 600.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.w),
            color: Colors.white,
          ),
          padding: EdgeInsets.symmetric(horizontal: 37.w, vertical: 43.w),
          child: Column(
            children: [
              Text(
                '修改子空间',
                style: TextStyle(
                  fontSize: 30.sp,
                  color: AppConfig.textMainColor,
                ),
              ),
              SizedBox(
                height: 50.w,
              ),
              Center(
                child: CustomLabel(
                  label: '',
                  input: '',
                  height: 100.w,
                  hasBottomLine: true,
                  rightWidget: Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            style: TextStyle(
                              fontSize: 28.sp,
                              color: AppConfig.textMainColor,
                            ),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              isCollapsed: true,
                              counterText: '',
                              border: InputBorder.none,
                              hintText: '请输入名称',
                              hintStyle: TextStyle(
                                fontSize: 28.sp,
                                color: AppConfig.textSecondColor,
                              ),
                            ),
                            controller: textCon,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50.w,
              ),
              ImageGridView(
                isEdit: true,
                imageList: imageList,
                crossAxisCount: 4,
                maxImageLength: 1,
                delectCallBack: (index) {
                  imageList.removeAt(index);
                  uploadList.removeAt(index);
                  state(() {});
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
                            state(() {});
                          });
                    });
                  });
                },
              ),
              SizedBox(
                height: 50.w,
              ),
              CustomButton(
                title: '确认修改',
                height: 80.w,
                width: 500.w,
                onTap: () => editRequest(),
              ),
              SizedBox(
                height: 36.w,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  '取消',
                  style: TextStyle(
                    fontSize: 26.sp,
                    color: AppConfig.textSecondColor,
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  editRequest() {
    if (uploadList.isEmpty || textCon.text.isEmpty) {
      showToast('信息不完整');
      return;
    }
    ServiceRequest.post(
      'space/updateSubspace',
      data: {
        'id': widget.id,
        'title': textCon.text,
        'image': uploadList.first,
      },
      success: (res) {
        bus.emit('updateSpace2');
        bus.emit('updateSpace1');
        bus.emit('updateSpace');
        EasyLoading.showSuccess('修改成功', duration: Duration(milliseconds: 500));
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pop(context);
          getRequest();
        });
      },
      error: (error) {},
    );
  }
}
