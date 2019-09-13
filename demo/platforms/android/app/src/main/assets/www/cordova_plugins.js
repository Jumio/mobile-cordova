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
  module.exports.metadata = {
    "cordova-plugin-jumio-mobilesdk": "3.3.0"
  };
});