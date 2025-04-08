import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lessonsapp/Features/Home/Views/HomeScreen.dart';
import 'package:lessonsapp/core/constants/AppAssets.dart';
import 'package:lessonsapp/core/constants/TextStyles.dart';

import '../../../shared/CustomButton.dart';
import '../../../shared/CustomTextField.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const ROUTE_NAME = '/';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image.asset(
              AppAssets.illustrateHighQuality,
              width: media(context).width,
            ),

            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.w),
                child: Column(
                  children: [
                    SizedBox(height: 15.h),
                    Text(
                      'Login',

                      style: customStyle(Colors.black, 32.sp, FontWeight.bold),
                    ),
                    SizedBox(height: 15.h),
                    CustomTextField(
                      hint: 'Enter UserName',
                      prefix: Icon(Icons.import_contacts),
                      controller: TextEditingController(),
                    ),
                    CustomTextField(
                      hint: 'Enter PassKey',
                      prefix: Icon(Icons.import_contacts),
                      controller: TextEditingController(),
                    ),
                    SizedBox(height: 15.h),
                    CustomButton(
                      title: 'Login',
                      height: 40.h,
                      onPressed: () {
                        Get.toNamed(HomeScreen.ROUTE_NAME);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
