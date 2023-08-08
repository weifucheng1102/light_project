import 'package:flutter/cupertino.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class CustomRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function()? onLoad;
  final Future<void> Function()? onRefresh;
  final int count;
  final Widget? emptyWidget;
  const CustomRefresh({
    Key? key,
    required this.count,
    required this.child,
    this.onLoad,
    this.onRefresh,
    this.emptyWidget,
  }) : super(key: key);

  @override
  State<CustomRefresh> createState() => _CustomRefreshState();
}

class _CustomRefreshState extends State<CustomRefresh> {
  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      header: MaterialHeader(),
      footer: MaterialFooter(),
      child: widget.child,
      onLoad: widget.onLoad,
      onRefresh: widget.onRefresh,
      emptyWidget: widget.count == 0
          ? Center(child: widget.emptyWidget ?? Text('无数据'))
          : null,
    );
  }
}
