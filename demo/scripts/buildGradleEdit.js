#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Path to the build.gradle file
const buildGradlePath = path.join('platforms', 'android', 'app', 'build.gradle');
const gradlePropertiesPath = path.join('platforms', 'android', 'gradle.properties');

try {
    // Read the contents of the build.gradle file
    let buildGradleContents = fs.readFileSync(buildGradlePath, 'utf8');

    // Modify compileOptions in build.gradle
    buildGradleContents = buildGradleContents.replace(
        /compileOptions\s*{\s*[^{}]*\s*}/,
        `compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
        }
        kotlinOptions {
            jvmTarget = JavaVersion.VERSION_17
        }
        kotlin {
            jvmToolchain(17)
        }
        java {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }`
    );

    // Read the contents of the gradle.properties file
    let gradlePropertiesContents = fs.readFileSync(gradlePropertiesPath, 'utf8');

    // Ignore JVM target validation
    gradlePropertiesContents += '\n';
    gradlePropertiesContents += 'kotlin.jvm.target.validation.mode=WARNING\n';

    // Write update contents back to gradle.properties file
    fs.writeFileSync(gradlePropertiesPath, gradlePropertiesContents, 'utf8');

    console.log('compileOptions updated successfully in build.gradle');
} catch (err) {
    console.error('An error occurred while updating build.gradle:', err);
}