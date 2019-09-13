cordova.define("cordova-plugin-jumio-mobilesdk.JumioMobileSDK", function(require, exports, module) {
// var argscheck = require('cordova/argscheck');
// var channel = require('cordova/channel');
// var utils = require('cordova/utils');
var exec = require('cordova/exec');
// var cordova = require('cordova');

// channel.createSticky('onCordovaInfoReady');
// // Tell cordova channel to wait on the CordovaInfoReady event
// channel.waitForInitialization('onCordovaInfoReady');

/**
 * This represents the mobile device, and provides properties for inspecting the model, version, UUID of the
 * phone, etc.
 * @constructor
 */
function Jumio () {
	this.initNetverify = function(token, secret, datacenter, options, customization) {
		exec(function(success) { console.log("Netverify::init Success: " + success) }, 
			 function(error) { console.log("Netverify::init Error: " + error) },
			 "JumioMobileSDK", 
			 "initNetverify", 
			 [token, secret, datacenter, options, customization]);
	};
	
	this.startNetverify = function(success, error) {
		exec(success, error, "JumioMobileSDK", "startNetverify", []);
	};
	
	this.initAuthentication = function(token, secret, datacenter, options) {
		exec(function(success) { console.log("Authentication::init Success: " + success) },
			 function(error) { console.log("Authentication::init Error: " + error) },
			 "JumioMobileSDK",
			 "initAuthentication",
			 [token, secret, datacenter, options]);
	};
	
	
	this.startAuthentication = function(success, error) {
		exec(success, error, "JumioMobileSDK", "startAuthentication", []);
	};
	
	this.initBAM = function(token, secret, datacenter, options, customization) {
		exec(function(success) { console.log("BAM::init Success: " + success) }, 
			 function(error) { console.log("BAM::init Error: " + error) },
			 "JumioMobileSDK", 
			 "initBAM", 
			 [token, secret, datacenter, options, customization]);
	};
	
	this.startBAM = function(success, error) {
		exec(success, error, "JumioMobileSDK", "startBAM", []);
	};
	
	this.initDocumentVerification = function(token, secret, datacenter, options, customization) {
		exec(function(success) { console.log("DocumentVerification::init Success: " + success) }, 
			 function(error) { console.log("DocumentVerification::init Error: " + error) },
			 "JumioMobileSDK", 
			 "initDocumentVerification", 
			 [token, secret, datacenter, options, customization]);
	};
	
	this.startDocumentVerification = function(success, error) {
		exec(success, error, "JumioMobileSDK", "startDocumentVerification", []);
	};
}

// /**
//  * Get device info
//  *
//  * @param {Function} successCallback The function to call when the heading data is available
//  * @param {Function} errorCallback The function to call when there is an error getting the heading data. (OPTIONAL)
//  */
// Device.prototype.getInfo = function (successCallback, errorCallback) {
//     argscheck.checkArgs('fF', 'Device.getInfo', arguments);
//     exec(successCallback, errorCallback, 'Device', 'getDeviceInfo', []);
// };

module.exports = new Jumio();
});
