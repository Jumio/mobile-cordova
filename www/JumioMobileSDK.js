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
	this.initialize = function(authorizationToken, datacenter) {
    	exec(function(success) { console.log("Jumio::init Success: " + success) },
            function(error) { console.log("Jumio::init Error: " + JSON.stringify(error)) },
    		"JumioMobileSDK",
    		"initialize",
    		[authorizationToken, datacenter]);
    };
	
	this.start = function(success, error) {
		exec(success, error, "JumioMobileSDK", "start", []);
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