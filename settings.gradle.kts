rootProject.name = "outai-sandbox-java"

pluginManagement {
    repositories {
        mavenCentral()
        gradlePluginPortal()
        System
            // This is a little best practice I have in my projects:
            //   Instead of accidentally leaving mavenLocal() enabled,
            //   we require it to be explicitly enabled via an environment variable.
            .getenv("ENABLE_LOCAL_MAVEN")
            ?.apply { if (toBoolean()) mavenLocal() }
    }
}

dependencyResolutionManagement {
    @Suppress("UnstableApiUsage")
    repositories {
        mavenCentral()
        System
            .getenv("ENABLE_LOCAL_MAVEN")
            ?.apply { if (toBoolean()) mavenLocal() }
    }

    versionCatalogs {
        create("libs") {
            val junit5Version = version("junit5", "5.11.3")
            val junitPlatformLauncherVersion = version("junitPlatformLauncherVersion", "1.11.3")
            val mockitoVersion = version("mockito", "5.14.0")
            val restAssuredVersion = version("restAssured", "5.5.0")
            val hamcrestVersion = version("hamcrest", "3.0")
            val spotlessVersion = version("spotless", "6.25.0")
            val wiremockVersion = version("wiremock", "3.9.1")
            val sonarlintVersion = version("sonarlint", "2.1.0")

            plugin("spotless", "com.diffplug.spotless").versionRef(spotlessVersion)
            plugin("sonarlint", "se.solrike.sonarlint").versionRef(sonarlintVersion)

            library("junit-jupiter", "org.junit.jupiter", "junit-jupiter").versionRef(junit5Version)
            library("junit-platform-launcher", "org.junit.platform", "junit-platform-launcher").versionRef(junitPlatformLauncherVersion)
            library("wiremock", "org.wiremock", "wiremock").versionRef(wiremockVersion)
            library("rest-assured", "io.rest-assured", "rest-assured").versionRef(restAssuredVersion)
            library("mockito-core", "org.mockito", "mockito-core").versionRef(mockitoVersion)
            library("mockito-junit-jupiter", "org.mockito", "mockito-junit-jupiter").versionRef(mockitoVersion)
            library("hamcrest", "org.hamcrest", "hamcrest").versionRef(hamcrestVersion)
        }
    }
}
