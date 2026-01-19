plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.sudan.passport.photo"
    compileSdk = 35
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.sudan.passport.photo"
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val envKeyPath = System.getenv("KEYSTORE_PATH") ?: project.findProperty("KEYSTORE_PATH")?.toString()
            val envKeyPassword = System.getenv("KEYSTORE_PASSWORD") ?: project.findProperty("KEYSTORE_PASSWORD")?.toString()
            val envKeyAlias = System.getenv("KEY_ALIAS") ?: project.findProperty("KEY_ALIAS")?.toString()
            val envKeyPasswordAlias = System.getenv("KEY_PASSWORD") ?: project.findProperty("KEY_PASSWORD")?.toString()

            if (envKeyPath != null && envKeyPassword != null && envKeyAlias != null && envKeyPasswordAlias != null) {
                storeFile = file(envKeyPath)
                storePassword = envKeyPassword
                keyAlias = envKeyAlias
                keyPassword = envKeyPasswordAlias
            }
        }
    }

    buildTypes {
        release {
            val isSigningConfigured = signingConfigs.getByName("release").storeFile != null
            if (isSigningConfigured) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // Fallback to debug for local release testing if release keys aren't provided
                signingConfig = signingConfigs.getByName("debug")
            }
            
            // Link ProGuard rules for ML Kit and image processing
            proguardFiles("proguard-rules.pro")
            
            ndk {
                abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a", "x86_64"))
            }
        }
    }
}

flutter {
    source = "../.."
}
