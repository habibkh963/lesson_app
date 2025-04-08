import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lessonsapp/Features/VideoScreen/views/Widget/FullScreenWidget.dart';
import 'package:lessonsapp/Features/VideoScreen/views/Widget/VideoControllWidget.dart';
import 'package:lessonsapp/core/constants/Colors.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/TextStyles.dart';
import '../controllers/VideoController.dart';

class VideoScreen extends StatelessWidget {
  VideoScreen({super.key});
  static const ROUTE_NAME = '/VideoScreen';
  Videocontroller videocontroller = Get.put(Videocontroller());
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (videocontroller.isFullScreen) {
          videocontroller.resetOrientaion();
        } else {
          Get.back();
        }
        return false;
      },
      child: Scaffold(
        appBar:
            videocontroller.isFullScreen
                ? null
                : AppBar(
                  toolbarHeight: 110.h,
                  automaticallyImplyLeading: true,
                  title: Text(
                    'Lesson ',
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    style: customStyle(Colors.black, 20.sp, FontWeight.w600),
                  ),
                ),
        body:
            videocontroller.isFullScreen
                ? GetBuilder<Videocontroller>(
                  builder: (_) {
                    return FullScreenWidget(videocontroller: videocontroller);
                  },
                )
                : Padding(
                  padding: EdgeInsets.all(12.0.w),
                  child: GetBuilder<Videocontroller>(
                    builder: (_) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child:
                                videocontroller.controller.value.isInitialized
                                    ? Container(
                                      clipBehavior: Clip.hardEdge,
                                      margin: EdgeInsets.all(5.w),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              videocontroller
                                                  .hideControl
                                                  .value = !videocontroller
                                                      .hideControl
                                                      .value;
                                            },
                                            child: AspectRatio(
                                              aspectRatio:
                                                  videocontroller
                                                      .controller
                                                      .value
                                                      .aspectRatio,
                                              child: VideoPlayer(
                                                videocontroller.controller,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 0.h,
                                            right: 0,
                                            left: 0,
                                            bottom: 0,
                                            child: Obx(() {
                                              if (videocontroller
                                                  .isBuffering
                                                  .value) {
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
                                                videocontroller
                                                        .controller
                                                        .value
                                                        .isPlaying
                                                    ? GestureDetector(
                                                      onTap: () {
                                                        videocontroller
                                                                .hideControl
                                                                .value =
                                                            !videocontroller
                                                                .hideControl
                                                                .value;
                                                      },
                                                      child: SizedBox(
                                                        width:
                                                            media(
                                                              context,
                                                            ).width,
                                                        height: 300.h,
                                                      ),
                                                    )
                                                    : GestureDetector(
                                                      onTap: () {
                                                        videocontroller
                                                                .controller
                                                                .value
                                                                .isPlaying
                                                            ? videocontroller
                                                                .controller
                                                                .pause()
                                                            : videocontroller
                                                                .controller
                                                                .play();
                                                        videocontroller
                                                            .update();
                                                      },
                                                      child: Container(
                                                        color: Colors.black54,
                                                        child: Center(
                                                          child: Icon(
                                                            videocontroller
                                                                    .controller
                                                                    .value
                                                                    .isPlaying
                                                                ? Icons.pause
                                                                : Icons
                                                                    .play_arrow,
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
                                            height:
                                                videocontroller.isFullScreen
                                                    ? 80.h
                                                    : 40.h,
                                            child: ViedoControlWidget(
                                              videocontroller: videocontroller,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : Container(
                                      width: media(context).width,
                                      height: media(context).height * 0.25,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        color: AppColors.textColor.withOpacity(
                                          0.08,
                                        ),
                                      ),
                                      child: Center(
                                        child: const CircularProgressIndicator(
                                          color: AppColors.mainColor,
                                        ),
                                      ),
                                    ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Description : ',
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                            style: customStyle(
                              Colors.black,
                              20.sp,
                              FontWeight.w600,
                            ),
                          ),
                          Text(
                            'This Flutter app is a great starting point to implement a video player with multiple video sources. With features like video switching, full-screen mode, and volume control, it provides an engaging and interactive experience. You can further customize this app by adding additional features like subtitles or background playback to enhance functionality.',
                            overflow: TextOverflow.clip,
                            maxLines: 3,
                            style: customStyle(
                              AppColors.textColor.withOpacity(0.5),
                              16.sp,
                              FontWeight.normal,
                            ),
                          ),
                          Expanded(
                            child: GetBuilder<Videocontroller>(
                              builder: (_) {
                                return ListView.builder(
                                  itemCount: videocontroller.videoUrls.length,
                                  itemBuilder: (
                                    BuildContext context,
                                    int index,
                                  ) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          videocontroller.changeVideo(index);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                videocontroller.index == index
                                                    ? AppColors.mainWithOpacity
                                                    : Colors
                                                        .white, // White color for the container
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ), // Light shadow color
                                                offset: Offset(
                                                  4.0,
                                                  4.0,
                                                ), // Shadow offset
                                                blurRadius: 8.0, // Blur effect
                                                spreadRadius:
                                                    2.0, // Spread the shadow a bit
                                              ),
                                            ],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          height: 120.h,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 15.w,
                                          ),
                                          width: double.infinity,
                                          child: Row(
                                            children: [
                                              SizedBox(width: 15),
                                              Container(
                                                height: 90.w,
                                                width: 90.w,
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                    255,
                                                    227,
                                                    225,
                                                    225,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Center(
                                                  child:
                                                      videocontroller.index ==
                                                              index
                                                          ? Icon(
                                                            Icons.pause_circle,
                                                            color:
                                                                AppColors
                                                                    .mainColor,
                                                          )
                                                          : Icon(
                                                            Icons
                                                                .play_circle_fill,
                                                            color:
                                                                AppColors
                                                                    .mainColor,
                                                          ),
                                                ),
                                              ),
                                              SizedBox(width: 10.w),
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 10.h),
                                                    Text(
                                                      'Lecture $index',
                                                      overflow:
                                                          TextOverflow.clip,
                                                      maxLines: 1,
                                                      style: customStyle(
                                                        videocontroller.index ==
                                                                index
                                                            ? Colors.white
                                                            : AppColors
                                                                .mainColor,
                                                        16.sp,
                                                        FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8.h),
                                                    Expanded(
                                                      child: Text(
                                                        " Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book",
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        maxLines: 2,
                                                        style: customStyle(
                                                          videocontroller
                                                                      .index ==
                                                                  index
                                                              ? Colors.white
                                                              : Colors.grey
                                                                  .withOpacity(
                                                                    0.5,
                                                                  ),
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
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
      ),
    );
  }
}
