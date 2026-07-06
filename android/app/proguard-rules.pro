# Keep Flutter engine and plugin classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Keep generated app classes used by Flutter
-keep class com.example.lessonsapp.** { *; }

# Keep Play Core split classes used by Flutter deferred components
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep AndroidX and support classes commonly used by plugins
-dontwarn com.google.android.gms.**
-dontwarn androidx.**
