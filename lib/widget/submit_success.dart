import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/app.dart';
import 'custom_button.dart';

class SubmitSuccess extends StatefulWidget {
  final String title;
  final String desc;
  final List<Widget>? bottomButtons;
  final bool? showImage;
  final String? buttonText;
  final void Function()? onTap;

  const SubmitSuccess({
    Key? key,
    required this.title,
    required this.desc,
    this.onTap,
    this.bottomButtons,
    this.buttonText,
    this.showImage,
  }) : super(key: key);

  @override
  State<SubmitSuccess> createState() => _SubmitSuccessState();
}

class _SubmitSuccessState extends State<SubmitSuccess> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 560.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.w),
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 48.w),
      child: Column(
        children: [
          // Visibility(
          //   visible: widget.showImage == null || widget.showImage!,
          //   child: Padding(
          //     padding: EdgeInsets.only(bottom: 32.w),
          //     child: Image.asset(
          //       assetImagePath('success'),
          //       width: 120.w,
          //     ),
          //   ),
          // ),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 36.sp,
              color: AppConfig.textMainColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 20.w,
          ),
          Text(
            widget.desc,
            style: TextStyle(
              fontSize: 26.sp,
              color: Color(0xff808591),
            ),
          ),
          SizedBox(
            height: 56.w,
          ),
          widget.bottomButtons != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: widget.bottomButtons!,
                )
              : CustomButton(
                  title: widget.buttonText ?? '确定',
                  width: 360.w,
                  height: 84.w,
                  onTap: widget.onTap ??
                      () {
                        Navigator.pop(context);
                      },
                ),
        ],
      ),
    );
  }
}
