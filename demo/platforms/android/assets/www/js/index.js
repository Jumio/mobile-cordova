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
var app = {
    // Application Constructor
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
		document.getElementById("startNetverify").addEventListener("click", this.startNetverify);
		document.getElementById("startBAM").addEventListener("click", this.startBAM);
		document.getElementById("startDocumentVerification").addEventListener("click", this.startDocumentVerification);
    },

    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
    onDeviceReady: function() {
		
    },
	
	startNetverify: function() {
		// Netverify / Fastfill
		Jumio.initNetverify('API_TOKEN', 'API_SECRET', 'DATACENTER', {
			requireVerification: true,
			//callbackUrl: "URL",
			//requireFaceMatch: true,
			//preselectedCountry: "AUT",
			//merchantScanReference: "ScanRef",
			//merchantReportingCriteria: "Criteria",
			//customerId: "ID",
			//additionalInformation: "Information",
			//sendDebugInfoToJumio: true,
			//dataExtractionOnMobileOnly: false,
			//cameraPosition: "back",
			//preselectedDocumentVariant: "plastic",
			//documentTypes: ["PASSPORT", "DRIVER_LICENSE", "IDENTITY_CARD", "VISA"],
            //offlineToken: ""
		}, {
			// Customization iOS only
			//disableBlur: true,
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
			//negativeButtonTitleColor: "#ff0000"
		});

		Jumio.startNetverify(function(documentData) {
			alert(JSON.stringify(documentData));
		}, function(error) {
		    alert(JSON.stringify(error));
		});
	},
	
	startDocumentVerification: function() {
		// Document Verification
		Jumio.initDocumentVerification('API_TOKEN', 'API_SECRET', 'DATACENTER', {
			type: "BS",
			customerId: "123456789",
			country: "USA",
			merchantScanReference: "123456789",
			//merchantScanReportingCriteria: "Criteria",
			//callbackUrl: "URL",
			//additionalInformation: "Information",
			//documentName: "Name",
			//customDocumentCode: "Custom",
			//cameraPosition: "back"
		}, {
			// Customization iOS only
			// see Jumio.initNetverify above
		});

		Jumio.startDocumentVerification(function(documentData) {
			alert(JSON.stringify(documentData));
		}, function(error) {
			alert(JSON.stringify(error));
		});
	},
	
	startBAM: function() {
		// BAM Checkout
		Jumio.initBAM('API_TOKEN', 'API_SECRET', 'DATACENTER', {
			cardHolderNameRequired: true,
			//sortCodeAndAccountNumberRequired: false,
			//expiryRequired: true,
			//cvvRequired: false,
			//expiryEditable: false,
			//cardHolderNameEditable: false,
			//merchantReportingCriteria: "Criteria",
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
			alert(JSON.stringify(cardInformation));
		}, function(error) {
			alert(JSON.stringify(error));
		});
	}
};

app.initialize();
