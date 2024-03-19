#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Path to the build.gradle file
const buildGradlePath = path.join('platforms', 'android', 'app', 'build.gradle');

try {
    // Read the contents of the build.gradle file
    let buildGradleContents = fs.readFileSync(buildGradlePath, 'utf8');

    // Modify compileOptions in build.gradle
    buildGradleContents = buildGradleContents.replace(
        /compileOptions\s*{\s*[^{}]*\s*}/,
        `compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }`
    );

    // Write the updated contents back to the build.gradle file
    fs.writeFileSync(buildGradlePath, buildGradleContents, 'utf8');

    console.log('compileOptions updated successfully in build.gradle');
} catch (err) {
    console.error('An error occurred while updating build.gradle:', err);
}