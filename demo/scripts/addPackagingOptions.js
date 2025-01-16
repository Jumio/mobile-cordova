const fs = require('fs');
const path = require('path');

module.exports = function (context) {
    const buildGradlePath = path.join('platforms', 'android', 'app', 'build.gradle');

    if (fs.existsSync(buildGradlePath)) {
        let buildGradleContents = fs.readFileSync(buildGradlePath, 'utf8');

        if (!buildGradleContents.includes('packagingOptions')) {
            buildGradleContents = insertPackagingOptions(buildGradleContents);
            fs.writeFileSync(buildGradlePath, buildGradleContents, 'utf8');
            console.log('Successfully added packagingOptions to build.gradle.');
        } else {
            console.log('packagingOptions already present in build.gradle.');
        }
    } else {
        console.log('build.gradle file not found.');
    }
};

function insertPackagingOptions(buildGradleContents) {
    const packagingOptionsBlock = `
    packagingOptions {
        resources.excludes.add("META-INF/versions/9/OSGI-INF/MANIFEST.MF")
        resources.excludes.add("META-INF/kotlin-project-structure-metadata.json")
        resources.excludes.add("META-INF/kotlinx_coroutines_core.version")
        resources.excludes.add("META-INF/LICENSE.md")
        resources.excludes.add("META-INF/LICENSE-notice.md")
        resources.excludes.add("commonMain/default/manifest")
        resources.excludes.add("commonMain/default/linkdata/module")
        resources.excludes.add("commonMain/default/linkdata/**/*.knm")
        resources.excludes.add("nativeMain/default/manifest")
        resources.excludes.add("nativeMain/default/linkdata/module")
        resources.excludes.add("nativeMain/default/linkdata/**/*.knm")
        resources.excludes.add("nonJvmMain/default/manifest")
        resources.excludes.add("nonJvmMain/default/linkdata/module")
        resources.excludes.add("nonJvmMain/default/linkdata/**/*.knm")
    }
    `;

    // Find the position of 'android {' and add packagingOptions there
    const androidBlockStart = buildGradleContents.indexOf('android {');
    if (androidBlockStart !== -1) {
        const insertPosition = androidBlockStart + 'android {'.length;
        return (
            buildGradleContents.slice(0, insertPosition) +
            '\n' +
            packagingOptionsBlock +
            buildGradleContents.slice(insertPosition)
        );
    }

    return buildGradleContents;
}