// android/build.gradle.kts

buildscript {
    // We define the version here using a Kotlin variable
    val kotlinVersion = "1.9.10"

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Correct Kotlin syntax uses parentheses and double quotes
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")

        // This line is for Google Services (Firebase), now fixed for Kotlin syntax
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// This section tells Flutter where to put the "build" files
val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()

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