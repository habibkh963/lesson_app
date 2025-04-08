import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lessonsapp/core/constants/Colors.dart';

import '../core/constants/TextStyles.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.width,
    this.height,
    this.title,
    this.backGroundColor,
    this.textColor,
    this.icon,
    required this.onPressed,
  });
  final double? width;
  final double? height;
  final Color? backGroundColor;
  final Color? textColor;
  final String? title;
  final Widget? icon;
  final Function() onPressed;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Container(
        width: width ?? media(context).width * 0.8,
        height: height ?? media(context).width * 0.15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),

          color: backGroundColor ?? AppColors.mainColor,
        ),
        alignment: Alignment.center,
        child:
            icon != null
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon!,
                    SizedBox(width: 10.w),
                    Text(
                      title ?? '',
                      style: customStyle(
                        textColor ?? Colors.white,
                        16.sp,
                        FontWeight.w400,
                      ),
                    ),
                  ],
                )
                : Text(
                  title ?? '',
                  style: customStyle(
                    textColor ?? Colors.white,
                    16.sp,
                    FontWeight.w400,
                  ),
                ),
      ),
    );
  }
}
