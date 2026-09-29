plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.muster.sport"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    val releaseKeyAlias = System.getenv("KEY_ALIAS")
    val releaseKeyPassword = System.getenv("KEY_PASSWORD")
    val releaseStorePath = System.getenv("KEYSTORE_PATH")
    val releaseStorePassword = System.getenv("STORE_PASSWORD")
    val releaseSigningConfigured = listOf(
        releaseKeyAlias,
        releaseKeyPassword,
        releaseStorePath,
        releaseStorePassword,
    ).all { !it.isNullOrBlank() }
    val releaseBuildRequested = gradle.startParameter.taskNames.any {
        it.contains("release", ignoreCase = true)
    }

    if (releaseBuildRequested && !releaseSigningConfigured) {
        throw GradleException(
            "Release signing is not configured. Set KEY_ALIAS, KEY_PASSWORD, " +
                "KEYSTORE_PATH, and STORE_PASSWORD.",
        )
    }

    if (releaseSigningConfigured) {
        val releaseKeystore = file(requireNotNull(releaseStorePath))
        if (releaseBuildRequested && !releaseKeystore.isFile) {
            throw GradleException("Release keystore does not exist: $releaseKeystore")
        }
        signingConfigs.create("release") {
            keyAlias = requireNotNull(releaseKeyAlias)
            keyPassword = requireNotNull(releaseKeyPassword)
            storeFile = releaseKeystore
            storePassword = requireNotNull(releaseStorePassword)
        }
    }

    defaultConfig {
        applicationId = "com.muster.sport"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            if (releaseSigningConfigured) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
