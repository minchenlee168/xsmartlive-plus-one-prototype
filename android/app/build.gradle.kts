plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // GA4 / Firebase Analytics
    id("com.google.gms.google-services")
}

android {
    namespace = "com.xsmartlive.plus.one"
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
        applicationId = "com.xsmartlive.plus.one"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "merchant"

    productFlavors {
        create("default") {
            dimension = "merchant"
            applicationId = "com.xsmartlive.plus.one"
            buildConfigField("String", "BASE_URL", "\"https://api-uat-1.xsmartlive.com\"")
            buildConfigField("String", "MERCHANT_ID", "\"default\"")
        }

        create("merchantA") {
            dimension = "merchant"
            applicationId = "com.xsmartlive.plus.one.merchant_a"
            buildConfigField("String", "BASE_URL", "\"https://api.merchant-a.com\"")
            buildConfigField("String", "MERCHANT_ID", "\"merchant_a\"")
            resValue("string", "app_name", "Brand A Live")
        }
        create("merchantB") {
            dimension = "merchant"
            applicationId = "com.xsmartlive.plus.one.merchant_b"
            buildConfigField("String", "BASE_URL", "\"https://api.merchant-b.com\"")
            buildConfigField("String", "MERCHANT_ID", "\"merchant_b\"")
            resValue("string", "app_name", "Brand B Shop")
        }
        create("merchantC") {
            dimension = "merchant"
            applicationId = "com.xsmartlive.plus.one.merchant_c"
            buildConfigField("String", "BASE_URL", "\"https://api.merchant-c.com\"")
            buildConfigField("String", "MERCHANT_ID", "\"merchant_c\"")
            resValue("string", "app_name", "Brand C Live")
        }
    }

    buildFeatures {
        buildConfig = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("ANDROID_KEYSTORE_PATH")?.trim() ?: "xsmartlive-plus-one.jks"
            storeFile = file(keystorePath)
            storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")?.trim() ?: "50810188"
            keyAlias = System.getenv("ANDROID_KEY_ALIAS")?.trim() ?: "xsmartlive-plus-one"
            keyPassword = System.getenv("ANDROID_KEY_PASSWORD")?.trim() ?: "50810188"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

// APK 輸出檔名加版號
android.applicationVariants.all {
    val vn = versionName
    val vc = versionCode
    val flavor = flavorName
    val type = buildType.name
    outputs.all {
        (this as com.android.build.gradle.internal.api.BaseVariantOutputImpl)
            .outputFileName = "app-${flavor}-${type}-v${vn}-${vc}.apk"
    }
}

// AAB 輸出檔名加版號
tasks.whenTaskAdded {
    if (name.startsWith("bundle") && name.endsWith("Release")) {
        doLast {
            val vn = android.defaultConfig.versionName
            val vc = android.defaultConfig.versionCode
            // name 例如 "bundleDefaultRelease" -> flavor = "default"
            val flavor = name
                .removePrefix("bundle")
                .removeSuffix("Release")
                .replaceFirstChar { it.lowercaseChar() }
            val dir = layout.buildDirectory.dir("outputs/bundle/${flavor}Release").get().asFile
            dir.listFiles()
                ?.filter { it.extension == "aab" }
                ?.forEach { it.renameTo(File(it.parent, "app-${flavor}-release-v${vn}-${vc}.aab")) }
        }
    }
}
