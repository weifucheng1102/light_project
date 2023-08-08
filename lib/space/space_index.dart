import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:light_project/config/app.dart';
import 'package:light_project/config/application.dart';
import 'package:light_project/space/connect_wifi.dart';
import 'package:light_project/space/search_devices.dart';
import 'package:light_project/widget/custom_bottom_sheet.dart';
import 'package:light_project/mine/space_management.dart';
import 'package:light_project/service/service_request.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:light_project/space/space_control.dart';
import 'package:light_project/space/space_detail.dart';
import 'package:light_project/space/space_old_edit.dart';
import 'package:light_project/space/subspace_list.dart';
import 'package:light_project/util/common.dart';
import 'package:light_project/util/event.dart';

class SpaceIndex extends StatefulWidget {
  const SpaceIndex({Key? key}) : super(key: key);

  @override
  State<SpaceIndex> createState() => _SpaceIndexState();
}

class _SpaceIndexState extends State<SpaceIndex> {
  final ScrollController _scrollController = ScrollController();

  ///手否显示顶部标题
  bool showTitle = false;

  ///顶层空间 切换列表
  List spaceList = [];

  ///选中的 顶层空间
  Map? selectSpace;

  /// 选中顶层空间之后 请求的空间详情
  Map? spaceInfo;

  ///显示筛选的Widget数组
  List<Widget> filterWidgetList = [];

  ///选中筛选的楼宇
  Map? selectBuild;

  ///选中筛选的楼层
  Map? selectFloor;

  ///选中筛选的区域
  Map? selectRoom;

  ///底部 子空间列表
  Map? subSpaceMap;

  var titleState;

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(() {});
    bus.off('updateSpace');
  }

  @override
  void initState() {
    super.initState();
    getRequest();
    bus.on('updateSpace', (arg) => getRequest());
    _scrollController.addListener(() {
      if (_scrollController.offset > 200.w) {
        showTitle = true;
      } else {
        showTitle = false;
      }

      titleState(() {});
    });
  }

  ///获取顶层空间 列表请求
  getRequest() {
    selectBuild = null;
    selectFloor = null;
    selectRoom = null;
    ServiceRequest.post(
      'space/allSpace',
      data: {},
      showProgress: false,
      success: (res) {
        spaceList = res['data'];
        if (spaceList.isNotEmpty) {
          if (selectSpace == null) {
            selectSpace = spaceList.first;
          } else {
            List li = spaceList
                .where((element) =>
                    element['space_id'] == selectSpace!['space_id'])
                .toList();
            if (li.isNotEmpty) {
              selectSpace = li.first;
            } else {
              selectSpace = spaceList.first;
            }
          }

          getSpaceInfoRequest();
        } else {
          appl!.tabbarChanged!(3);
        }
      },
      error: (error) {},
    );
  }

  ///根据选中的顶层空间  查询 该空间的具体信息
  getSpaceInfoRequest() {
    ServiceRequest.post(
      'space/spaceList',
      data: {
        'space_id': selectSpace!['space_id'],
      },
      showProgress: false,
      success: (res) {
        spaceInfo = res['data'];
        getFilterList();
      },
      error: (error) {},
    );
  }

  ///获取子空间
  getSubSpaceRequest(int space_id) {
    ServiceRequest.post(
      'space/subSpaceList',
      data: {
        ///顶部选择space  type 传1
        'type': selectBuild == null && selectFloor == null && selectRoom == null
            ? 1
            : 2,
        'space_id': space_id,
      },
      success: (res) {
        subSpaceMap = res['data'];
        if (mounted) {
          setState(() {});
        }
      },
      error: (error) {},
    );
  }

  ///组装筛选的数组
  getFilterList() {
    ///三层筛选
    if (spaceInfo!.containsKey('build') && spaceInfo!['build'].length != 0) {
      filterWidgetList = [
        spaceFilterWidget(
            parentFilter: spaceInfo, selectFilter: selectBuild, index: 0),
        SizedBox(
          width: 12.w,
        ),
        spaceFilterWidget(
            parentFilter: selectBuild, selectFilter: selectFloor, index: 1),
        SizedBox(
          width: 12.w,
        ),
        spaceFilterWidget(
            parentFilter: selectFloor, selectFilter: selectRoom, index: 2),
      ];
    }

    ///两层筛选
    else if (spaceInfo!.containsKey('floor') &&
        spaceInfo!['floor'].length != 0) {
      filterWidgetList = [
        spaceFilterWidget(
            parentFilter: spaceInfo, selectFilter: selectFloor, index: 1),
        SizedBox(
          width: 12.w,
        ),
        spaceFilterWidget(
            parentFilter: selectFloor, selectFilter: selectRoom, index: 2),
      ];
    }

    ///一层筛选
    else if (spaceInfo!.containsKey('room') && spaceInfo!['room'].length != 0) {
      filterWidgetList = [
        spaceFilterWidget(
            parentFilter: spaceInfo, selectFilter: selectRoom, index: 2)
      ];
    } else {
      ///没有筛选按钮
      filterWidgetList = [];
    }

    int? spaceid;
    if (spaceInfo != null) {
      spaceid = spaceInfo!['space']['id'];
    }
    if (selectBuild != null) {
      spaceid = selectBuild!['id'];
    }
    if (selectFloor != null) {
      spaceid = selectFloor!['id'];
    }
    if (selectRoom != null) {
      spaceid = selectRoom!['id'];
    }

    getSubSpaceRequest(spaceid!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.bgColor,
      body: selectSpace == null
          ? SizedBox()
          : NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                List<Widget> li = [
                  _spaceInfoWidget(),
                ];
                if (filterWidgetList.isNotEmpty) {
                  li.add(
                    ///筛选 Widget
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: HeaderPersistentHeaderDelegate(
                        Container(
                          height: 93.w,
                          color: AppConfig.bgColor,
                          padding: EdgeInsets.only(left: 30.w, right: 30.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: filterWidgetList,
                          ),
                        ),
                        maxHeight: 93.w,
                        minHeight: 93.w,
                      ),
                    ),
                  );
                }

                return li;
              },
              body: subSpaceMap == null ? SizedBox() : _spaceItemListWidget()),
    );
  }

  ///空间信息
  _spaceInfoWidget() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: AppConfig.bgColor,
      automaticallyImplyLeading: false,
      expandedHeight: 460.w - paddingSizeTop(context),
      title: StatefulBuilder(
        builder: (context, state) {
          titleState = state;
          return showTitle ? _spaceTitleWidget() : SizedBox();
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            color: AppConfig.bgColor,
            image: DecorationImage(
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
              image: AssetImage('images/space_index_bg.png'),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            children: [
              SizedBox(
                height: 148.w,
              ),
              _spaceTitleWidget(),
              SizedBox(
                height: 37.w,
              ),
              _spaceOverViewWidget(),
            ],
          ),
        ),
      ),
    );
  }

  ///顶部 空间 名字 以及 操作
  _spaceTitleWidget() {
    return SizedBox(
      height: 48.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 0.45.sw,
            child: DropdownButtonHideUnderline(
              child: DropdownButton2(
                hint: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      selectSpace!['title'],
                      style: TextStyle(
                        color: AppConfig.textMainColor,
                        fontSize: 34.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 12.w,
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
                items: spaceList
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
                  if (value != selectSpace) {
                    setState(() {
                      selectSpace = value as Map?;
                      selectBuild = null;
                      selectFloor = null;
                      selectRoom = null;
                    });
                    getSpaceInfoRequest();
                  }
                },
              ),
            ),
          ),
          Row(
            children: [
              [3, 5, 6].contains(selectSpace!['space_type_id'])
                  ? InkWell(
                      onTap: () => Get.to(SubspaceList(
                        id: selectSpace!['space_id'],
                        isSame: false,
                      )),
                      child: Image.asset(
                        'images/space_index_home.png',
                        width: 58.w,
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        CustomButtomSheet.showText(context,
                            dataArr: ['添加新空间', '管理旧空间'],
                            clickCallback: (index, str) {
                          if (index == 0) {
                            Get.to(SpaceManagement());
                          } else {
                            Get.to(SpaceOldEdit(
                              spaceid: selectSpace!['space_id'],
                              space_type_id: selectSpace!['space_type_id'],
                            ))!
                                .then((res) {
                              if (res != null) {
                                getRequest();
                              }
                            });
                          }
                        });
                      },
                      child: Image.asset(
                        'images/space_index_add.png',
                        width: 58.w,
                      ),
                    ),
              SizedBox(
                width: 20.w,
              ),
              InkWell(
                onTap: () => Get.to(
                  SpaceControl(),
                ),
                child: Image.asset(
                  'images/space_index_menu.png',
                  width: 58.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///空间信息总览
  _spaceOverViewWidget() {
    return Container(
      height: 215.w,
      padding: EdgeInsets.only(top: 24.w, bottom: 27.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.w),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 30.w),
            child: Row(
              children: [
                Image.asset(
                  'images/space_index_light.png',
                  width: 34.w,
                ),
                SizedBox(
                  width: 11.w,
                ),
                Text(
                  '照明系统-设备总览',
                  style: TextStyle(
                    fontSize: 28.sp,
                    color: AppConfig.textMainColor,
                  ),
                )
              ],
            ),
          ),
          Row(
            children: spaceInfo == null
                ? []
                : [
                    _spaceOverViewNumberWidget(
                      '在线',
                      spaceInfo!['online'].toString(),
                    ),
                    _spaceOverViewNumberWidget(
                      '开启',
                      spaceInfo!['open'].toString(),
                    ),
                    _spaceOverViewNumberWidget(
                      '关闭',
                      spaceInfo!['close'].toString(),
                    ),
                    _spaceOverViewNumberWidget(
                      '离线',
                      spaceInfo!['offline'].toString(),
                    ),
                    _spaceOverViewNumberWidget(
                      '异常',
                      spaceInfo!['unusual'].toString(),
                    ),
                  ],
          )
        ],
      ),
    );
  }

  ///空间 设备总览 item
  _spaceOverViewNumberWidget(
    String title,
    String count,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              color: AppConfig.textMainColor,
              fontSize: 36.sp,
              fontFamily: 'OPPOSans',
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 13.w,
          ),
          Text(
            title,
            style: TextStyle(
              color: AppConfig.textSecondColor,
              fontSize: 26.sp,
            ),
          )
        ],
      ),
    );
  }

  ///筛选 Widget  item
  spaceFilterWidget({
    required Map? parentFilter,
    required Map? selectFilter,
    required index,
  }) {
    String hintStr = index == 0
        ? '楼宇'
        : index == 1
            ? '楼层'
            : '区域';
    List list = [];
    if (parentFilter == null) {
      list = [];
    } else {
      Map resetMap = {'id': 0, 'title': '重置'};
      if (index == 0) {
        list = parentFilter.containsKey('build')
            ? (parentFilter['build'] as List).map((e) => e).toList()
            : [];

        if (list.isNotEmpty && selectBuild != null) {
          list.insert(0, resetMap);
        }
      } else if (index == 1) {
        list = parentFilter.containsKey('floor')
            ? (parentFilter['floor'] as List).map((e) => e).toList()
            : [];

        if (list.isNotEmpty && selectFloor != null) {
          list.insert(0, resetMap);
        }
      } else {
        list = parentFilter.containsKey('room')
            ? (parentFilter['room'] as List).map((e) => e).toList()
            : [];

        if (list.isNotEmpty && selectRoom != null) {
          list.insert(0, resetMap);
        }
      }
    }

    return Container(
        width: (1.sw - 60.w - 24.w) / 3,
        height: 64.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: Colors.white,
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
                if (selectBuild == value) {
                  return;
                }
                if ((value as Map?)!['id'] == 0) {
                  selectBuild = null;
                } else {
                  selectBuild = value as Map?;
                }
                selectFloor = null;
                selectRoom = null;
              } else if (index == 1) {
                if (selectFloor == value) {
                  return;
                }
                if ((value as Map?)!['id'] == 0) {
                  selectFloor = null;
                } else {
                  selectFloor = value as Map?;
                }

                selectRoom = null;
              } else {
                if (selectRoom == value) {
                  return;
                }
                if ((value as Map?)!['id'] == 0) {
                  selectRoom = null;
                } else {
                  selectRoom = value as Map?;
                }
              }

              getFilterList();
            },
          ),
        ));
  }

  Widget _spaceItemListWidget() {
    return ListView.separated(
      padding:
          EdgeInsets.only(left: 30.w, top: 12.w, bottom: 30.w, right: 30.w),
      itemBuilder: (context, index) {
        if (subSpaceMap!['level1'] == null ||
            subSpaceMap!['level1'].length == 0) {
          return Container(
            padding: EdgeInsets.all(25.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.w),
              color: Colors.white,
            ),
            child: _subItemList(subSpaceMap!['subspace'] ?? []),
          );
        } else {
          return _spaceBuildItemWidget(subSpaceMap!['level1'][index]);
        }
      },
      separatorBuilder: (context, index) {
        return SizedBox(height: 20.w);
      },
      itemCount:
          (subSpaceMap!['level1'] == null || subSpaceMap!['level1'].length == 0)
              ? subSpaceMap!['subspace'] == null
                  ? 0
                  : 1
              : subSpaceMap!['level1'].length,
    );
  }

  Widget _spaceBuildItemWidget(Map item) {
    bool open = true;
    return StatefulBuilder(builder: (context, widgetstate) {
      return Container(
        padding: EdgeInsets.all(25.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.w),
          color: Colors.white,
        ),
        child: Column(
          children: [
            InkWell(
              child: _spaceBuildTitleWidget(item, open),
              onTap: () {
                open = !open;
                widgetstate(() {});
              },
            ),
            open ? _spaceFloorItemWidget(item) : SizedBox(),
          ],
        ),
      );
    });
  }

  Widget _spaceBuildTitleWidget(Map item, bool open) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                item['title'],
                style: TextStyle(
                  fontSize: 28.sp,
                  color: AppConfig.textMainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 16.w,
              ),
              Image.asset(
                open ? 'images/bottom.png' : 'images/right.png',
                width: 32.w,
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => Get.to(SpaceDetail(id: item['id'])),
          child: Image.asset(
            'images/space_index_home.png',
            width: 58.w,
          ),
        ),
      ],
    );
  }

  Widget _spaceFloorItemWidget(Map item) {
    return item['level2'] == null || item['level2'].length == 0
        ? _subItemList(item['subspace'] ?? [])
        : ListView.separated(
            padding: EdgeInsets.only(top: 26.w),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  _spaceFloorTitleWidget(item['level2'][index]),
                  _subItemList(item['level2'][index]['subspace'] ?? []),
                ],
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(
                height: 20.w,
              );
            },
            itemCount: item['level2'].length,
          );
  }

  Widget _spaceFloorTitleWidget(Map item) {
    return Row(
      children: [
        Text(
          item['title'],
          style: TextStyle(
            fontSize: 26.sp,
            color: Color(0xff666666),
          ),
        )
      ],
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
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
class HeaderPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;
  HeaderPersistentHeaderDelegate(this.child,
      {this.minHeight = 0, this.maxHeight = 0});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
