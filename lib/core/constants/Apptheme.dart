import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lessonsapp/core/constants/Colors.dart';

class Apptheme {
  static lightTheme() => ThemeData(
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    primaryColor: AppColors.mainColor,
    canvasColor: Colors.white,
    indicatorColor: AppColors.mainColor,
    cardTheme: CardTheme(
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      color: Colors.white,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.mainColor,
    ),
    cardColor: Colors.white,
  );

  // static darkTheme() => ThemeData(
  //   appBarTheme: const AppBarTheme(
  //     elevation: 0,
  //     surfaceTintColor: Colors.transparent,
  //     backgroundColor: AppColors.splashBackgroundDark,
  //   ),
  //   useMaterial3: true,
  //   scaffoldBackgroundColor: AppColors.splashBackgroundDark,
  //   brightness: Brightness.dark,
  //   primaryColor: AppColors.darkMainColor,
  //   floatingActionButtonTheme: FloatingActionButtonThemeData(
  //     backgroundColor: AppColors.darkMainColor,
  //   ),
  //   canvasColor: AppColors.splashBackgroundDark,
  //   cardTheme: CardTheme(
  //     surfaceTintColor: Colors.transparent,
  //     clipBehavior: Clip.hardEdge,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
  //   ),
  //   indicatorColor: AppColors.mainColor,
  //   cardColor: AppColors.cardColor,
  // );
}
