# Plugin for Apache Cordova

Official Jumio Mobile SDK plugin for Apache Cordova

This plugin is compatible with version 4.9.0 of the Jumio SDK.
If you have questions, please reach out to your Account Manager or contact [Jumio Support](#support).

# Table of Contents
- [Compatibility](#compatibility)
- [Setup](#setup)
- [Integration](#integration)
  - [iOS](#ios)
  - [Android](#android)
    - [Proguard](#proguard)
- [Usage](#usage)
- [Customization](#customization)
- [Configuration](#configuration)
- [Callbacks](#callbacks)
- [FAQ](#faq)
  - [Android Issues](#android-issues)
  - [iOS Issues](#ios-issues)
    - [Framework not found](#framework-not-found)
- [Support](#support)

## Compatibility
With this release, we only ensure compatibility with the latest Cordova versions and plugins.
At the time of this release, the following minimum versions are supported:
* Cordova: 12.0.0
* Cordova Android: 12.0.1
* Cordova iOS: 7.0.1

## Setup
Create Cordova project and add our plugin
```
cordova create MyProject com.my.project "MyProject"
cd MyProject
cordova platform add ios
cordova platform add android
cordova plugin add https://github.com/Jumio/mobile-cordova.git#v4.9.0
cd platforms/ios && pod install
```

## Integration

### iOS
Manual integration or dependency management via cocoapods possible, please see [the official documentation of the Jumio Mobile SDK for iOS](https://github.com/Jumio/mobile-sdk-ios/tree/master#basics)

#### NFC

Check out the [NFC setup guide](https://github.com/Jumio/mobile-sdk-ios/blob/master/docs/integration_guide.md#nfc-setup).

#### Digital Identity

Check out the [Digital Identity setup guide](https://github.com/Jumio/mobile-sdk-ios/blob/master/docs/integration_guide.md#digital-identity-setup).

#### Device Risk

To include Jumio's Device Risk functionality, you need to add `pod Jumio/DeviceRisk` to your Podfile.

### Android
Add required permissions for the products as described in chapter [Permissions](https://github.com/Jumio/mobile-sdk-android/blob/master/README.md#permissions)

To use the native Jumio Android component, your App needs to support AndroidX. This can be enabled by adding the following preference to your config.xml:

```xml
<preference name="AndroidXEnabled" value="true" />
```

#### Proguard  
For information on Android Proguard Rules concerning the Jumio SDK, please refer to our [Android Guides](https://github.com/Jumio/mobile-sdk-android#proguard).

For other build issues, refer to the The [FAQ section](#faq) at the bottom.

## Usage
1. To initialize the SDK, perform the following call.

```javascript
Jumio.initialize(<AUTHORIZATION_TOKEN>, <DATACENTER>);
```

Datacenter can either be **US**, **EU** or **SG**.

For more information about how to obtain an AUTHORIZATION_TOKEN, please refer to our [API Guide](https://jumio.github.io/kyx/integration-guide.html).

2. As soon as the SDK is initialized, the sdk is started by the following call.

```javascript
Jumio.start(successCallback, errorCallback);
```


## Customization
### Android
The JumioSDK colors can be customized by overriding the custom theme `AppThemeCustomJumio`. The styles-file for Android is automatically copied to your app by the rule in the `plugin.xml`. An example customization of all values that can be found in the [jumio-styles.xml of the plugin](src/android/res/values/jumio-styles.xml)

### iOS
JumioSDK iOS appearance can be customized to your respective needs. You can customize each color based on the device's set appearance, for either Dark mode or Light mode, or you can set a single color for both appearances. Customization is optional and not required.

You can pass the following customization options at [`Jumio.start`](demo/www/js/index.js#L40):

| Customization key                               |
|:------------------------------------------------|
| facePrimary                                     |
| faceSecondary                                   |
| faceOutline                                     |
| faceAnimationForeground                         |
| iProovFilterForegroundColor                     |
| iProovFilterBackgroundColor                     |
| iProovTitleTextColor                            |
| iProovCloseButtonTintColor                      |
| iProovSurroundColor                             |
| iProovPromptTextColor                           |
| iProovPromptBackgroundColor                     |
| genuinePresenceAssuranceReadyOvalStrokeColor    |
| genuinePresenceAssuranceNotReadyOvalStrokeColor |
| livenessAssuranceOvalStrokeColor                |
| livenessAssuranceCompletedOvalStrokeColor       |
| primaryButtonBackground                         |
| primaryButtonBackgroundPressed                  |
| primaryButtonBackgroundDisabled                 |
| primaryButtonForeground                         |
| primaryButtonForegroundPressed                  |
| primaryButtonForegroundDisabled                 |
| primaryButtonOutline                            |
| secondaryButtonBackground                       |
| secondaryButtonBackgroundPressed                |
| secondaryButtonBackgroundDisabled               |
| secondaryButtonForeground                       |
| secondaryButtonForegroundPressed                |
| secondaryButtonForegroundDisabled               |
| secondaryButtonOutline                          |
| bubbleBackground                                |
| bubbleForeground                                |
| bubbleBackgroundSelected                        |
| bubbleCircleItemForeground                      |
| bubbleCircleItemBackground                      |
| loadingCirclePlain                              |
| loadingCircleGradientStart                      |
| loadingCircleGradientEnd                        |
| loadingErrorCircleGradientStart                 |
| loadingErrorCircleGradientEnd                   |
| loadingCircleIcon                               |
| scanOverlay                                     |
| scanOverlayFill                                 |
| scanOverlayTransparent                          |
| scanOverlayBackground                           |
| nfcPassportCover                                |
| nfcPassportPageDark                             |
| nfcPassportPageLight                            |
| nfcPassportForeground                           |
| nfcPhoneCover                                   |
| scanViewBubbleForeground                        |
| scanViewBubbleBackground                        |
| scanViewForeground                              |
| scanViewDocumentShutter                         |
| scanViewFaceShutter                             |
| searchBubbleBackground                          |
| searchBubbleForeground                          |
| searchBubbleBackgroundSelected                  |
| searchBubbleOutline                             |
| confirmationImageBackground                     |
| confirmationImageBackgroundBorder               |
| confirmationIndicatorActive                     |
| confirmationIndicatorDefault                    |
| confirmationImageBorder                         | 
| background                                      |
| navigationIconColor                             |
| textForegroundColor                             |
| primaryColor                                    |
| selectionIconForeground                         |

All colors are provided with a HEX string with the following formats: `#ff00ff` or `#66ff00ff` if you want to set the alpha level.

**Customization example**

Example for setting color based on Dark or Light mode
```
Jumio.start(successCallback, errorCallback, {
    primaryColor: { light:"ffffff", dark:"000000" }
    primaryButtonBackground: { light:ffffff, dark:"000000" }
});
```

Example for setting same color for both Dark and Light mode
```
Jumio.start(successCallback, errorCallback, {
    primaryColor: "ffffff"
    primaryButtonBackground: "ffffff"
});
```

## Configuration
For more information about how to set specific SDK parameters (callbackUrl, userReference, country, ...), please refer to our [API Guide](https://jumio.github.io/kyx/integration-guide.html#request-body).

## Callback
To get information about callbacks, Netverify Retrieval API, Netverify Delete API and Global Netverify settings and more, please read our [page with server related information](https://jumio.github.io/kyx/integration-guide.html#callback).

## Result Objects
JumioSDK will return a JSONObject `documentData` with all  extracted data in case of a successfully completed workflow and `error` in case of error. An error object always includes an error code and an error message.

### Result

| Parameter               | Type     | Max. length | Description                                                                                                |
|:------------------------|:---------|:------------|:-----------------------------------------------------------------------------------------------------------|
| selectedCountry         | String   | 3           | [ISO 3166-1 alpha-3](http://en.wikipedia.org/wiki/ISO_3166-1_alpha-3) country code as provided or selected |
| selectedDocumentType    | String   | 16          | PASSPORT, DRIVER_LICENSE, IDENTITY_CARD or VISA                                                            |
| selectedDocumentSubType | String   |             | Sub type of the scanned ID                                                                                 |
| idNumber                | String   | 100         | Identification number of the document                                                                      |
| personalNumber          | String   | 14          | Personal number of the document                                                                            |
| issuingDate             | Date     |             | Date of issue                                                                                              |
| expiryDate              | Date     |             | Date of expiry                                                                                             |
| issuingCountry          | String   | 3           | Country of issue as ([ISO 3166-1 alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3)) country code  |
| lastName                | String   | 100         | Last name of the customer                                                                                  |
| firstName               | String   | 100         | First name of the customer                                                                                 |
| dob                     | Date     |             | Date of birth                                                                                              |
| gender                  | String   | 1           | m, f or x                                                                                                  |
| originatingCountry      | String   | 3           | Country of origin as ([ISO 3166-1 alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3)) country code |
| addressLine             | String   | 64          | Street name                                                                                                |
| city                    | String   | 64          | City                                                                                                       |
| subdivision             | String   | 3           | Last three characters of [ISO 3166-2:US](http://en.wikipedia.org/wiki/ISO_3166-2:US) state code            |
| postCode                | String   | 15          | Postal code                                                                                                |
| mrzData                 | MRZ-DATA |             | MRZ data, see table below                                                                                  |
| optionalData1           | String   | 50          | Optional field of MRZ line 1                                                                               |
| optionalData2           | String   | 50          | Optional field of MRZ line 2                                                                               |
| placeOfBirth            | String   | 255         | Place of Birth                                                                                             |

*MRZ-Data*

| Parameter           | Type   | Max. length | Description                                                                    |
|:--------------------|:-------|:------------|:-------------------------------------------------------------------------------|
| format              | String | 8           | MRP, TD1, TD2, CNIS, MRVA, MRVB or UNKNOWN                                     |
| line1               | String | 50          | MRZ line 1                                                                     |
| line2               | String | 50          | MRZ line 2                                                                     |
| line3               | String | 50          | MRZ line 3                                                                     |
| idNumberValid       | BOOL   |             | True if ID number check digit is valid, otherwise false                        |
| dobValid            | BOOL   |             | True if date of birth check digit is valid, otherwise false                    |
| expiryDateValid     | BOOL   |             | True if date of expiry check digit is valid or not available, otherwise false  |
| personalNumberValid | BOOL   |             | True if personal number check digit is valid or not available, otherwise false |
| compositeValid      | BOOL   |             | True if composite check digit is valid, otherwise false                        |


## Local Models for JumioDocfinder

If you are using our JumioDocFinder module, you can download our encrypted models and add them to your bundle from [here](https://cdn.mobile.jumio.ai/model/classifier_on_device_ep_99_float16_quant.enc) and [here](https://cdn.mobile.jumio.ai/model/normalized_ensemble_passports_v2_float16_quant.enc).

We recommend to download the files and add them to your project without changing their names (the same way you add Localization files). This will save two network requests on runtime to download these files.

### iOS

You also need to copy those files to the `ios/Assets` folder for Cordova to recognize them.

### Android

You need to copy those files to the assets folder of your Android project (Path: `app/src/main/assets/`)


# FAQ

## Android Issues
This is a list of common __Android build issues__ and how to resolve them:
* `AAPT: error: resource android:attr/lStar not found` is resolved [in this Stackoverflow post](https://stackoverflow.com/a/70492116/1297835)
* `Build-tool 32.0.0 is missing DX` (on Windows) -  [in this Stackoverflow post](https://stackoverflow.com/a/68430992/1297835)
* Gradle plugin 4.X not supported, please install 5.X    
	--> Change the version in the `gradle-wrapper.properties` file

* Device-ready not fired after X seconds    
  --> The plugin definition in "YOURPROJECT/platforms/android/platform_www/plugins/cordova-plugin-jumio-mobilesdk/www" might be duplicated/corrupted due to the issue mentioned [in this Stackoverflow post](https://stackoverflow.com/questions/28017540/cordova-plugin-javascript-gets-corrupted-when-added-to-project/28264312#28264312). Please fix the duplicated `cordova.define()` call in these files as mentioned in the post.

## iOS Issues

### iOS Simulator Shows a White Screen when Jumio SDK Starts
The Jumio SDK does not support the iOS Simulator. Please run the Jumio SDK only on physical devices.

### iOS Runs on Debug, Crashes on Release Build
This happens due to Xcode 13 introducing a new option to their __App Store Distribution Options__:

__"Manage Version and Build Number"__ (see image below)

If checked, this option changes the version and build number of all content of your app to the overall application version, including third-party frameworks. __This option is enabled by default.__ Please make sure to disable this option when archiving / exporting your application to the App Store. Otherwise, the Jumio SDK version check, which ensures all bundled frameworks are up to date, will fail.

![Xcode13 Issue](images/known_issues_xcode13.png)

Alternatively, it is also possible to set the key `manageAppVersionAndBuildNumber` in the __exportOptions.plist__ to `false`:
```
<key>manageAppVersionAndBuildNumber</key>
<false/>
```

### iOS Localization
After installing Cocoapods, please localize your iOS application using the languages provided at the following path:   
`ios -> Pods -> Jumio -> Localizations -> xx.lproj`

### Framework not found
If iOS application build is failing with `ld: framework not found DatadogCore.xcframework` or `dyld: Symbol not found: ... Referenced from: /.../Frameworks/DatadogCore.frameworks/DatadogCore`, please make sure the necessary post install-hook has been included in your `Podfile`:
```
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['iProov', 'DatadogRUM', 'DatadogCore', 'DatadogInternal'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
  end
end
```

For more information, please refer to our [iOS guides](https://github.com/Jumio/mobile-sdk-ios#certified-liveness-vendor).

# Support

## Contact
If you have any questions regarding our implementation guide please contact Jumio Customer Service at support@jumio.com or https://support.jumio.com. The Jumio online helpdesk contains a wealth of information regarding our service including demo videos, product descriptions, FAQs and other things that may help to get you started with Jumio. Check it out at: https://support.jumio.com.

## Licenses
The software contains third-party open source software. For more information, please see [Android licenses](https://github.com/Jumio/mobile-sdk-android/tree/master/licenses) and [iOS licenses](https://github.com/Jumio/mobile-sdk-ios/tree/master/licenses)

This software is based in part on the work of the Independent JPEG Group.

## Copyright

&copy; Jumio Corp. 268 Lambert Avenue, Palo Alto, CA 94306
