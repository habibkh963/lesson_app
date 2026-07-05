import 'dart:io' show File;

import 'package:advanced_pdf_viewer/advanced_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lessonsapp/Features/Home/Views/Widget/SubjectItemWidget.dart';
import 'package:lessonsapp/core/constants/AppAssets.dart';

import 'package:path_provider/path_provider.dart';
import '../../../core/constants/TextStyles.dart';
import '../../../core/pdf_viewer_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const ROUTE_NAME = '/HomeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = PdfViewerController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
    ]);
    _loadPdf();
  }

  bool _isLoading = true;
  Future<Uint8List> _loadPdf() async {
    // Fallback: copy asset manually and use filePath
    final byteData = await rootBundle.load('assets/1778682681.pdf');
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp.pdf');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());

    return byteData.buffer.asUint8List();
  }

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
      body: SafeArea(
        child: Stack(
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
                children: <Widget>[
                  SubjectItemWidget(),

                  // Expanded(
                  //   child: FutureBuilder<Uint8List>(
                  //     future: _loadPdf(),
                  //     builder: (context, snapshot) {
                  //       if (snapshot.connectionState ==
                  //           ConnectionState.waiting) {
                  //         return const Center(
                  //           child: CircularProgressIndicator(),
                  //         );
                  //       }
                  //       if (snapshot.hasError) {
                  //         return Center(
                  //           child: Text('Error: ${snapshot.error}'),
                  //         );
                  //       }
                  //       if (snapshot.data == null) {
                  //         return const Center(child: Text('No data'));
                  //       }
                  //       return AdvancedPdfViewer.bytes(
                  //         snapshot.data ?? Uint8List(0),
                  //         controller: AdvancedPdfViewerController(),
                  //         config: PdfViewerConfig(
                  //           enablePageNumber: true,
                  //           showZoomButtons: true,
                  //           // Enable Bookmarks
                  //           allowFullScreen: true,
                  //           highlightColor: Colors.red,
                  //           showHighlightButton:
                  //               true, // Optional: unique ID for persistence
                  //           // Set Language (English or Arabic)

                  //           // Page Changed Callback
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),

                  // Action buttons row
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
