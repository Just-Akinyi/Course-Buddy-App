plugins {
    id("com.android.application")
    id("kotlin-android")
    
    // ✅ Add the Google services Gradle plugin
    id("com.google.gms.google-services")
    
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.coursebuddy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.coursebuddy"
        minSdk = flutter.minSdkVersion
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
    // ✅ Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.1.0"))

    // ✅ Example: Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")

    // TODO: Add any other Firebase dependencies you want
    // e.g. Firestore, Auth, Messaging, etc.
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
}
