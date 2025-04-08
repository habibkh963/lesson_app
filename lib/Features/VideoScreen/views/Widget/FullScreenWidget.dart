import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lessonsapp/Features/VideoScreen/views/Widget/VideoControllWidget.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/Colors.dart';
import '../../../../core/constants/TextStyles.dart';
import '../../controllers/VideoController.dart';

class FullScreenWidget extends StatelessWidget {
  const FullScreenWidget({super.key, required this.videocontroller});

  final Videocontroller videocontroller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          videocontroller.controller.value.isInitialized
              ? Container(
                clipBehavior: Clip.hardEdge,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        videocontroller.hideControl.value =
                            !videocontroller.hideControl.value;
                      },
                      child: AspectRatio(
                        aspectRatio:
                            media(context).width / media(context).height,
                        child: VideoPlayer(videocontroller.controller),
                      ),
                    ),
                    Positioned(
                      top: 0.h,
                      right: 0,
                      left: 0,
                      bottom: 0,
                      child: Obx(() {
                        if (videocontroller.isBuffering.value) {
                          return Center(
                            child:
                                CircularProgressIndicator(), // Loading indicator
                          );
                        } else {
                          return SizedBox();
                        }
                      }),
                    ),
                    Positioned.fill(
                      child:
                          videocontroller.controller.value.isPlaying
                              ? GestureDetector(
                                onTap: () {
                                  videocontroller.hideControl.value =
                                      !videocontroller.hideControl.value;
                                },
                                child: SizedBox(
                                  width: media(context).width,
                                  height: 300.h,
                                ),
                              )
                              : GestureDetector(
                                onTap: () {
                                  videocontroller.controller.value.isPlaying
                                      ? videocontroller.controller.pause()
                                      : videocontroller.controller.play();
                                  videocontroller.update();
                                },
                                child: Container(
                                  color: Colors.black54,
                                  child: Center(
                                    child: Icon(
                                      videocontroller.controller.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 64.0,
                                    ),
                                  ),
                                ),
                              ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 90.h,
                      child: ViedoControlWidget(
                        videocontroller: videocontroller,
                      ),
                    ),
                  ],
                ),
              )
              : Container(
                width: media(context).width,
                height: media(context).height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: AppColors.textColor.withOpacity(0.08),
                ),
                child: Center(
                  child: const CircularProgressIndicator(
                    color: AppColors.mainColor,
                  ),
                ),
              ),
    );
  }
}
