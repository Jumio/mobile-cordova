# Plugin for Apache Cordova

Official Jumio Mobile SDK plugin for Apache Cordova

This plugin is compatible with version 2.12.0 of the Jumio SDK. This is the final update to the Cordova plugin — future SDK compatibility can not be guaranteed. If you have questions, please reach out to your Account Manager or contact Jumio Support at support@jumio.com or https://support.jumio.com 

## Compatibility
With this release, we only ensure compatibility with the latest Cordova versions and plugins.
At the time of this release, the following minimum versions are supported:
* Cordova: 7.1.0
* Cordova Android: 6.4.0
* Cordova iOS: 4.5.3

## Setup

Create Cordova project and add our plugin
```
cordova create MyProject com.my.project "MyProject"
cd MyProject
cordova platform add ios
cordova platform add android
cordova plugin add https://github.com/Jumio/mobile-cordova.git#v2.12.0
```

## Integration

### iOS

Manual integration or dependency management via cocoapods possible, please see [the official documentation of the Jumio Mobile SDK for iOS](https://github.com/Jumio/mobile-sdk-ios/tree/v2.12.0#basic-setup)

### Android

Add the Jumio repository:

```
repositories {
    maven { url 'http://mobile-sdk.jumio.com' }
    maven { url 'https://maven.google.com/' }
}
```

Add a parameter for your SDK_VERSION into the ext-section:

```
ext {
    SDK_VERSION = "2.12.0"
}
```

Add required permissions for the products as described in chapter [Permissions](https://github.com/Jumio/mobile-sdk-android/blob/v2.12.0/README.md#permissions)

Open the android project of your cordova project located in */platforms/android* and insert the dependencies from the products you require to your **build.gradle** file. (Module: android)

* [Netverify & Fastfill](https://github.com/Jumio/mobile-sdk-android/blob/v2.12.0/docs/integration_netverify-fastfill.md#dependencies)
* [Document Verification](https://github.com/Jumio/mobile-sdk-android/blob/v2.12.0/docs/integration_document-verification.md#dependencies)
* [BAM Checkout](https://github.com/Jumio/mobile-sdk-android/blob/v2.12.0/docs/integration_bam-checkout.md#dependencies)

__Note:__ If you are using Netverify, make sure to add the Google vision meta-data to you **AndroidManifest.xml** accordingly:

```
<meta-data
			android:name="com.google.android.gms.vision.DEPENDENCIES"
			android:value="barcode, face"
			tools:replace="android:value"/>
```

## Usage

### Netverify / Fastfill

To initialize the SDK, perform the following call.

```javascript
Jumio.initNetverify(<API_TOKEN>, <API_SECRET>, <DATACENTER>, {configuration});
```

Datacenter can either be **US** or **EU**.



Configure the SDK with the *configuration*-Object.

| Configuration | Datatype | Description |
| ------ | -------- | ----------- |
| requireVerification | Boolean | Enable ID verification |
| callbackUrl | String | Specify an URL for individual transactions |
| requireFaceMatch | Boolean | Enable face match during the ID verification for a specific transaction |
| preselectedCountry | Boolean | Specify the issuing country (ISO 3166-1 alpha-3 country code) |
| merchantScanReference | String | Allows you to identify the scan (max. 100 characters) |
| merchantReportingCriteria | String | Use this option to identify the scan in your reports (max. 100 characters) |
| customerId | String | Set a customer identifier (max. 100 characters) |
| sendDebugInfoToJumio | Boolean | Send debug information to Jumio. |
| dataExtractionOnMobileOnly | Boolean | Limit data extraction to be done on device only |
| cameraPosition | String | Which camera is used by default. Can be **FRONT** or **BACK**. |
| preselectedDocumentVariant | String | Which types of document variants are available. Can be **PAPER** or **PLASTIC** |
| documentTypes | String-Array | An array of accepted document types: Available document types: **PASSPORT**, **DRIVER_LICENSE**, **IDENTITY_CARD**, **VISA** |


Initialization example with configuration.

```javascript
Jumio.initNetverify("API_TOKEN", "API_SECRET", "US", {
    requireVerification: false,
    customerId: "CUSTOMERID",
    preselectedCountry: "USA",
    cameraPosition: "BACK",
    documentTypes: ["DRIVER_LICENSE", "PASSPORT", "IDENTITY_CARD", "VISA"]
});
```

***Android eMRTD scanning***

If you are using eMRTD scanning, following lines are needed in your Manifest file:

```javascript
-keep class net.sf.scuba.smartcards.IsoDepCardService {*;}
-keep class org.jmrtd.** { *; }
-keep class net.sf.scuba.** {*;}
-keep class org.spongycastle.** {*;}
-keep class org.ejbca.** {*;}

-dontwarn java.nio.**
-dontwarn org.codehaus.**
-dontwarn org.ejbca.**
-dontwarn org.spongycastle.**
```

Add the needed dependencies following [this chapter](https://github.com/Jumio/mobile-sdk-android/blob/master/docs/integration_netverify-fastfill.md#dependencies) of the android integration guide.

Enable eMRTD by using the following method in your native android code:

```javascript
netverifySDK.setEnableEMRTD(true);
```


As soon as the sdk is initialized, the sdk is started by the following call.

```javascript
Jumio.startNetverify(successCallback, errorCallback);
```

Example

```javascript
Jumio.startNetverify(function(documentData) {
    // YOUR CODE
}, function(error) {
    // YOUR CODE
});
```

### Document Verification

To initialize the SDK, perform the following call.

```javascript
Jumio.initDocumentVerification(<API_TOKEN>, <API_SECRET>, <DATACENTER>, {configuration});
```

Datacenter can either be **US** or **EU**.

Configure the SDK with the *configuration*-Object. **(configuration marked with * are mandatory)**

| Configuration | Datatype | Description |
| ------ | -------- | ----------- |
| **type*** | String | See the list below |
| **customerId*** | String | Set a customer identifier (max. 100 characters) |
| **country*** | String | Set the country (ISO-3166-1 alpha-3 code) |
| **merchantScanReference*** | String | Allows you to identify the scan (max. 100 characters) |
| merchantReportingCriteria | String | Use this option to identify the scan in your reports (max. 100 characters) |
| callbackUrl | String | Specify an URL for individual transactions |
| documentName | String | Override the document label on the help screen |
| customDocumentCode | String | Set your custom document code (set in the merchant backend under "Settings" - "Multi Documents" - "Custom" |
| cameraPosition | String | Which camera is used by default. Can be **FRONT** or **BACK**. |
| enableExtraction | bool | Enable/disable data extraction for documents. |

Possible types:

*  BS (Bank statement)
*  IC (Insurance card)
*  UB (Utility bill, front side)
*  CAAP (Cash advance application)
*  CRC (Corporate resolution certificate)
*  CCS (Credit card statement)
*  LAG (Lease agreement)
*  LOAP (Loan application)
*  MOAP (Mortgage application)
*  TR (Tax return)
*  VT (Vehicle title)
*  VC (Voided check)
*  STUC (Student card)
*  HCC (Health care card)
*  CB (Council bill)
*  SENC (Seniors card)
*  MEDC (Medicare card)
*  BC (Birth certificate)
*  WWCC (Working with children check)
*  SS (Superannuation statement)
*  TAC (Trade association card)
*  SEL (School enrolment letter)
*  PB (Phone bill)
*  USSS (US social security card)
*  SSC (Social security card)
*  CUSTOM (Custom document type)

Initialization example with configuration.

```javascript
Jumio.initDocumentVerification("API_TOKEN", "API_SECRET", "US", {
    type: "BC",
    customerId: "CUSTOMER ID",
    country: "USA",
    merchantScanReference: "YOURSCANREFERENCE",
    cameraPosition: "BACK"
});
```

As soon as the SDK is initialized, the SDK is started by the following call.

```javascript
Jumio.startDocumentVerification(successCallback, errorCallback);
```

Example

```javascript
Jumio.startDocumentVerification(function(documentData) {
    // YOUR CODE
}, function(error) {
    // YOUR CODE
});
```

### BAM Checkout

To Initialize the SDK, perform the following call.

```javascript
Jumio.initBAM(<API_TOKEN>, <API_SECRET>, <DATACENTER>, {configuration});
```

Datacenter can either be **US** or **EU**.



Configure the SDK with the *configuration*-Object.

| Configuration | Datatype | Description |
| ------ | -------- | ----------- |
| cardHolderNameRequired | Boolean |
| sortCodeAndAccountNumberRequired | Boolean |
| expiryRequired | Boolean |
| cvvRequired | Boolean |
| expiryEditable | Boolean |
| cardHolderNameEditable | Boolean |
| merchantReportingCriteria | String | Overwrite your specified reporting criteria to identify each scan attempt in your reports (max. 100 characters)
| vibrationEffectEnabled | Boolean |
| enableFlashOnScanStart | Boolean |
| cardNumberMaskingEnabled | Boolean |
| offlineToken | String | In your Jumio merchant backend on the "Settings" page under "API credentials" you can find your Offline token. In case you use your offline token, you must not set the API token and secret|
| cameraPosition | String | Which camera is used by default. Can be **FRONT** or **BACK**. |
| cardTypes | String-Array | An array of accepted card types. Available card types: **VISA**, **MASTER_CARD**, **AMERICAN_EXPRESS**, **CHINA_UNIONPAY**, **DINERS_CLUB**, **DISCOVER**, **JCB** |

Initialization example with configuration.

```javascript
Jumio.initBAM("API_TOKEN", "API_SECRET", "US", {
    cardHolderNameRequired: false,
    cvvRequired: true,
    cameraPosition: "BACK",
    cardTypes: ["VISA", "MASTER_CARD"]
});
```


As soon as the sdk is initialized, the sdk is started by the following call.

```javascript
Jumio.startBAM(successCallback, errorCallback);
```

Example

```javascript
Jumio.startBAM(function(cardInformation) {
    // YOUR CODE
}, function(error) {
    // YOUR CODE
});
```

## Customization

### Android

#### Netverify
The Netverify SDK can be customized to the respective needs by following this [customization chapter](https://github.com/Jumio/mobile-sdk-android/blob/v2.12.0/docs/integration_netverify-fastfill.md#customization).

#### BAM Checkout
The Netverify SDK can be customized to the respective needs by following this [customization chapter](https://github.com/Jumio/mobile-sdk-android/blob/v2.12.0/docs/integration_bam-checkout.md#customization).

#### Document Verification
The Netverify SDK can be customized to the respective needs by following this [customization chapter](https://github.com/Jumio/mobile-sdk-android/blob/v2.12.0/docs/integration_document-verification.md#customization).

### iOS
The SDK can be customized to the respective needs. You can pass the following customization options to the initializer:

| Customization key | Type | Description |
|:------------------|:-----|:------------|
| disableBlur       | BOOL | Deactivate the blur effect |
| backgroundColor   | STRING | Change base view's background color |
| foregroundColor   | STRING | Change base view's foreground color |
| tintColor         | STRING | Change the tint color of the navigation bar |
| barTintColor      | STRING | Change the bar tint color of the navigation bar |
| textTitleColor    | STRING | Change the text title color of the navigation bar |
| documentSelectionHeaderBackgroundColor | STRING | Change the background color of the document selection header |
| documentSelectionHeaderTitleColor | STRING | Change the title color of the document selection header |
| documentSelectionHeaderIconColor | STRING | Change the icon color of the document selection header |
| documentSelectionButtonBackgroundColor | STRING | Change the background color of the document selection button |
| documentSelectionButtonTitleColor | STRING | Change the title color of the document selection button |
| documentSelectionButtonIconColor | STRING | Change the icon color of the document selection button |
| fallbackButtonBackgroundColor | STRING | Change the background color of the fallback button |
| fallbackButtonBorderColor | STRING | Change the border color of the fallback button |
| fallbackButtonTitleColor | STRING | Change the title color of the fallback button |
| positiveButtonBackgroundColor | STRING | Change the background color of the positive button |
| positiveButtonBorderColor | STRING | Change the border color of the positive button |
| positiveButtonTitleColor | STRING | Change the title color of the positive button |
| negativeButtonBackgroundColor | STRING | Change the background color of the negative button |
| negativeButtonBorderColor | STRING | Change the border color of the negative button |
| negativeButtonTitleColor | STRING | Change the title color of the negative button |
| scanOverlayStandardColor (NV only) | STRING | Change the standard color of the scan overlay |
| scanOverlayValidColor (NV only) | STRING | Change the valid color of the scan overlay |
| scanOverlayInvalidColor (NV only) | STRING | Change the invalid color of the scan overlay |
| scanOverlayTextColor (BAM only) | STRING | Change the text color of the scan overlay |
| scanOverlayBorderColor (BAM only) | STRING | Change the border color of the scan overlay |

All colors are provided with a HEX string with the following format: #ff00ff.

**Customization example**
```javascript
Jumio.initNetverify("API_TOKEN", "API_SECRET", "US", {
    requireVerification: false,
    ...
}, {
    disableBlur: true,
    backgroundColor: "#ff00ff",
    barTintColor: "#ff1298"
);
```

## Callback

To get information about callbacks, Netverify Retrieval API, Netverify Delete API and Global Netverify settings and more, please read our [page with server related information](https://github.com/Jumio/implementation-guides/blob/master/netverify/callback.md).

The JSONObject with all the extracted data that is returned for the specific products is described in the following subchapters:

### Netverify & Fastfill

*NetverifyDocumentData:*

| Parameter | Type | Max. length | Description  |
|:-------------------|:----------- 	|:-------------|:-----------------|
| selectedCountry | String| 3| [ISO 3166-1 alpha-3](http://en.wikipedia.org/wiki/ISO_3166-1_alpha-3) country code as provided or selected |
| selectedDocumentType | String | 16| PASSPORT, DRIVER_LICENSE, IDENTITY_CARD or VISA |
| idNumber | String | 100 | Identification number of the document |
| personalNumber | String | 14| Personal number of the document|
| issuingDate | Date | | Date of issue |
| expiryDate | Date | | Date of expiry |
| issuingCountry | String | 3 | Country of issue as ([ISO 3166-1 alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3)) country code |
| lastName | String | 100 | Last name of the customer|
| firstName | String | 100 | First name of the customer|
| middleName | String | 100 | Middle name of the customer |
| dob | Date | | Date of birth |
| gender | String | 1| m, f or x |
| originatingCountry | String | 3|Country of origin as ([ISO 3166-1 alpha-3](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3)) country code |
| addressLine | String | 64 | Street name	|
| city | String | 64 | City |
| subdivision | String | 3 | Last three characters of [ISO 3166-2:US](http://en.wikipedia.org/wiki/ISO_3166-2:US) state code	|
| postCode | String | 15 | Postal code |
| mrzData |  MRZ-DATA | | MRZ data, see table below |
| optionalData1 | String | 50 | Optional field of MRZ line 1 |
| optionalData2 | String | 50 | Optional field of MRZ line 2 |
| placeOfBirth | String | 255 | Place of Birth |
| extractionMethod | String | 12| MRZ, OCR, BARCODE, BARCODE_OCR or NONE |

*MRZ-Data*

| Parameter |Type | Max. length | Description |
|:---------------|:------------- |:-------------|:-----------------|
| format | String |  8| MRP, TD1, TD2, CNIS, MRVA, MRVB or UNKNOWN |
| line1 | String | 50 | MRZ line 1 |
| line2 | String | 50 | MRZ line 2 |
| line3 | String | 50| MRZ line 3 |
| idNumberValid | BOOL| | True if ID number check digit is valid, otherwise false |
| dobValid | BOOL | | True if date of birth check digit is valid, otherwise false |
| expiryDateValid |	BOOL| |	True if date of expiry check digit is valid or not available, otherwise false|
| personalNumberValid | BOOL | | True if personal number check digit is valid or not available, otherwise false |
| compositeValid | BOOL | | True if composite check digit is valid, otherwise false |

### BAM Checkout

*BAMCardInformation*

|Parameter | Type | Max. length | Description |
|:---------------------------- 	|:-------------|:-----------------|:-------------|
| cardType | String |  16| VISA, MASTER_CARD, AMERICAN_EXPRESS, CHINA_UNIONPAY, DINERS_CLUB, DISCOVER, JCB or STARBUCKS |
| cardNumber | String | 16 | Full credit card number |
| cardNumberGrouped | String | 19 | Grouped credit card number |
| cardNumberMasked | String | 19 | First 6 and last 4 digits of the grouped credit card number, other digits are masked with "X" |
| cardExpiryMonth | String | 2 | Month card expires if enabled and readable |
| CardExpiryYear | String | 2 | Year card expires if enabled and readable |
| cardExpiryDate | String | 5 | Date card expires in the format MM/yy if enabled and readable |
| cardCVV | String | 4 | Entered CVV if enabled |
| cardHolderName | String | 100 | Name of the card holder in capital letters if enabled and readable, or as entered if editable |
| cardSortCode | String | 8 | Sort code in the format xx-xx-xx or xxxxxx if enabled, available and readable |
| cardAccountNumber | String | 8 | Account number if enabled, available and readable |
| cardSortCodeValid | BOOL |  | True if sort code valid, otherwise false |
| cardAccountNumberValid | BOOL |  | True if account number code valid, otherwise false |

### Document Verification

No data returned.

# Support

## Contact

If you have any questions regarding our implementation guide please contact Jumio Customer Service at support@jumio.com or https://support.jumio.com. The Jumio online helpdesk contains a wealth of information regarding our service including demo videos, product descriptions, FAQs and other things that may help to get you started with Jumio. Check it out at: https://support.jumio.com.

## Copyright

&copy; Jumio Corp. 268 Lambert Avenue, Palo Alto, CA 94306
