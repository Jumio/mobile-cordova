# Cordova Demo-App
Demonstrates how to use the JumioMobileSDK plugin.

## Prerequisites

* Cordova CLI 12.0.0
* NodeJS 21.6.2

## Hooks

### iOS specific hook

To build and run the iOS app, you need to add a hook in the `config.xml` iOS platform, which extends the generated Podfile. This script is located in the `scripts` folder, called `podEdit.js`, along with the extension, `podExtension`, that is copied to the Podfile.

### Android specific hook

Currently Cordova Android doesn't support API 34, breaking the run application command for Android. To remedy this, we need the add a `after_platform_add` hook in the `config.xml` Android platform section, to modify the Java version of the build gradle. This script is located in the `scripts` folder, called `buildGradleEdit.js`.

## Usage
```
cordova plugin add --link ../
cordova platform add android && cordova prepare android
cordova platform add ios && cordova prepare ios && cd platforms/ios && pod install
```
**_DISCLAIMER:_** The 'add platform' and 'prepare' commands need to be called separately due to cordova limitations.

## Run the application
```
cordova run android
# OR
cordova run ios
```