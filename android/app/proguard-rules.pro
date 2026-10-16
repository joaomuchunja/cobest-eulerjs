# Room / WorkManager generate their database implementation classes at compile
# time and instantiate them via reflection at runtime. R8 was renaming/removing
# those generated classes and constructors, which crashed app startup with
# "Failed to create an instance of class ... WorkDatabase" inside
# androidx.startup.InitializationProvider (WorkManagerInitializer).
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Database class *
-keep class **_Impl { <init>(...); }
-keepclassmembers class * extends androidx.room.RoomDatabase {
    public static <fields>;
}
-keep class androidx.work.impl.WorkDatabase { *; }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
