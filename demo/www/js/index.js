/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

const API_TOKEN = 'YOUR_API_KEY';
const API_SECRET = 'YOUR_API_SECRET';
const DATACENTER = 'YOUR_DATACENTER';
const BAM_API_TOKEN = 'YOUR_BAM_API_TOKEN';
const BAM_API_SECRET = 'YOUR_BAM_API_SECRET';
const BAM_DATACENTER = 'YOUR_BAME_DATACENTER';

var app = {
    // Application Constructor
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
		document.getElementById("startNetverify").addEventListener("click", this.startNetverify);
		document.getElementById("startBAM").addEventListener("click", this.startBAM);
		document.getElementById("startDocumentVerification").addEventListener("click", this.startDocumentVerification);
		document.getElementById("startSingleSessionNetverify").addEventListener("click", this.startSingleSessionNetverify);
		document.getElementById("log").addEventListener("change",function unhide() {
			document.getElementById("logtitle").hidden = true
		})			
    },

    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
    onDeviceReady: function() {
		
	},

	startNetverify: function() {
		// Netverify / Fastfill
		Jumio.initNetverify(API_TOKEN, API_SECRET, DATACENTER, {
			enableVerification: true,
			//callbackUrl: "URL",
			//enableIdentityVerification: true,
			//preselectedCountry: "AUT",
			//customerInternalReference: "CustomerInternalReference",
			//reportingCriteria: "ReportingCriteria",
			//userReference: "UserReference",
			//sendDebugInfoToJumio: true,
			//dataExtractionOnMobileOnly: false,
			//cameraPosition: "back",
			//preselectedDocumentVariant: "plastic",
			//documentTypes: ["PASSPORT", "DRIVER_LICENSE", "IDENTITY_CARD", "VISA"],
			//enableWatchlistScreening: ["enabled", "disabled" || "default"],
			//watchlistSearchProfile: "YOURPROFILENAME"
            //offlineToken: ""
		}, {
			// Customization iOS only
			//disableBlur: true,
			//enableDarkMode: true,
			//backgroundColor: "#ff0000",
			//foregroundColor: "#ff0000",
			//tintColor: "#ff0000",
			//barTintColor: "#ff0000",
			//textTitleColor: "#ff0000",
            //documentSelectionHeaderBackgroundColor: "#ff0000",
            //documentSelectionHeaderTitleColor: "#ff0000",
            //documentSelectionHeaderIconColor: "#ff0000",
            //documentSelectionButtonBackgroundColor: "#ff0000",
            //documentSelectionButtonTitleColor: "#ff0000",
            //documentSelectionButtonIconColor: "#ff0000",
			//fallbackButtonBackgroundColor: "#ff0000",
			//fallbackButtonBorderColor: "#ff0000",
			//fallbackButtonTitleColor: "#ff0000",
			//positiveButtonBackgroundColor: "#ff0000",
			//positiveButtonBorderColor: "#ff0000",
			//positiveButtonTitleColor: "#ff0000",
			//negativeButtonBackgroundColor: "#ff0000",
			//negativeButtonBorderColor: "#ff0000",
			//negativeButtonTitleColor: "#ff0000",
			//scanOverlayStandardColor: "#ff0000",
			//scanOverlayValidColor: "#ff0000",
			//scanOverlayInvalidColor: "#ff0000",
			//scanBackgroundColor: "#ff0000",
			//iProovHeaderTextColor: "#ff0000",
			//iProovHeaderBackgroundColor: "#ff0000",
			//iProovCloseButtonTintColor: "#ff0000",
			//iProovFooterTextColor: "#ff0000",
			//iProovFooterBackgroundColor: "#ff0000",
            //iProovLivenessScanningTintColor: "#ff0000",
            //iProovProgressBarColor: "#ff0000"
		});

		Jumio.startNetverify(function(documentData) {
			// alert(JSON.stringify(documentData));
			document.getElementById("log").textContent = JSON.stringify(documentData);
		}, function(error) {
			// alert(JSON.stringify(error));
			document.getElementById("log").textContent = JSON.stringify(error);
		});
	},
	
	startDocumentVerification: function() {
		// Document Verification
		Jumio.initDocumentVerification(API_TOKEN, API_SECRET, DATACENTER, {
			type: "BS",
			userReference: "123456789",
			country: "USA",
			customerInternalReference: "123456789",
			//reportingCriteria: "ReportingCriteria",
			//callbackUrl: "URL",
			//documentName: "Name",
            //enableExtraction: true,
			//customDocumentCode: "Custom",
			//cameraPosition: "back"
		}, {
			// Customization iOS only
			//disableBlur: true,
			//enableDarkMode: true,
			//backgroundColor: "#ff0000",
			//foregroundColor: "#ff0000",
			//tintColor: "#ff0000",
			//barTintColor: "#ff0000",
			//textTitleColor: "#ff0000",
			//positiveButtonBackgroundColor: "#ff0000",
			//positiveButtonBorderColor: "#ff0000",
			//positiveButtonTitleColor: "#ff0000",
			//negativeButtonBackgroundColor: "#ff0000",
			//negativeButtonBorderColor: "#ff0000",
			//negativeButtonTitleColor: "#ff0000"
		});

		Jumio.startDocumentVerification(function(documentData) {
			document.getElementById("log").textContent = JSON.stringify(documentData);
		}, function(error) {
			document.getElementById("log").textContent = JSON.stringify(error);
		});
	},
	
	startBAM: function() {
		// BAM Checkout
		Jumio.initBAM(BAM_API_TOKEN, BAM_API_SECRET, BAM_DATACENTER, {
			cardHolderNameRequired: true,
			//sortCodeAndAccountNumberRequired: false,
			//expiryRequired: true,
			//cvvRequired: false,
			//expiryEditable: false,
			//cardHolderNameEditable: false,
			//reportingCriteria: "ReportingCriteria",
			//vibrationEffectEnabled: true,
			//enableFlashOnScanStart: false,
			//cardNumberMaskingEnabled: false,
			//offlineToken: "TOKEN",
			//cameraPosition: "back",
			//cardTypes: ["VISA", "MASTER_CARD", "AMERICAN_EXPRESS", "CHINA_UNIONPAY", "DINERS_CLUB", "DISCOVER", "JCB"]
		}, {
		 	// Customization iOS only
			//disableBlur: true,
			//backgroundColor: "#ff0000",
			//foregroundColor: "#ff0000",
			//tintColor: "#ff0000",
			//barTintColor: "#ff0000",
			//textTitleColor: "#ff0000",
			//defaultButtonBackgroundColor: "#ff0000",
			//defaultButtonTitleColor: "#ff0000",
			//activeButtonBackgroundColor: "#ff0000",
			//activeButtonTitleColor: "#ff0000",
			//fallbackButtonBackgroundColor: "#ff0000",
			//fallbackButtonBorderColor: "#ff0000",
			//fallbackButtonTitleColor: "#ff0000",
			//positiveButtonBackgroundColor: "#ff0000",
			//positiveButtonBorderColor: "#ff0000",
			//positiveButtonTitleColor: "#ff0000",
			//negativeButtonBackgroundColor: "#ff0000",
			//negativeButtonBorderColor: "#ff0000",
			//negativeButtonTitleColor: "#ff0000",
		 	//scanOverlayTextColor: "#ff0000",
		 	//scanOverlayBorderColor: "#ff0000"
		});

		Jumio.startBAM(function(cardInformation) {
			document.getElementById("log").textContent = JSON.stringify(documentData);
		}, function(error) {
			document.getElementById("log").textContent = JSON.stringify(error);
		});
	},

	startSingleSessionNetverify: function() {
    		var authorizationToken = document.getElementById("tokenInput").value;
    		Jumio.initSingleSessionNetverify(authorizationToken, DATACENTER, {
    			enableVerification: true,
    			//callbackUrl: "URL",
    			//enableIdentityVerification: true,
    			//preselectedCountry: "AUT",
    			//customerInternalReference: "CustomerInternalReference",
    			//reportingCriteria: "ReportingCriteria",
    			//userReference: "UserReference",
    			//sendDebugInfoToJumio: true,
    			//dataExtractionOnMobileOnly: false,
    			//cameraPosition: "back",
    			//preselectedDocumentVariant: "plastic",
    			//documentTypes: ["PASSPORT", "DRIVER_LICENSE", "IDENTITY_CARD", "VISA"],
    			//enableWatchlistScreening: ["enabled", "disabled" || "default"],
    			//watchlistSearchProfile: "YOURPROFILENAME"
                //offlineToken: ""
    		}, {
    			// Customization iOS only
    			//disableBlur: true,
    			//enableDarkMode: true,
    			//backgroundColor: "#ff0000",
    			//foregroundColor: "#ff0000",
    			//tintColor: "#ff0000",
    			//barTintColor: "#ff0000",
    			//textTitleColor: "#ff0000",
                //documentSelectionHeaderBackgroundColor: "#ff0000",
                //documentSelectionHeaderTitleColor: "#ff0000",
                //documentSelectionHeaderIconColor: "#ff0000",
                //documentSelectionButtonBackgroundColor: "#ff0000",
                //documentSelectionButtonTitleColor: "#ff0000",
                //documentSelectionButtonIconColor: "#ff0000",
    			//fallbackButtonBackgroundColor: "#ff0000",
    			//fallbackButtonBorderColor: "#ff0000",
    			//fallbackButtonTitleColor: "#ff0000",
    			//positiveButtonBackgroundColor: "#ff0000",
    			//positiveButtonBorderColor: "#ff0000",
    			//positiveButtonTitleColor: "#ff0000",
    			//negativeButtonBackgroundColor: "#ff0000",
    			//negativeButtonBorderColor: "#ff0000",
    			//negativeButtonTitleColor: "#ff0000",
    			//scanOverlayStandardColor: "#ff0000",
    			//scanOverlayValidColor: "#ff0000",
    			//scanOverlayInvalidColor: "#ff0000",
    			//scanBackgroundColor: "#ff0000",
    			//iProovHeaderTextColor: "#ff0000",
                //iProovHeaderBackgroundColor: "#ff0000",
                //iProovCloseButtonTintColor: "#ff0000",
                //iProovFooterTextColor: "#ff0000",
                //iProovFooterBackgroundColor: "#ff0000",
                //iProovLivenessScanningTintColor: "#ff0000",
                //iProovProgressBarColor: "#ff0000"
    		});

    		Jumio.startNetverify(function(documentData) {
    			// alert(JSON.stringify(documentData));
    			document.getElementById("log").textContent = JSON.stringify(documentData);
    		}, function(error) {
    			// alert(JSON.stringify(error));
    			document.getElementById("log").textContent = JSON.stringify(error);
    		});
    }
};

app.initialize();