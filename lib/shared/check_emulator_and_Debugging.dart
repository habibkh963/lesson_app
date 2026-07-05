import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_device/safe_device.dart';

import '../core/constants/Colors.dart';
import '../core/constants/TextStyles.dart';

class SecurityCheck {
  static Future<void> check(BuildContext context) async {
    final isJailBroken = await SafeDevice.isJailBroken;
    final isRealDevice = await SafeDevice.isRealDevice;
    final isDevMode = await SafeDevice.isDevelopmentModeEnable;
    final isRooted =
        (await SafeDevice.rootDetectionDetails)["isRooted"] ?? false;

    // if (isJailBroken) {
    //   _showBlockedDialog(
    //     context,
    //     title: "تنبيه أمني",
    //     message:
    //         "تم اكتشاف أن الجهاز معدل .\n\n"
    //         "حرصًا على أمان بياناتك، لا يمكن تشغيل التطبيق على أجهزة  isJailBroken معدلة.",
    //   );
    //   return;
    // }
    if (isRooted) {
      _showBlockedDialog(
        context,
        title: "تنبيه أمني",
        message:
            "تم اكتشاف أن الجهاز معدل .\n\n"
            "حرصًا على أمان بياناتك، لا يمكن تشغيل التطبيق isRooted على أجهزة معدلة.",
      );
      return;
    }
    if (!isRealDevice) {
      _showBlockedDialog(
        context,
        title: "جهاز غير مدعوم",
        message:
            "يبدو أنك تستخدم محاكي (Emulator).\n\n"
            "يرجى تشغيل التطبيق على جهاز حقيقي لضمان الأداء والأمان.",
      );
      return;
    }
    if (kDebugMode) {
      _showBlockedDialog(
        context,
        title: "تنبيه أمني",
        message:
            "هذا الإصدار مخصص للاختبار والتطوير فقط.\n\n"
            "يرجى تحميل النسخة الرسمية من المتجر لاستخدام التطبيق بشكل طبيعي.",
      );
      return;
    }

    if (isDevMode) {
      _showBlockedDialog(
        context,
        title: "وضع المطور مفعّل",
        message:
            "تم اكتشاف أن وضع المطور (Developer Mode) مفعل.\n\n"
            "يرجى إيقافه ثم إعادة تشغيل التطبيق.",
      );
      return;
    }
  }

  // -----------------------------
  // Dialog UI
  // -----------------------------
  static void _showBlockedDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              backgroundColor: Get.theme.cardColor,
              title: Text(
                title,
                style: customStyle(
                  Get.theme.primaryColor,
                  15.sp,
                  FontWeight.w600,
                ),
              ),
              content: Text(
                message,
                style: customStyle(
                  AppColors.textColor,
                  13.sp,
                  FontWeight.normal,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => exit(0),
                  child: Text(
                    "إغلاق التطبيق",
                    style: customStyle(
                      const Color.fromARGB(255, 220, 70, 65),
                      15.sp,
                      FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
