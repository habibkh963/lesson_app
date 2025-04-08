import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// TextStyle? customStyle() {
//   return TextStyle(
//       color: Color.fromRGBO(251, 251, 251, 1),
//       fontSize: 20.sp,
//       fontWeight: FontWeight.w700,
//       fontFamily: 'Almarai');
// }

TextStyle? customStyle(Color? color, double? size, FontWeight? fontWeight) {
  return TextStyle(
    color: color,
    fontSize: size,
    fontFamily: 'Almarai',
    fontWeight: fontWeight ?? FontWeight.w700,
  );
}

Size media(context) {

  return MediaQuery.of(context).size;
}

bool bigHeightSize(context) {
  double height = media(context).height;
  if (height >= 780 && height < 936.0) {
    return true;
  } else {
    return false;
  }
}

bool mediombigHeightSize(context) {
  double height = media(context).height;
  if (height > 680 && height < 780) {
    return true;
  } else {
    return false;
  }
}

bool mediombigwidthSize(context) {
  double width = media(context).width;
  if (width >= 360 && width < 400.0) {
    return true;
  } else {
    return false;
  }
}

bool smallHeightSize(double height) {
  if (height < 680 && height < 580) {
    return true;
  } else {
    return false;
  }
}
