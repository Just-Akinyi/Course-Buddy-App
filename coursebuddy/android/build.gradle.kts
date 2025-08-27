// Root-level (project-level) Gradle file

plugins {
    // ✅ Android Gradle Plugin (AGP) for app + library
    id("com.android.application") version "8.4.2" apply false
    id("com.android.library") version "8.4.2" apply false

    // ✅ Kotlin Android plugin
    id("org.jetbrains.kotlin.android") version "1.9.25" apply false

    // ✅ Google services (Firebase)
    id("com.google.gms.google-services") version "4.4.3" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Custom build directory configuration
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
