import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lessonsapp/core/constants/Colors.dart';

import '../core/constants/TextStyles.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.prefix,
    this.controller,
    this.suffix,
    required this.hint,
  });
  final Widget prefix;
  final Widget? suffix;
  final String hint;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 40.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: TextFormField(
                clipBehavior: Clip.antiAlias,
                style: customStyle(
                  AppColors.lightText,
                  16.sp,
                  FontWeight.normal,
                ),
                controller: controller,
                cursorColor: AppColors.mainColor,
                decoration: InputDecoration(
                  suffix: suffix,
                  hintText: hint,
                  hintStyle: customStyle(
                    AppColors.lightText,
                    14.sp,
                    FontWeight.normal,
                  ),
                  // constraints: BoxConstraints(minHeight: 80.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    borderSide: BorderSide(color: Colors.red.withOpacity(0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    borderSide: BorderSide(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    borderSide: BorderSide(color: Colors.red.withOpacity(0.5)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
