import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:light_project/config/app.dart';

class CustomLabel extends StatelessWidget {
  final Widget? image;
  final String label;
  final String input;
  final String? tip;
  final double? height;
  final String? bottomLabel;
  final TextStyle? labelStyle;
  final TextStyle? inputStyle;
  final TextStyle? tipStyle;
  final TextStyle? bottomLabelStyle;
  final TextEditingController? textCon;
  final TextAlign? textfieldAlign;

  final bool hasRight;
  final Widget? rightImage;
  final bool hasBottomLine;
  final Widget? rightWidget;
  final VoidCallback? callback;

  final TextInputType? keyboardType;
  final bool? isObscure;
  final TextStyle? textfieldStyle;
  final int? textfieldMaxLength;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;

  /// ```dart
  /// labelStyle:
  /// TextStyle(
  ///    fontSize: 28.sp,
  ///    color: const Color(0xff333333),
  ///      ),
  /// inputStyle:
  /// TextStyle(
  ///    fontSize: 26.sp,
  ///    color: const Color(0xffafafaf),
  ///      ),
  /// ```
  const CustomLabel({
    required this.label,
    required this.input,
    this.tip,
    this.height,
    this.bottomLabel,
    this.labelStyle,
    this.inputStyle,
    this.tipStyle,
    this.bottomLabelStyle,
    this.image,
    this.hasRight = false,
    this.rightImage,
    this.hasBottomLine = false,
    this.rightWidget,
    this.callback,
    this.textCon,
    this.textfieldAlign,
    this.isObscure = false,
    this.keyboardType = TextInputType.text,
    this.textfieldStyle,
    this.textfieldMaxLength,
    this.focusNode,
    this.inputFormatters,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: SizedBox(
        height: height ?? 100.w,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  bottomLabel != null
                      ? bottomLabelWidget()
                      : Row(
                          children: [
                            Visibility(
                              visible: image != null,
                              child: Padding(
                                padding: EdgeInsets.only(right: 22.w),
                                child: image,
                              ),
                            ),
                            Text(
                              label,
                              style: labelStyle ??
                                  TextStyle(
                                    fontSize: 28.sp,
                                    color: AppConfig.textMainColor,
                                  ),
                            ),
                          ],
                        ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        rightWidget ??
                            (textCon == null
                                ? Expanded(
                                    child: Text(
                                      input.isEmpty && tip != null
                                          ? tip!
                                          : input,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.end,
                                      style: input.isEmpty && tip != null
                                          ? (tipStyle ??
                                              TextStyle(
                                                fontSize: 28.sp,
                                                color: const Color(0xffAFAFAF),
                                              ))
                                          : (inputStyle ??
                                              TextStyle(
                                                fontSize: 28.sp,
                                                color:
                                                    AppConfig.textSecondColor,
                                              )),
                                    ),
                                  )
                                : Expanded(
                                    child: TextField(
                                      style: textfieldStyle,
                                      focusNode: focusNode,
                                      maxLength: textfieldMaxLength,
                                      decoration: InputDecoration(
                                        isCollapsed: true,
                                        counterText: '',
                                        border: InputBorder.none,
                                        hintText: tip ?? '',
                                        hintStyle: tipStyle ??
                                            TextStyle(
                                              fontSize: 28.sp,
                                              color: AppConfig.textSecondColor,
                                            ),
                                      ),
                                      inputFormatters: inputFormatters,
                                      textAlign:
                                          textfieldAlign ?? TextAlign.end,
                                      controller: textCon,
                                      obscureText: isObscure!,
                                      keyboardType: keyboardType,
                                      onChanged: onChanged,
                                    ),
                                  )),
                        Visibility(
                          visible: hasRight || rightImage != null,
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.w),
                            child: rightImage ??
                                Image.asset(
                                  'images/grey_right.png',
                                  width: 14.w,
                                ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: hasBottomLine,
              child: Container(
                height: 1.w,
                color: AppConfig.lineColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomLabelWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: labelStyle ??
              TextStyle(
                fontSize: 28.sp,
                color: const Color(0xff222222),
              ),
        ),
        SizedBox(
          height: 3.w,
        ),
        Text(
          bottomLabel!,
          style: bottomLabelStyle ??
              TextStyle(
                fontSize: 22.sp,
                color: const Color(0xffafafaf),
              ),
        ),
      ],
    );
  }
}
