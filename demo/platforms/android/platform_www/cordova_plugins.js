cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
  {
    "id": "cordova-plugin-jumio-mobilesdk.JumioMobileSDK",
    "file": "plugins/cordova-plugin-jumio-mobilesdk/www/JumioMobileSDK.js",
    "pluginId": "cordova-plugin-jumio-mobilesdk",
    "clobbers": [
      "Jumio"
    ]
  }
];
module.exports.metadata = 
// TOP OF METADATA
{
  "cordova-plugin-whitelist": "1.3.2",
  "cordova-plugin-cocoapod-support": "1.3.0",
  "cordova-plugin-jumio-mobilesdk": "2.9.0"
};
// BOTTOM OF METADATA
});