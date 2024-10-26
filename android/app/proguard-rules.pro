# Flutter-specific ProGuard rules

# Keep class names for Flutter
-keep class io.flutter.** { *; }

# Keep classes used by reflection
-keep class com.techiez.** { *; }
-keepattributes Signature

# You may need additional rules based on your dependencies
# Add rules for other libraries here (like Retrofit, Dio, etc.)