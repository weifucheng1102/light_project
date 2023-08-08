import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/utils.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final TextStyle? titleStyle;
  final Color? backgroundColor;
  final Color? backIconColor;
  final String? backImgName;
  final Widget? leading;
  final Widget? flexibleSpace;
  final double elevation;
  final Widget? titleWidget;
  final bool titleCenter;
  final dynamic backMap;
  final Function()? onTap;
  final bool canBack; //控制安卓底部按钮是否能返回
  final bool backIconShow;
  const MyAppBar({
    Key? key,
    this.title = '',
    this.actions,
    this.titleStyle,
    this.backgroundColor,
    this.backImgName,
    this.leading,
    this.onTap,
    this.flexibleSpace,
    this.canBack = true,
    this.elevation = 0,
    this.titleWidget,
    this.titleCenter = true,
    this.backMap,
    this.backIconColor = Colors.black,
    this.backIconShow = true,
  }) : super(key: key);
  @override
  _MyAppBarState createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(45);
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: AppBar(
        titleSpacing: 0,
        centerTitle: widget.titleCenter,
        title: widget.titleWidget ??
            Text(
              widget.title!,
              textScaleFactor: 1,
              style: widget.titleStyle ??
                  TextStyle(
                    color: const Color(0xff101530),
                    fontSize: 34.sp,
                    fontWeight: FontWeight.normal,
                  ),
            ),
        leading: widget.backIconShow
            ? (widget.leading ??
                GestureDetector(
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: widget.backIconColor,
                  ),
                  onTap: widget.onTap ??
                      () {
                        Navigator.of(context).pop(widget.backMap);
                      },
                ))
            : null,
        backgroundColor: widget.backgroundColor ?? Colors.transparent,
        flexibleSpace: widget.flexibleSpace,
        elevation: widget.elevation,
        actions: widget.actions ?? [],
      ),
      onWillPop: widget.canBack && widget.backIconShow && GetPlatform.isIOS
          ? null
          : () async {
              if (widget.canBack && widget.backIconShow) {
                Navigator.of(context).pop(widget.backMap);
              }
              return false;
            },
    );
  }
}
