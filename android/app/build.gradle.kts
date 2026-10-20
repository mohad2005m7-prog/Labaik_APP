import java.util.Base64

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// قيم --dart-define (Flutter بيبعتها لـ Gradle مشفّرة Base64) — منها مفتاح Google Maps
val dartDefines: Map<String, String> = (project.findProperty("dart-defines") as String?)
    ?.split(",")
    ?.mapNotNull { encoded ->
        val entry = String(Base64.getDecoder().decode(encoded)).split("=", limit = 2)
        if (entry.size == 2) entry[0] to entry[1] else null
    }
    ?.toMap()
    ?: emptyMap()

android {
    namespace = "com.example.labaik"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.labaik"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // مفتاح Google Maps لـ AndroidManifest (نفس المفتاح اللي بيستخدمه كود Dart)
        manifestPlaceholders["MAPS_API_KEY"] = dartDefines["MAPS_API_KEY"] ?: ""
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
