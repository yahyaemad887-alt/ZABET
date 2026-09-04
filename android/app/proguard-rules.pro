-keep class androidx.work.** { *; }
-keep class * extends androidx.work.ListenableWorker { *; }
-keep class androidx.work.impl.** { *; }
-keep class * extends androidx.sqlite.db.SupportSQLiteOpenHelper { *; }
-dontwarn androidx.work.**

-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.google.android.gms.** { *; }