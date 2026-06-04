plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.anashassaan.wifiscanner"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.anashassaan.wifiscanner"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24 // Updated for modern compatibility
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 1. THIS FORCES THE RELEASE KEYSTORE AND PASSWORDS
    signingConfigs {
        create("release") {
            keyAlias = "upload"
            keyPassword = "Sweety1432"
            storeFile = file("upload-keystore.jks") 
            storePassword = "Sweety1432"
        }
    }

    buildTypes {
        release {
            // R8 / ProGuard Obfuscation & Shrinking for 2026 Play Store compliance
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // 2. THIS IS THE MAGIC FIX - NOW POINTS TO "release" INSTEAD OF "debug"
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.activity:activity-ktx:1.9.0")
}