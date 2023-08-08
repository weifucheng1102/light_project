import 'package:flutter/material.dart';

class CustomDialog {
  static Future showCustomDialog(
    BuildContext context, {
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          ///Dialog的内部实现使用ConstrainedBox，并设置了最小宽度为280dp。
          ///添加UnconstrainedBox 移除showDialog 最小宽度
          return UnconstrainedBox(
            child: Material(
              color: Colors.transparent,
              child: child,
            ),
          );
        });
  }
}
