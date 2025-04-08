import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lessonsapp/Features/Home/Views/Widget/SubjectItemWidget.dart';
import 'package:lessonsapp/core/constants/AppAssets.dart';

import '../../../core/constants/TextStyles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const ROUTE_NAME = '/HomeScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 110.h,
        automaticallyImplyLeading: true,
        title: Text(
          'Subjects',
          overflow: TextOverflow.clip,
          maxLines: 1,
          style: customStyle(Colors.black, 20.sp, FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            child: Opacity(
              opacity: 0.3,
              child: SvgPicture.asset(
                AppAssets.learningSvg,
                width: media(context).width * 0.7,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[SubjectItemWidget()],
            ),
          ),
        ],
      ),
    );
  }
}
