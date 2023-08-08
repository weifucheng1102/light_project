import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/route_manager.dart';
import 'package:light_project/config/app.dart';

class CustomButton extends StatefulWidget {
  final double? height;
  final double? width;
  final String? title;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final FontWeight fontWeight;
  final void Function()? onTap;
  final double? borderRadius;
  final double? font;
  final Widget? child;

  const CustomButton({
    Key? key,
    this.height,
    this.width,
    this.title,
    this.onTap,
    this.bgColor = AppConfig.mainColor,
    this.borderColor = Colors.transparent,
    this.textColor = AppConfig.textMainColor,
    this.fontWeight = FontWeight.normal,
    this.borderRadius,
    this.font,
    this.child,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: widget.height ?? 100.w,
        width: widget.width ?? 618.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius == null
                ? (widget.height ?? 100.w) / 2
                : widget.borderRadius!),
            color: widget.bgColor,
            border: Border.all(color: widget.borderColor, width: 1.w)),
        alignment: Alignment.center,
        child: widget.child ??
            Text(
              widget.title ?? '',
              style: TextStyle(
                fontSize: widget.font ?? 30.sp,
                fontWeight: widget.fontWeight,
                color: widget.textColor,
              ),
            ),
      ),
    );
  }
}
