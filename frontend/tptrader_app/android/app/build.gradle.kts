    plugins {
        id("com.android.application")
        id("kotlin-android")
        id("dev.flutter.flutter-gradle-plugin")  // Flutter plugin must come last
    }

    android {
        namespace = "com.example.tptrader_app"
        compileSdk = flutter.compileSdkVersion
        ndkVersion = flutter.ndkVersion

        compileOptions {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }

        kotlinOptions {
            jvmTarget = JavaVersion.VERSION_17.toString()
        }

        defaultConfig {
            applicationId = "com.example.tptrader_app"

            // 🔥 FIX — REQUIRED FOR CAMERA + PERMISSION_HANDLER 🔥
            minSdk = flutter.minSdkVersion          // DO NOT use flutter.minSdkVersion
            targetSdk = flutter.targetSdkVersion

            versionCode = flutter.versionCode
            versionName = flutter.versionName
        }

        buildTypes {
            release {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }

    flutter {
        source = "../.."
    }

    dependencies {
        implementation("androidx.core:core:1.12.0")
    }
