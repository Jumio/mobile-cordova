cordova.define("cordova-plugin-jumio-mobilesdk.JumioMobileSDK", function(require, exports, module) {
var exec = require('cordova/exec');

exports.initNetverify = function(token, secret, datacenter, options, customization) {
    exec(function(success) { console.log("Netverify::init Success: " + success) }, 
		 function(error) { console.log("Netverify::init Error: " + error) },
		 "JumioMobileSDK", 
		 "initNetverify", 
		 [token, secret, datacenter, options, customization]);
};

exports.startNetverify = function(success, error) {
    exec(success, error, "JumioMobileSDK", "startNetverify", []);
};

exports.initBAM = function(token, secret, datacenter, options, customization) {
    exec(function(success) { console.log("BAM::init Success: " + success) }, 
		 function(error) { console.log("BAM::init Error: " + error) },
		 "JumioMobileSDK", 
		 "initBAM", 
		 [token, secret, datacenter, options, customization]);
};

exports.startBAM = function(success, error) {
    exec(success, error, "JumioMobileSDK", "startBAM", []);
};

exports.initDocumentVerification = function(token, secret, datacenter, options, customization) {
    exec(function(success) { console.log("DocumentVerification::init Success: " + success) }, 
		 function(error) { console.log("DocumentVerification::init Error: " + error) },
		 "JumioMobileSDK", 
		 "initDocumentVerification", 
		 [token, secret, datacenter, options, customization]);
};

exports.startDocumentVerification = function(success, error) {
    exec(success, error, "JumioMobileSDK", "startDocumentVerification", []);
};
});
