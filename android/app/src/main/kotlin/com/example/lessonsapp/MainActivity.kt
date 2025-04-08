package com.example.lessonsapp
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import android.view.SurfaceView
import androidx.annotation.NonNull
class MainActivity : FlutterActivity(){
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
                SurfaceView(applicationContext).setSecure(true)
                this.window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
                window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)  
      }
}