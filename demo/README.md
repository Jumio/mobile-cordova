# Cordova Demo-App
Demonstrates how to use the JumioMobileSDK plugin.

## Prerequisites

* Cordova CLI 12.0.0
* NodeJS 20.5.1

## Usage

Add your data center in `www/js/index.js` and run the following commands:

```
cordova plugin add --link ../
cordova prepare
cd platforms/ios && pod install
```

### iOS-specific

To build and run the iOS app, you need to add two hooks in the `config.xml`, which extends the generated Podfile. We use the same script for both hooks, and it's located in the `scripts` folder, called `podEdit.js`, along with the extension, `podExtension`, that is copied to the Podfile. 

## Run the application
```
cordova run android
# OR
cordova run ios
```
