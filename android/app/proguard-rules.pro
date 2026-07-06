# Keep Flutter engine and plugin classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep generated app classes used by Flutter
-keep class com.example.lessonsapp.** { *; }

# Keep AndroidX and support classes commonly used by plugins
-dontwarn com.google.android.gms.**
-dontwarn androidx.**
