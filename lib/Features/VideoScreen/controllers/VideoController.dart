import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../views/VideoScreen.dart' show FullScreenVideoPlayer;

class Videocontroller extends GetxController {
  late VideoPlayerController controller;
  List<String> videoUrls = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  ];
  int index = 0;
  double volume = 1.0; // Volume level
  bool isFullScreen = false; // Full screen state
  RxBool hideControl = false.obs;
  @override
  void onInit() {
    controller =
        VideoPlayerController.networkUrl(Uri.parse(videoUrls[0]))
          ..initialize().then((_) {
            update();
          })
          ..addListener(() {
            isBuffering.value =
                !controller.value.isPlaying && controller.value.isBuffering;
          });
    ;
    super.onInit();
  }

  RxBool isBuffering = false.obs;
  void changeVideo(int indexV) {
    controller.pause(); // Pause the current video
    index = indexV;
    controller =
        VideoPlayerController.networkUrl(Uri.parse(videoUrls[index]))
          ..initialize().then((_) {
            controller.play();
            update();
          })
          ..addListener(() {
            isBuffering.value =
                !controller.value.isPlaying && controller.value.isBuffering;
          });
    update();
  }

  void toggleFullScreen(BuildContext context) {
    isFullScreen = !isFullScreen;
    update();
    if (isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (context) => FullScreenVideoPlayer(controller: controller),
      //   ),
      // );
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      // Navigator.of(context).pop();
    }
    update();
  }

  resetOrientaion() {
    isFullScreen = false;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}
