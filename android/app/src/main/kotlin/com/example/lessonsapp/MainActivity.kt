package com.example.lessonsapp

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    // private var pdfChannel: PdfViewerMethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // pdfChannel = PdfViewerMethodChannel(context, flutterEngine)
    }

    override fun onDestroy() {
        // pdfChannel?.dispose()
        super.onDestroy()
    }
}