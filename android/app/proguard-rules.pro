# R8/ProGuard rules for release builds.
#
# The Flutter engine and most plugins ship their own consumer rules, so this
# file only needs the gaps. The Flutter embedding references the Play Core
# split-install / deferred-components classes even when the app doesn't use
# them; keep R8 from warning about the missing references.
-dontwarn com.google.android.play.core.**
-keep class io.flutter.embedding.** { *; }
