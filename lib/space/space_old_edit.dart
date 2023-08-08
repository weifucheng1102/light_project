import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/config/get_box.dart';
import 'package:light_project/mine/space_management_add.dart';
import 'package:light_project/service/service_request.dart';
import 'package:light_project/util/common.dart';
import 'package:light_project/util/event.dart';
import 'package:light_project/widget/custom_appbar.dart';
import 'package:light_project/widget/custom_button.dart';
import 'package:light_project/widget/custom_label.dart';
import 'package:oktoast/oktoast.dart';

class SpaceOldEdit extends StatefulWidget {
  final int spaceid;
  final int space_type_id;
  const SpaceOldEdit(
      {Key? key, required this.spaceid, required this.space_type_id})
      : super(key: key);

  @override
  State<SpaceOldEdit> createState() => _SpaceOldEditState();
}

class _SpaceOldEditState extends State<SpaceOldEdit> {
  final TextEditingController _nameCon = TextEditingController(text: '');
  int selectType = 0;

  List _showItemList = [];

  List<Widget> _showFilterList = [];

  Map? selectLevel1;
  Map? selectLevel2;

  List levelList = [];

  @override
  void initState() {
    super.initState();
    if (widget.space_type_id == 1) {
      _showItemList = [2, 3, 4, 5, 6];
    } else if (widget.space_type_id == 2) {
      _showItemList = [4, 5, 6];
    } else if (widget.space_type_id == 4) {
      _showItemList = [5, 6];
    }
    setState(() {});
  }

  getRequest(type_id) {
    ///space_type_id==1   楼宇 以及园区公共区域 不需要查filter
    ///space_type_id==2   楼层不需要查filter
    ///space_type_id==4   房间以及公共区域 不需要查filter

    if ((widget.space_type_id == 1 && [2, 3].contains(type_id)) ||
        (widget.space_type_id == 2 && [4].contains(type_id)) ||
        (widget.space_type_id == 4 && [5, 6].contains(type_id))) {
      selectType = type_id;
      _nameCon.text = '';
      _showFilterList = [];
      selectLevel1 = null;
      selectLevel2 = null;
      setState(() {});
    } else {
      ///4,5,6
      ServiceRequest.post(
        'space/parentSpace',
        data: {
          'space_id': widget.spaceid,
          'space_type': type_id,
        },
        success: (res) {
          bool haveSpace = false;
          levelList = res['data']['level'];

          if (type_id == 4) {
            if (levelList.isNotEmpty) {
              haveSpace = true;
            }
          } else {
            if (widget.space_type_id == 1) {
              levelList.forEach((element) {
                List level2 = element['level2'] ?? [];

                if (level2.isNotEmpty) {
                  haveSpace = true;
                }
              });
            } else {
              if (levelList.isNotEmpty) {
                haveSpace = true;
              }
            }
          }
          if (!haveSpace) {
            showToast('该空间类型不可创建');
          } else {
            selectType = type_id;
            _nameCon.text = '';
            selectLevel1 = null;
            selectLevel2 = null;
            setState(() {});
            _getFilterList(levelList);
          }
        },
        error: (error) {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgColor,
      appBar: MyAppBar(
        title: '空间管理',
      ),
      body: ListView(
        padding: EdgeInsets.all(30.w),
        children: itemList(),
      ),
    );
  }

  List<Widget> itemList() {
    return [
      Text(
        '请创建您需要管理的空间',
        style: TextStyle(
          fontSize: 30.sp,
          fontWeight: FontWeight.bold,
          color: AppConfig.textMainColor,
        ),
      ),
      SizedBox(
        height: 30.w,
      ),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.w),
          color: Colors.white,
        ),
        padding: EdgeInsets.only(top: 40.w, bottom: 86.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                '选择空间类型',
                style: TextStyle(
                  fontSize: 28.sp,
                  color: AppConfig.textMainColor,
                ),
              ),
            ),
            _spaceItems(),
            _showFilterList.isEmpty ? SizedBox() : _filterWidget(),
            selectType == 0 ? SizedBox() : _nameTextField(),
            Padding(
              padding: EdgeInsets.only(
                  left: 24.w, right: 24.w, top: 25.w, bottom: 98.w),
              child: Text(
                '注：如需创建更多空间类型，请联系绿大科技获取授权。',
                style: TextStyle(
                  fontSize: 24.sp,
                  color: AppConfig.textSecondColor,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  title: '确定创建',
                  width: 585.w,
                  height: 90.w,
                  onTap: () => _submitRequest(),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  _getFilterList(List level) {
    _showFilterList = [];

    if (selectType == 4) {
      if (widget.space_type_id == 1) {
        _showFilterList = [
          spaceFilterWidget(list: level, selectFilter: selectLevel1, index: 0),
        ];
      }
    } else {
      ///5,6
      if (widget.space_type_id == 1) {
        //循环一下list  如果level2 有空， 则移除
        List newList = [];

        level.forEach((element) {
          List level2 = element['level2'] ?? [];
          if (level2.isNotEmpty) {
            newList.add(element);
          }
        });

        _showFilterList = [
          spaceFilterWidget(
              list: newList, selectFilter: selectLevel1, index: 0),
          SizedBox(
            width: 24.w,
          ),
          spaceFilterWidget(
              list: selectLevel1 == null ? [] : selectLevel1!['level2'] ?? [],
              selectFilter: selectLevel2,
              index: 1),
        ];
      } else {
        _showFilterList = [
          spaceFilterWidget(list: level, selectFilter: selectLevel1, index: 0),
        ];
      }
    }
    setState(() {});
  }

  spaceFilterWidget({
    required List list,
    required Map? selectFilter,
    required index,
  }) {
    String hintStr = index == 0 ? '楼宇' : '楼层';

    return Container(
        width: (1.sw - 60.w - 48.w - 48.w) / 3,
        height: 64.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          border: Border.all(color: AppConfig.lineColor, width: 1.w),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            hint: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectFilter == null ? '选择$hintStr' : selectFilter['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selectFilter == null
                          ? AppConfig.textSecondColor
                          : AppConfig.textMainColor,
                      fontSize: 26.sp,
                    ),
                  ),
                ),
                Image.asset(
                  'images/bottom.png',
                  width: 36.w,
                ),
              ],
            ),
            icon: const SizedBox(),
            itemPadding: EdgeInsets.zero,
            isExpanded: true,
            items: list
                .map(
                  (e) => DropdownMenuItem(
                    alignment: AlignmentDirectional.center,
                    value: e,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        e['title'],
                        style: TextStyle(
                          fontSize: 26.sp,
                          color: AppConfig.textMainColor,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (index == 0) {
                if (selectLevel1 == value) {
                  return;
                }
                selectLevel1 = value as Map?;
                selectLevel2 = null;
              } else {
                if (selectLevel2 == value) {
                  return;
                }
                selectLevel2 = value as Map?;
              }

              _getFilterList(levelList);
            },
          ),
        ));
  }

  Widget _spaceItems() {
    return Container(
      height: 200.w,
      margin: EdgeInsets.only(top: 30.w),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          int showItemNum = _showItemList[index];
          return GestureDetector(
            onTap: () {
              if (selectType != showItemNum) {
                getRequest(showItemNum);
              }
            },
            child: SizedBox(
              width: 180.w,
              child: Image.asset(
                'images/space_manage${selectType == showItemNum ? "" : "_un"}_$showItemNum.png',
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(
            width: 20.w,
          );
        },
        itemCount: _showItemList.length,
      ),
    );
  }

  Widget _filterWidget() {
    return Padding(
      padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 48.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择空间所属上级',
            style: TextStyle(
              fontSize: 28.sp,
              color: AppConfig.textMainColor,
            ),
          ),
          SizedBox(
            height: 20.w,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: _showFilterList,
          ),
        ],
      ),
    );
  }

  Widget _nameTextField() {
    return Padding(
      padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 70.w),
      child: CustomLabel(
        label: '',
        input: '',
        height: 90.w,
        hasBottomLine: true,
        rightWidget: Expanded(
          child: TextField(
            style: TextStyle(
              fontSize: 28.sp,
              color: AppConfig.textMainColor,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              counterText: '',
              border: InputBorder.none,
              hintText: '请输入${_getNameWithSelect()}名称',
              hintStyle: TextStyle(
                fontSize: 28.sp,
                color: AppConfig.textSecondColor,
              ),
            ),
            controller: _nameCon,
          ),
        ),
      ),
    );
  }

  String _getNameWithSelect() {
    return getSpaceNameWithType(selectType);
  }

  String _getRequestUrlWithSelect() {
    switch (selectType) {
      case 1:
        return 'property/createPark';
      case 2:
        return 'property/createBuild';
      case 3:
        return 'property/createParkArea';
      case 4:
        return 'property/createFloor';
      case 5:
        return 'property/createSpace';
      case 6:
        return 'property/createSpace';
      default:
        return '';
    }
  }

  _submitRequest() {
    if (selectType == 4 && widget.space_type_id != 2 && selectLevel1 == null) {
      showToast('请选择空间所属上级');
      return;
    }

    if ([5, 6].contains(selectType)) {
      if ((widget.space_type_id == 1 && selectLevel2 == null) ||
          (widget.space_type_id == 2 && selectLevel1 == null)) {
        showToast('请选择空间所属上级');
        return;
      }
    }

    if (_nameCon.text.isEmpty) {
      showToast('请输入名称');
      return;
    }
    Map<String, dynamic> map = {
      'title': _nameCon.text,
    };
    if (selectType == 2 || selectType == 3) {
      map.addAll({'park_id': widget.spaceid});
    }
    if (selectType == 4) {
      if (widget.space_type_id == 1) {
        map.addAll({'build_id': selectLevel1!['id']});
      } else {
        map.addAll({'build_id': widget.spaceid});
      }
    }

    if (selectType == 5 || selectType == 6) {
      map.addAll({
        'space_type': selectType,
      });
      if (widget.space_type_id == 1) {
        map.addAll({'floor_id': selectLevel2!['id']});
      } else if (widget.space_type_id == 2) {
        map.addAll({'floor_id': selectLevel1!['id']});
      } else {
        map.addAll({'floor_id': widget.spaceid});
      }
    }

    ServiceRequest.post(
      _getRequestUrlWithSelect(),
      data: map,
      success: (res) {
        EasyLoading.showSuccess('创建成功', duration: Duration(milliseconds: 500));
        Future.delayed(Duration(milliseconds: 500), () {
          Get.back(result: true);
        });
      },
      error: (error) {},
    );
  }
}
