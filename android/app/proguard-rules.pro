# Keep Flutter wrapper and engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Hive and its adapters
-keep class com.anashassaan.wifiscanner.shared.models.** { *; }
-keep class * extends com.hive.TypeAdapter { *; }

# Prevent obfuscation of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Flutter Deferred Components / Play Store Split compatibility (Suppressing errors for missing classes)
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontnote com.google.android.play.core.**
-dontnote io.flutter.embedding.engine.deferredcomponents.**