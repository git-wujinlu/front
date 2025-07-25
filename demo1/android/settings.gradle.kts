pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
//        maven {
//            setUrl("https://maven.aliyun.com/repository/public")
//        }
//        maven {
//            setUrl("https://maven.aliyun.com/repository/google")
//        }
//        maven {
//            setUrl("https://maven.aliyun.com/repository/jcenter")
//        }
//        maven {
//            setUrl("https://maven.aliyun.com/nexus/content/repositories/releases")
//        }
//        maven {
//            setUrl("https://maven.aliyun.com/repository/releases")
//        }
//        maven {
//            setUrl("https://maven.aliyun.com/repository/central")
//        }
//        maven {
//            setUrl("https://maven.aliyun.com/repository/gradle-plugin")
//        }
        maven {
            setUrl("https://www.jitpack.io")
        }
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
    repositories {
        maven {
            setUrl("https://maven.aliyun.com/repository/public")
        }
        maven {
            setUrl("https://maven.aliyun.com/repository/google")
        }
        maven {
            setUrl("https://maven.aliyun.com/repository/jcenter")
        }
        maven {
            setUrl("https://maven.aliyun.com/nexus/content/repositories/releases")
        }
        maven {
            setUrl("https://www.jitpack.io")
        }
//        google()
//        mavenCentral()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}

include(":app")
