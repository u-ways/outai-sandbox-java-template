//import org.jetbrains.kotlin.gradle.dsl.JvmTarget
//import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    java
//    alias(libs.plugins.spotless)
//    alias(libs.plugins.sonarlint)
//    alias(libs.plugins.jetbrains.kotlin.jvm)
}

group = "outai.sandbox"
version = "DEV-SNAPSHOT"

dependencies {
//    implementation(libs.kotlin.reflect)

//    testImplementation(libs.mockk.core)
//    testImplementation(libs.kotest.runner.junit5)
//    testImplementation(libs.kotest.assertions.core)

    testImplementation(libs.junit.jupiter)
    testImplementation(libs.mockito.junit.jupiter)
    testImplementation(libs.mockito.core)
    testImplementation(libs.hamcrest)
//    testImplementation(libs.wiremock)
//    testImplementation(libs.rest.assured)

    testRuntimeOnly(libs.junit.platform.launcher)
}

java {
    sourceCompatibility = JavaVersion.VERSION_18
    targetCompatibility = JavaVersion.VERSION_18
}

tasks {
//    withType<KotlinCompile> {
//        compilerOptions {
//            freeCompilerArgs.add("-Xjsr305=strict")
//            jvmTarget.set(JvmTarget.JVM_18)
//        }
//    }

    withType<Test> {
        useJUnitPlatform()
        jvmArgs(
            // Required to suppress Byte Buddy agent warnings.
            // see: https://openjdk.org/jeps/451
            "-XX:+EnableDynamicAgentLoading",
            // Explicitly disable class data sharing.
            // see: https://stackoverflow.com/a/57957031/5037430
            "-Xshare:off",
        )
        testLogging {
            events("passed", "skipped", "failed")
        }
    }

    withType<JavaCompile> {
        options.encoding = "UTF-8"
        options.compilerArgs.add("-parameters")
    }

    wrapper {
        distributionType = Wrapper.DistributionType.ALL
    }
}

//spotless {
//    java {
//        importOrder()
//        removeUnusedImports()
//        palantirJavaFormat()
//    }
//}
//
//sonarlint {
//    maxIssues.set(0)
//    showIssues.set(true)
//    ignoreFailures.set(false)
//    reports { create("html") { enabled.set(true) } }
//    /**
//     * Rules are described here:
//     * - https://rules.sonarsource.com/java/
//     *
//     * You can quickly search for a rule by its key, e.g. for `java:S1186`:
//     * - https://rules.sonarsource.com/java/RSPEC-1186
//     *
//     * Note that some rules are for SonarQube or SonarCloud only.
//     *
//     * In a real-world project, you would want to enable more rules or
//     * create more tailored profiles for your project.
//     */
//    includeRules.addAll(
//        "java:S1186",
//        "java:S1190",
//    )
//}