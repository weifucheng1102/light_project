import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/widget/custom_bottom_sheet.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/space/subspace_list.dart';
import 'package:light_project/space/subspace_machine_list.dart';
import 'package:light_project/util/common.dart';
import 'package:light_project/util/event.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_dialog.dart';
import 'package:oktoast/oktoast.dart';

class SpaceDetail extends StatefulWidget {
  final int id;
  const SpaceDetail({Key? key, required this.id}) : super(key: key);

  @override
  State<SpaceDetail> createState() => _SpaceDetailState();
}

class _SpaceDetailState extends State<SpaceDetail> {
  Map? data;
  @override
  void dispose() {
    super.dispose();
    bus.off('updateSpace1');
  }

  @override
  void initState() {
    super.initState();
    getRequest();
    bus.on('updateSpace1', (arg) {
      getRequest();
    });
  }

  getRequest() {
    ServiceRequest.post(
      'space/spaceInfo',
      data: {
        'space_id': widget.id,
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
          TextButton(
            onPressed: () {
              CustomButtomSheet.showText(context, dataArr: ['修改', '删除'],
                  clickCallback: (index, str) {
                if (index == 0) {
                  showParentNameEditDialog(
                    context,
                    name: data!['title'],
                    onTap: (res) {
                      editNameRequest(res);
                    },
                  );
                } else {
                  deleteAlertDialog();
                }
              });
            },
            child: Text(
              '编辑',
              style: TextStyle(
                fontSize: 26.sp,
                color: AppConfig.textMainColor,
              ),
            ),
          ),
        ],
      ),
      body: data == null
          ? SizedBox()
          : ListView.separated(
              padding: EdgeInsets.all(30.w),
              itemBuilder: (context, index) {
                return listItem(data!['level'][index]);
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 20.w,
                );
              },
              itemCount: data!['level'].length,
            ),
    );
  }

  Widget listItem(item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.w),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(30.w),
      child: Column(
        children: [
          _spaceFloorTitleWidget(item),
          _subItemList(item['subspace']),
        ],
      ),
    );
  }

  Widget _subItemList(List subspace) {
    return subspace.isEmpty
        ? SizedBox()
        : GridView.count(
            crossAxisCount: 3,
            padding: EdgeInsets.only(top: 24.w),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            mainAxisSpacing: 24.w,
            crossAxisSpacing: 24.w,
            childAspectRatio: 198 / 270,
            children: subspace
                .map((e) => Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(bottom: 13.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.w),
                              image: DecorationImage(
                                image: NetworkImage(
                                  e['image'],
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    subspaceButton(
                                        'images/space_index_del.png'),
                                    subspaceButton(
                                        'images/space_index_wifi.png'),
                                    subspaceButton(
                                        'images/space_index_message.png'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.w,
                        ),
                        Text(
                          e['title'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 26.sp,
                            color: AppConfig.textMainColor,
                          ),
                        ),
                      ],
                    ))
                .toList());
  }

  Widget subspaceButton(image) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Image.asset(
        image,
        width: 24.w,
      ),
    );
  }

  Widget _spaceFloorTitleWidget(item) {
    return Row(
      children: [
        Expanded(
          child: Text(
            item['title'],
            style: TextStyle(
              fontSize: 28.sp,
              color: AppConfig.textMainColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            InkWell(
              onTap: () {
                Get.to(SubspaceList(
                  id: item['id'],
                  isSame: item['id'] == widget.id,
                ));
              },
              child: Image.asset(
                'images/space_index_home.png',
                width: 58.w,
              ),
            ),
            SizedBox(
              width: 21.w,
            ),
            Image.asset(
              'images/space_index_menu.png',
              width: 58.w,
            ),
            SizedBox(
              width: 21.w,
            ),
            Image.asset(
              'images/space_index_lock.png',
              width: 58.w,
            ),
          ],
        ),
      ],
    );
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
                  delRequest();
                  Navigator.pop(cxt);
                },
              ),
            ],
          );
        });
  }

  editNameRequest(name) {
    if (name.isEmpty) {
      showToast('请输入名称');
      return;
    }
    ServiceRequest.post(
      'property/editSpace',
      data: {
        'id': widget.id,
        'title': name,
      },
      success: (res) {
        EasyLoading.showSuccess('修改成功', duration: Duration(milliseconds: 500));
        Future.delayed(Duration(milliseconds: 500), () {
          bus.emit('updateSpace');
          Navigator.pop(context);
          getRequest();
        });
      },
      error: (error) {},
    );
  }

  delRequest() {
    ServiceRequest.post(
      'space/delSpace',
      data: {
        'id': widget.id,
      },
      success: (res) {
        bus.emit('updateSpace');
        EasyLoading.showSuccess('删除成功', duration: Duration(seconds: 1));
        Future.delayed(Duration(seconds: 1), () {
          Get.back();
        });
      },
      error: (error) {},
    );
  }
}
