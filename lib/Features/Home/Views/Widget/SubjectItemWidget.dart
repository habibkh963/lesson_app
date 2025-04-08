import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lessonsapp/Features/VideoScreen/views/VideoScreen.dart';

import 'package:lessonsapp/core/constants/Colors.dart';
import 'package:lessonsapp/core/constants/TextStyles.dart';

class SubjectItemWidget extends StatelessWidget {
  const SubjectItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(VideoScreen.ROUTE_NAME);
      },

      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 8.w),
            width: media(context).width,
            height: media(context).height * 0.152,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppColors.textColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    height: constraints.maxHeight * 0.6,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: AppColors.textColor.withOpacity(0.08),
                    ),
                    child: Icon(
                      Icons.play_circle,
                      color: AppColors.mainColor,
                      size: 30.w,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.h),
                      Text(
                        'MathiMatics',
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                        style: customStyle(
                          AppColors.mainColor,
                          16.sp,
                          FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Expanded(
                        child: Text(
                          " Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: customStyle(
                            Colors.grey.withOpacity(0.5),
                            13.sp,
                            FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
