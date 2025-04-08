import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/Colors.dart';
import '../../controllers/VideoController.dart';

class ViedoControlWidget extends StatelessWidget {
  const ViedoControlWidget({super.key, required this.videocontroller});

  final Videocontroller videocontroller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AnimatedOpacity(
        duration: Duration(milliseconds: 500),
        opacity: videocontroller.hideControl.value ? 0 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.textColor.withOpacity(0.8),
          ),
          child: Column(
            children: [
              VideoProgressIndicator(
                videocontroller.controller,
                allowScrubbing: true,
              ),
              SizedBox(height: videocontroller.isFullScreen ? 15.h : 5.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Icon(
                        videocontroller.controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: videocontroller.isFullScreen ? 40.h : 20.w,
                      ),
                      onTap: () {
                        videocontroller.controller.value.isPlaying
                            ? videocontroller.controller.pause()
                            : videocontroller.controller.play();
                        videocontroller.update();
                      },
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          child: Icon(
                            videocontroller.volume == 1.0
                                ? Icons.volume_off_outlined
                                : Icons.volume_up,
                            color: Colors.white,
                            size: videocontroller.isFullScreen ? 40.h : 20.w,
                          ),
                          onTap: () {
                            videocontroller.volume =
                                videocontroller.volume == 1.0 ? 0.0 : 1.0;
                            videocontroller.controller.setVolume(
                              videocontroller.volume,
                            );
                            videocontroller.update();
                            ;
                          },
                        ),
                        SizedBox(width: 15.h),
                        GestureDetector(
                          child: Icon(
                            videocontroller.isFullScreen
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                            size: videocontroller.isFullScreen ? 40.h : 20.w,
                            color: Colors.white,
                          ),
                          onTap: () {
                            videocontroller.toggleFullScreen(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
