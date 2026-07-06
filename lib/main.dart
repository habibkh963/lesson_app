import 'package:device_preview/device_preview.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:lessonsapp/Features/VideoScreen/views/VideoScreen.dart';
import 'package:safe_device/safe_device.dart';
import 'package:safe_device/safe_device_config.dart';

import 'Features/Home/Views/HomeScreen.dart';
import 'Features/auth/Views/Login.dart';
import 'core/util/remote/dio_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SafeDevice.init(
    SafeDeviceConfig(
      mockLocationCheckEnabled: false,
    ), // disables mock location check on Android
  );

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Get.theme.brightness,
    ),
  );
  _initializeFlutterSecureStorage();
  runApp(
    DevicePreview(
      enabled: false,

      builder: (context) => MyApp(), // Wrap your app
    ),
  );
}

late FlutterSecureStorage storage;
void _initializeFlutterSecureStorage() {
  storage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      biometricPromptTitle: 'Flutter Secure Storage Example',
      biometricPromptSubtitle: 'Please unlock to access data.',
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        DioHelper.init();
        return GetMaterialApp(
          useInheritedMediaQuery: true,

          debugShowCheckedModeBanner: false,

          fallbackLocale: Locale('en', ''),
          locale: Locale('en'),

          // translations: Messages(),
          getPages: [
            GetPage(
              name: LoginPage.ROUTE_NAME,

              page: () => LoginPage(),

              arguments: Get.arguments,
              transition: Transition.leftToRight,
              transitionDuration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuad,
            ),
            GetPage(
              name: HomeScreen.ROUTE_NAME,
              page: () => HomeScreen(),

              arguments: Get.arguments,
              transition: Transition.leftToRight,
              transitionDuration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuad,
            ),
            GetPage(
              name: VideoScreen.ROUTE_NAME,

              page: () => VideoScreen(),

              arguments: Get.arguments,
              transition: Transition.leftToRight,
              transitionDuration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuad,
            ),
          ],
          title: 'Lessons Daily',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: LoginPage.ROUTE_NAME,
        );
      },
    );
  }
}
