import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:light_project/widget/custom_appbar.dart';

class WaterRipples extends StatefulWidget {
  final double size;
  const WaterRipples({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WaterRipplesState();
}

class _WaterRipplesState extends State<WaterRipples>
    with TickerProviderStateMixin {
  //动画控制器
  final List<AnimationController> _controllers = [];
  //动画控件集合
  final List<Widget> _children = [];
  //添加检索动画计时器
  Timer? _searchBluetoothTimer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: _children,
      ),
    );
  }

  ///初始化检索动画，依次添加5个缩放动画，形成水波纹动画效果
  void _startAnimation() {
    //动画启动前确保_children控件总数为0
    _children.clear();
    int count = 0;
    //添加第一个圆形缩放动画
    _addSearchAnimation(true);
    //以后每隔1秒，再次添加一个缩放动画，总共添加4个
    _searchBluetoothTimer =
        Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _addSearchAnimation(true);
      count++;
      if (count >= 4) {
        timer.cancel();
      }
    });
  }

  ///添加检索动画控件
  ///init: 首次添加5个基本控件时，=true，
  void _addSearchAnimation(bool init) {
    var controller = _createController();
    _controllers.add(controller);
    // print("tag——children length : ${_children.length}");
    var animation = Tween(begin: 100.w, end: widget.size)
        .animate(CurvedAnimation(parent: controller, curve: Curves.linear));
    if (!init) {
      //5个基本动画控件初始化完成的情况下，每次添加新的动画控件时，移除第一个，确保动画控件始终保持5个
      _children.removeAt(0);
      //添加新的动画控件
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        //动画页面没有执行退出情况下，继续添加动画
        _children.add(AnimatedBuilder(
            animation: controller,
            builder: (BuildContext context, Widget? child) {
              return Opacity(
                // opacity: (300.0 - animation.value) / 300.0,
                opacity:
                    1.0 - ((animation.value - 100.w) / (widget.size - 100.w)),
                child: ClipOval(
                  child: Container(
                    width: animation.value,
                    height: animation.value,
                    color: const Color(0xff9fbaff),
                  ),
                ),
              );
            }));
        try {
          //动画页退出时，捕获可能发生的异常
          controller.forward();
          setState(() {});
        } catch (e) {
          return;
        }
      });
    } else {
      _children.add(AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? child) {
            return Opacity(
              opacity:
                  1.0 - ((animation.value - 100.w) / (widget.size - 100.w)),
              child: ClipOval(
                child: Container(
                  width: animation.value,
                  height: animation.value,
                  color: const Color(0xff9fbaff),
                ),
              ),
            );
          }));
      controller.forward();
      setState(() {});
    }
  }

  ///创建蓝牙检索动画控制器
  AnimationController _createController() {
    var controller = AnimationController(
        duration: const Duration(milliseconds: 4000), vsync: this);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        if (_controllers.contains(controller)) {
          _controllers.remove(controller);
        }
        //每次动画控件结束时，添加新的控件，保持动画的持续性
        if (mounted) _addSearchAnimation(false);
      }
    });
    return controller;
  }

  ///销毁动画
  void _disposeSearchAnimation() {
    //释放动画所有controller
    for (var element in _controllers) {
      element.dispose();
    }
    _controllers.clear();
    _searchBluetoothTimer?.cancel();
    _children.clear();
  }

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void dispose() {
    // print("tag--=========================dispose===================");
    //销毁动画
    _disposeSearchAnimation();

    super.dispose();
  }
}
