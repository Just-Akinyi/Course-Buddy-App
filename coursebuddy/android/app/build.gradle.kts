plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.coursebuddy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.coursebuddy"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        debug {
            // Debug build: no shrinking, no minify
            isMinifyEnabled = false
            isShrinkResources = false
        }
        release {
            // Release build: enable shrinking and minify
            signingConfig = signingConfigs.getByName("debug") // use real signing for production
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
    // Firebase BoM ensures compatible versions
    implementation(platform("com.google.firebase:firebase-bom:34.1.0"))
    implementation("com.google.firebase:firebase-analytics")
    // Add more Firebase dependencies here as needed
    // implementation("com.google.firebase:firebase-auth-ktx")
    // implementation("com.google.firebase:firebase-firestore-ktx")
}

// Show deprecation warnings during Java/Gradle compilation in release/debug
tasks.withType<JavaCompile> {
    if (name.contains("Debug", ignoreCase = true)) {
        // Optional: suppress deprecation warnings in debug builds
        options.compilerArgs.add("-Xlint:-deprecation")
    } else {
        // Show deprecation warnings in release builds
        options.compilerArgs.add("-Xlint:deprecation")
    }
}
