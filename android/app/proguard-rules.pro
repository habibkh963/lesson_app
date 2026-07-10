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
# 1. Protect Flutter System Engine Internals
# This ensures the underlying framework communication layers remain stable
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# 2. Protect the MethodChannel Bridge entrypoint in MainActivity
# Keeps the layout structure intact so Dart can locate your "com.example.lessonsapp/security" channel
-keep class com.example.lessonsapp.MainActivity {
    public void configureFlutterEngine(io.flutter.embedding.engine.FlutterEngine);
}

# 3. HEAVILY OBFUSCATE Security and Secrets Classes
# We do NOT add a "-keep" rule for EncryptionHelper or Secrets.
# Instead, we force R8 to scramble their class names, methods, and variables into 'a', 'b', 'c'.
-keepclassmembers class com.example.lessonsapp.security.** {
    *** *;
}

# 4. Strip Debugging Information and Optimization Logs
# This removes line numbers and source file names, making stack traces useless to an attacker.
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable