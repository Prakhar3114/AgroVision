// android/build.gradle.kts
plugins {
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false

    // ✅ Only this line needed for Firebase
    id("com.google.gms.google-services") version "4.4.2" apply false
}