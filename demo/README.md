# Cordova Demo-App
Demonstrates how to use the JumioMobileSDK plugin.

## Prerequisites

* Cordova CLI 10.0.0
* NodeJS 14.17.0

## Usage

Update your SDK credentials in `www/js/index.js` and run the following commands:

```
cordova plugin add --link ../
cordova prepare
```
### Android-specific

Navigate to `platforms/android/build.gradle` and replace the generated buildscript with the following:

```
buildscript {
    ext.kotlin_version = '1.4.30'
    repositories {
        google()
        jcenter()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:4.1.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}
```

Navigate to `platforms/android/gradle.properties` and add the following line:

```
android.jetifier.blacklist=bcprov-jdk15on
```

### iOS-specific

In the project root folder create a build.json file and add the following:

```
{
  "ios": {
    "debug": {
      "buildFlag": [
        "BUILD_LIBRARY_FOR_DISTRIBUTION=YES"
      ]
    },
    "release": {
      "buildFlag": [
        "BUILD_LIBRARY_FOR_DISTRIBUTION=YES"
      ]
    }
  }
}
```

## Run the application
```
cordova run android
# OR
cordova run ios
```
