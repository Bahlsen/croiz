import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.dsl.KotlinVersion
import org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
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

// Ensure consistent Kotlin compiler settings across all Android subprojects (incl. plugins)
subprojects {
    pluginManager.withPlugin("org.jetbrains.kotlin.android") {
        // Configure Kotlin compiler options using the new DSL
        tasks.withType<KotlinJvmCompile>().configureEach {
            compilerOptions {
                // Some environments may lack the jvmTarget option in compilerOptions; rely on Java toolchain below
                languageVersion.set(KotlinVersion.KOTLIN_2_0)
                apiVersion.set(KotlinVersion.KOTLIN_2_0)
            }
        }
    }

    // Ensure Java compilation uses 17 across all modules to avoid source/target 8 warnings
    tasks.withType<org.gradle.api.tasks.compile.JavaCompile>().configureEach {
        sourceCompatibility = JavaVersion.VERSION_17.toString()
        targetCompatibility = JavaVersion.VERSION_17.toString()
        // Do not use --release for Android: AGP needs bootclasspath for Android APIs
        // options.release.set(17)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
