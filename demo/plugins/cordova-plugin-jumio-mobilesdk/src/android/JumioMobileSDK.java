/*
 * Copyright 2017 Jumio Corporation
 * All rights reserved
 */

package com.jumio.mobilesdk;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.cordova.PluginResult.Status;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.util.Log;
import android.widget.Toast;

import com.jumio.MobileSDK;
import com.jumio.bam.*;
import com.jumio.bam.custom.*;
import com.jumio.bam.enums.CreditCardType;
import com.jumio.commons.json.JSON;
import com.jumio.core.enums.*;
import com.jumio.core.exceptions.*;
import com.jumio.dv.DocumentVerificationSDK;
import com.jumio.nv.*;
import com.jumio.nv.data.document.NVDocumentType;
import com.jumio.nv.data.document.NVDocumentVariant;
import com.jumio.sdk.SDKExpiredException;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class JumioMobileSDK extends CordovaPlugin {
    
    private static String TAG = "JumioMobileSDK";
    private static final int PERMISSION_REQUEST_CODE_BAM = 300;
    private static final int PERMISSION_REQUEST_CODE_NETVERIFY = 301;
    private static final int PERMISSION_REQUEST_CODE_DOCUMENT_VERIFICATION = 303;
    
    private static final String ACTION_BAM_INIT = "initBAM";
    private static final String ACTION_BAM_START = "startBAM";
    private static final String ACTION_NV_INIT = "initNetverify";
    private static final String ACTION_NV_START = "startNetverify";
    private static final String ACTION_DV_INIT = "initDocumentVerification";
    private static final String ACTION_DV_START = "startDocumentVerification";
    
    private BamSDK bamSDK;
    private NetverifySDK netverifySDK;
    private DocumentVerificationSDK documentVerificationSDK;
    private CallbackContext callbackContext;
    private String errorMsg;
    
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        PluginResult result = null;
        this.callbackContext = callbackContext;
        
        if (action.equals(ACTION_BAM_INIT)) {
            initBAM(args);
            result = new PluginResult(Status.NO_RESULT);
            result.setKeepCallback(false);
            return true;
        } else if (action.equals(ACTION_BAM_START)) {
            startBAM(args);
            result = new PluginResult(Status.NO_RESULT);
            result.setKeepCallback(true);
            return true;
        } else if (action.equals(ACTION_NV_INIT)) {
            initNetverify(args);
            result = new PluginResult(Status.NO_RESULT);
            result.setKeepCallback(false);
            return true;
        } else if (action.equals(ACTION_NV_START)) {
            startNetverify(args);
            result = new PluginResult(Status.NO_RESULT);
            result.setKeepCallback(true);
            return true;
        } else if (action.equals(ACTION_DV_INIT)) {
            initDocumentVerification(args);
            result = new PluginResult(Status.NO_RESULT);
            result.setKeepCallback(false);
            return true;
        } else if (action.equals(ACTION_DV_START)) {
            startDocumentVerification(args);
            result = new PluginResult(Status.NO_RESULT);
            result.setKeepCallback(true);
            return true;
        } else {
            result = new PluginResult(Status.INVALID_ACTION);
            callbackContext.error("Invalid Action");
            return false;
        }
    }
    
    // BAM Checkout
    
    private void initBAM(JSONArray data) {
        if (BamSDK.isRooted(cordova.getActivity().getApplicationContext())) {
            showErrorMessage("The BAM SDK can't run on a rooted device.");
            return;
        }
        
        if (!BamSDK.isSupportedPlatform(cordova.getActivity())) {
            showErrorMessage("This platform is not supported.");
            return;
        }
        
        try {
            JSONObject options = data.getJSONObject(3);
            if (options.has("offlineToken")) {
                String offlineToken = options.getString("offlineToken");
                bamSDK = BamSDK.create(cordova.getActivity(), offlineToken);
            } else {
                if (data.isNull(0) || data.isNull(1) || data.isNull(2)) {
                    showErrorMessage("Missing required parameters apiToken, apiSecret or dataCenter.");
                    return;
                }
                
                String apiToken = data.getString(0);
                String apiSecret = data.getString(1);
                JumioDataCenter dataCenter = (data.getString(2).toLowerCase().equals("us")) ? JumioDataCenter.US : JumioDataCenter.EU;
                
                bamSDK = BamSDK.create(cordova.getActivity(), apiToken, apiSecret, dataCenter);
            }
            
            // Configuration options
            if (!data.isNull(3)) {
                options = data.getJSONObject(3);
                Iterator<String> keys = options.keys();
                while (keys.hasNext()) {
                    String key = keys.next();
                    
                    if (key.equals("cardHolderNameRequired")) {
                        bamSDK.setCardHolderNameRequired(options.getBoolean(key));
                    } else if (key.equals("sortCodeAndAccountNumberRequired")) {
                        bamSDK.setSortCodeAndAccountNumberRequired(options.getBoolean(key));
                    } else if (key.equals("expiryRequired")) {
                        bamSDK.setExpiryRequired(options.getBoolean(key));
                    } else if (key.equals("cvvRequired")) {
                        bamSDK.setCvvRequired(options.getBoolean(key));
                    } else if (key.equals("expiryEditable")) {
                        bamSDK.setExpiryEditable(options.getBoolean(key));
                    } else if (key.equals("cardHolderNameEditable")) {
                        bamSDK.setCardHolderNameEditable(options.getBoolean(key));
                    } else if (key.equals("merchantReportingCriteria")) {
                        bamSDK.setMerchantReportingCriteria(options.getString(key));
                    } else if (key.equals("vibrationEffectEnabled")) {
                        bamSDK.setVibrationEffectEnabled(options.getBoolean(key));
                    } else if (key.equals("enableFlashOnScanStart")) {
                        bamSDK.setEnableFlashOnScanStart(options.getBoolean(key));
                    } else if (key.equals("cardNumberMaskingEnabled")) {
                        bamSDK.setCardNumberMaskingEnabled(options.getBoolean(key));
                    } else if (key.equals("cameraPosition")) {
                        JumioCameraPosition cameraPosition = (options.getString(key).toLowerCase().equals("front")) ? JumioCameraPosition.FRONT : JumioCameraPosition.BACK;
                        bamSDK.setCameraPosition(cameraPosition);
                    } else if (key.equals("cardTypes")) {
                        JSONArray jsonTypes = options.getJSONArray(key);
                        ArrayList<String> types = new ArrayList<String>();
                        if (jsonTypes != null) {
                            int len = jsonTypes.length();
                            for (int i=0;i<len;i++){
                                types.add(jsonTypes.get(i).toString());
                            }
                        }
                        
                        ArrayList<CreditCardType> creditCardTypes = new ArrayList<CreditCardType>();
                        for (String type : types) {
                            if (type.toLowerCase().equals("visa")) {
                                creditCardTypes.add(CreditCardType.VISA);
                            } else if (type.toLowerCase().equals("master_card")) {
                                creditCardTypes.add(CreditCardType.MASTER_CARD);
                            } else if (type.toLowerCase().equals("american_express")) {
                                creditCardTypes.add(CreditCardType.AMERICAN_EXPRESS);
                            } else if (type.toLowerCase().equals("china_unionpay")) {
                                creditCardTypes.add(CreditCardType.CHINA_UNIONPAY);
                            } else if (type.toLowerCase().equals("diners_club")) {
                                creditCardTypes.add(CreditCardType.DINERS_CLUB);
                            } else if (type.toLowerCase().equals("discover")) {
                                creditCardTypes.add(CreditCardType.DISCOVER);
                            } else if (type.toLowerCase().equals("jcb")) {
                                creditCardTypes.add(CreditCardType.JCB);
                            } else if (type.toLowerCase().equals("starbucks")) {
                                creditCardTypes.add(CreditCardType.STARBUCKS);
                            }
                        }
                        
                        bamSDK.setSupportedCreditCardTypes(creditCardTypes);
                    }
                }
            }
        } catch (JSONException e) {
            showErrorMessage("Invalid parameters: " + e.getLocalizedMessage());
        } catch (PlatformNotSupportedException e) {
            showErrorMessage("Error initializing the BAM SDK: " + e.getLocalizedMessage());
        } catch (SDKExpiredException e) {
            showErrorMessage("Error initializing the BAM SDK: " + e.getLocalizedMessage());
        }
    }
    
    private void startBAM(JSONArray data) {
        if (bamSDK == null) {
            showErrorMessage("The BAM SDK is not initialized yet. Call initBAM() first.");
            return;
        }
        
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                try {
                    checkPermissionsAndStart(bamSDK);
                } catch (Exception e) {
                    showErrorMessage("Error starting the BAM SDK: " + e.getLocalizedMessage());
                }
            }
        };
        
        this.cordova.setActivityResultCallback(this);
        this.cordova.getActivity().runOnUiThread(runnable);
    }
    
    // Netverify
    
    private void initNetverify(JSONArray data) {
        if (!NetverifySDK.isSupportedPlatform(cordova.getActivity())) {
            showErrorMessage("This platform is not supported.");
            return;
        }
        
        try {
            if (data.isNull(0) || data.isNull(1) || data.isNull(2)) {
                showErrorMessage("Missing required parameters apiToken, apiSecret or dataCenter.");
                return;
            }
            
            String apiToken = data.getString(0);
            String apiSecret = data.getString(1);
            JumioDataCenter dataCenter = (data.getString(2).toLowerCase().equals("us")) ? JumioDataCenter.US : JumioDataCenter.EU;
            
            netverifySDK = NetverifySDK.create(cordova.getActivity(), apiToken, apiSecret, dataCenter);
            
            // Configuration options
            if (!data.isNull(3)) {
                JSONObject options = data.getJSONObject(3);
                Iterator<String> keys = options.keys();
                while (keys.hasNext()) {
                    String key = keys.next();
                    
                    if (key.equals("requireVerification")) {
                        netverifySDK.setRequireVerification(options.getBoolean(key));
                    } else if (key.equals("callbackUrl")) {
                        netverifySDK.setCallbackUrl(options.getString(key));
                    } else if (key.equals("requireFaceMatch")) {
                        netverifySDK.setRequireFaceMatch(options.getBoolean(key));
                    } else if (key.equals("preselectedCountry")) {
                        netverifySDK.setPreselectedCountry(options.getString(key));
                    } else if (key.equals("merchantScanReference")) {
                        netverifySDK.setMerchantScanReference(options.getString(key));
                    } else if (key.equals("merchantReportingCriteria")) {
                        netverifySDK.setMerchantReportingCriteria(options.getString(key));
                    } else if (key.equals("customerID")) {
                        netverifySDK.setCustomerId(options.getString(key));
                    } else if (key.equals("enableEpassport")) {
                        netverifySDK.setEnableEMRTD(options.getBoolean(key));
                    } else if (key.equals("sendDebugInfoToJumio")) {
                        netverifySDK.sendDebugInfoToJumio(options.getBoolean(key));
                    } else if (key.equals("dataExtractionOnMobileOnly")) {
                        netverifySDK.setDataExtractionOnMobileOnly(options.getBoolean(key));
                    } else if (key.equals("cameraPosition")) {
                        JumioCameraPosition cameraPosition = (options.getString(key).toLowerCase().equals("front")) ? JumioCameraPosition.FRONT : JumioCameraPosition.BACK;
                        netverifySDK.setCameraPosition(cameraPosition);
                    } else if (key.equals("preselectedDocumentVariant")) {
                        NVDocumentVariant variant = (options.getString(key).toLowerCase().equals("paper")) ? NVDocumentVariant.PAPER : NVDocumentVariant.PLASTIC;
                        netverifySDK.setPreselectedDocumentVariant(variant);
                    } else if (key.equals("documentTypes")) {
                        JSONArray jsonTypes = options.getJSONArray(key);
                        ArrayList<String> types = new ArrayList<String>();
                        if (jsonTypes != null) {
                            int len = jsonTypes.length();
                            for (int i=0;i<len;i++){
                                types.add(jsonTypes.get(i).toString());
                            }
                        }
                        
                        ArrayList<NVDocumentType> documentTypes = new ArrayList<NVDocumentType>();
                        for (String type : types) {
                            if (type.toLowerCase().equals("passport")) {
                                documentTypes.add(NVDocumentType.PASSPORT);
                            } else if (type.toLowerCase().equals("driver_license")) {
                                documentTypes.add(NVDocumentType.DRIVER_LICENSE);
                            } else if (type.toLowerCase().equals("identity_card")) {
                                documentTypes.add(NVDocumentType.IDENTITY_CARD);
                            } else if (type.toLowerCase().equals("visa")) {
                                documentTypes.add(NVDocumentType.VISA);
                            }
                        }
                        
                        netverifySDK.setPreselectedDocumentTypes(documentTypes);
                    }
                }
            }
        } catch (JSONException e) {
            showErrorMessage("Invalid parameters: " + e.getLocalizedMessage());
        } catch (PlatformNotSupportedException e) {
            showErrorMessage("Error initializing the Netverify SDK: " + e.getLocalizedMessage());
        }
    }
    
    private void startNetverify(JSONArray data) {
        if (netverifySDK == null) {
            showErrorMessage("The Netverify SDK is not initialized yet. Call initNetverify() first.");
            return;
        }
        
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                try {
                    checkPermissionsAndStart(netverifySDK);
                } catch (Exception e) {
                    showErrorMessage("Error starting the Netverify SDK: " + e.getLocalizedMessage());
                }
            }
        };
        
        this.cordova.setActivityResultCallback(this);
        this.cordova.getActivity().runOnUiThread(runnable);
    }
    
    // Document Verification
    
    private void initDocumentVerification(JSONArray data) {
        if (!DocumentVerificationSDK.isSupportedPlatform(cordova.getActivity())) {
            showErrorMessage("This platform is not supported.");
            return;
        }
        
        try {
            if (data.isNull(0) || data.isNull(1) || data.isNull(2)) {
                showErrorMessage("Missing required parameters apiToken, apiSecret or dataCenter.");
                return;
            }
            
            String apiToken = data.getString(0);
            String apiSecret = data.getString(1);
            JumioDataCenter dataCenter = (data.getString(2).toLowerCase().equals("us")) ? JumioDataCenter.US : JumioDataCenter.EU;
            
            documentVerificationSDK = DocumentVerificationSDK.create(cordova.getActivity(), apiToken, apiSecret, dataCenter);
            
            // Configuration options
            if (!data.isNull(3)) {
                JSONObject options = data.getJSONObject(3);
                Iterator<String> keys = options.keys();
                while (keys.hasNext()) {
                    String key = keys.next();
                    
                    if (key.equals("type")) {
                        documentVerificationSDK.setType(options.getString(key));
                    } else if (key.equals("customDocumentCode")) {
                        documentVerificationSDK.setCustomDocumentCode(options.getString(key));
                    } else if (key.equals("country")) {
                        documentVerificationSDK.setCountry(options.getString(key));
                    } else if (key.equals("merchantReportingCriteria")) {
                        documentVerificationSDK.setMerchantReportingCriteria(options.getString(key));
                    } else if (key.equals("callbackUrl")) {
                        documentVerificationSDK.setCallbackUrl(options.getString(key));
                    } else if (key.equals("merchantScanReference")) {
                        documentVerificationSDK.setMerchantScanReference(options.getString(key));
                    } else if (key.equals("customerId")) {
                        documentVerificationSDK.setCustomerId(options.getString(key));
                    } else if (key.equals("documentName")) {
                        documentVerificationSDK.setDocumentName(options.getString(key));
                    } else if (key.equals("cameraPosition")) {
                        JumioCameraPosition cameraPosition = (options.getString(key).toLowerCase().equals("front")) ? JumioCameraPosition.FRONT : JumioCameraPosition.BACK;
                        documentVerificationSDK.setCameraPosition(cameraPosition);
					} else if (key.equalsIgnoreCase("enableExtraction")) {
						documentVerificationSDK.setEnableExtraction(options.getString(key));
                    }
                }
            }
            
            // Configuration options
            if (!data.isNull(3)) {
                JSONObject options = data.getJSONObject(3);
                Iterator<String> keys = options.keys();
                while (keys.hasNext()) {
                    String key = keys.next();
                    
                    // ...
                }
            }
        } catch (JSONException e) {
            showErrorMessage("Invalid parameters: " + e.getLocalizedMessage());
        } catch (PlatformNotSupportedException e) {
            showErrorMessage("Error initializing the Document Verification SDK: " + e.getLocalizedMessage());
        }
    }
    
    private void startDocumentVerification(JSONArray data) {
        if (documentVerificationSDK == null) {
            showErrorMessage("The Document Verification SDK is not initialized yet. Call initDocumentVerification() first.");
            return;
        }
        
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                try {
                    checkPermissionsAndStart(documentVerificationSDK);
                } catch (Exception e) {
                    showErrorMessage("Error starting the Document Verification SDK: " + e.getLocalizedMessage());
                }
            }
        };
        
        this.cordova.setActivityResultCallback(this);
        this.cordova.getActivity().runOnUiThread(runnable);
    }
    
    
    // Permissions
    
    private void checkPermissionsAndStart(MobileSDK sdk) {
        if (!MobileSDK.hasAllRequiredPermissions(cordova.getActivity().getApplicationContext())) {
            //Acquire missing permissions.
            String[] mp = MobileSDK.getMissingPermissions(cordova.getActivity().getApplicationContext());
            
            int code;
            if (sdk instanceof BamSDK)
                code = PERMISSION_REQUEST_CODE_BAM;
            else if (sdk instanceof NetverifySDK)
                code = PERMISSION_REQUEST_CODE_NETVERIFY;
            else if (sdk instanceof DocumentVerificationSDK)
                code = PERMISSION_REQUEST_CODE_DOCUMENT_VERIFICATION;
            else {
                showErrorMessage("Invalid SDK instance");
                return;
            }
            
            cordova.requestPermissions(this, code, mp);
        } else {
            this.startSdk(sdk);
        }
    }
    
    @Override
    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException {
        boolean allGranted = true;
        for (int grantResult : grantResults) {
            if (grantResult != PackageManager.PERMISSION_GRANTED) {
                allGranted = false;
                break;
            }
        }
        
        if (allGranted) {
            if (requestCode == JumioMobileSDK.PERMISSION_REQUEST_CODE_BAM) {
                startSdk(this.bamSDK);
            } else if (requestCode == JumioMobileSDK.PERMISSION_REQUEST_CODE_NETVERIFY) {
                startSdk(this.netverifySDK);
            } else if (requestCode == JumioMobileSDK.PERMISSION_REQUEST_CODE_DOCUMENT_VERIFICATION) {
                startSdk(this.documentVerificationSDK);
            }
        } else {
            showErrorMessage("You need to grant all required permissions to start the Jumio SDK.");
            super.onRequestPermissionResult(requestCode, permissions, grantResults);
        }
    }
    
    // SDK Result
    
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        // BAM Checkout Results
        if (requestCode == BamSDK.REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                BamCardInformation cardInformation = intent.getParcelableExtra(BamSDK.EXTRA_CARD_INFORMATION);
                
                JSONObject result = new JSONObject();
                try {
                    result.put("cardType", cardInformation.getCardType());
                    result.put("cardNumber", String.valueOf(cardInformation.getCardNumber()));
                    result.put("cardNumberGrouped", String.valueOf(cardInformation.getCardNumberGrouped()));
                    result.put("cardNumberMasked", String.valueOf(cardInformation.getCardNumberMasked()));
                    result.put("cardExpiryMonth", String.valueOf(cardInformation.getCardExpiryDateMonth()));
                    result.put("cardExpiryYear", String.valueOf(cardInformation.getCardExpiryDateYear()));
                    result.put("cardExpiryDate", String.valueOf(cardInformation.getCardExpiryDateYear()));
                    result.put("cardCVV", String.valueOf(cardInformation.getCardCvvCode()));
                    result.put("cardHolderName", String.valueOf(cardInformation.getCardHolderName()));
                    result.put("cardSortCode", String.valueOf(cardInformation.getCardSortCode()));
                    result.put("cardAccountNumber", String.valueOf(cardInformation.getCardAccountNumber()));
                    result.put("cardSortCodeValid", cardInformation.isCardSortCodeValid());
                    result.put("cardAccountNumberValid", cardInformation.isCardAccountNumberValid());
                    
                    callbackContext.success(result);
                    cardInformation.clear();
                } catch (JSONException e) {
                    showErrorMessage("Result could not be sent. Try again.");
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                int errorCode = intent.getIntExtra(BamSDK.EXTRA_ERROR_CODE, 0);
                String errorMsg = intent.getStringExtra(BamSDK.EXTRA_ERROR_MESSAGE);
                showErrorMessage("Cancelled with error code: " + errorCode + ": " + errorMsg);
            }
            // Netverify Results
        } else if (requestCode == NetverifySDK.REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                NetverifyDocumentData documentData = intent.getParcelableExtra(NetverifySDK.EXTRA_SCAN_DATA);
                JSONObject result = new JSONObject();
                try {
                    result.put("selectedCountry", documentData.getSelectedCountry());
                    result.put("selectedDocumentType", documentData.getSelectedDocumentType());
                    result.put("idNumber", documentData.getIdNumber());
                    result.put("personalNumber", documentData.getPersonalNumber());
                    result.put("issuingDate", documentData.getIssuingDate());
                    result.put("expiryDate", documentData.getExpiryDate());
                    result.put("issuingCountry", documentData.getIssuingCountry());
                    result.put("lastName", documentData.getLastName());
                    result.put("firstName", documentData.getFirstName());
                    result.put("middleName", documentData.getMiddleName());
                    result.put("dob", documentData.getDob());
                    result.put("gender", documentData.getGender());
                    result.put("originatingCountry", documentData.getOriginatingCountry());
                    result.put("addressLine", documentData.getAddressLine());
                    result.put("city", documentData.getCity());
                    result.put("subdivision", documentData.getSubdivision());
                    result.put("postCode", documentData.getPostCode());
                    result.put("optionalData1", documentData.getOptionalData1());
                    result.put("optionalData2", documentData.getOptionalData2());
                    result.put("placeOfBirth", documentData.getPlaceOfBirth());
                    result.put("extractionMethod", documentData.getExtractionMethod());
                    
                    // MRZ data if available
                    if (documentData.getMrzData() != null) {
                        JSONObject mrzData = new JSONObject();
                        mrzData.put("format", documentData.getMrzData().getFormat());
                        mrzData.put("line1", documentData.getMrzData().getMrzLine1());
                        mrzData.put("line2", documentData.getMrzData().getMrzLine2());
                        mrzData.put("line3", documentData.getMrzData().getMrzLine3());
                        mrzData.put("idNumberValid", documentData.getMrzData().idNumberValid());
                        mrzData.put("dobValid", documentData.getMrzData().dobValid());
                        mrzData.put("expiryDateValid", documentData.getMrzData().expiryDateValid());
                        mrzData.put("personalNumberValid", documentData.getMrzData().personalNumberValid());
                        mrzData.put("compositeValid", documentData.getMrzData().compositeValid());
                        result.put("mrzData", mrzData);
                    }
                    
                    callbackContext.success(result);
                } catch (JSONException e) {
                    showErrorMessage("Result could not be sent: " + e.getLocalizedMessage());
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                int errorCode = intent.getIntExtra(NetverifySDK.EXTRA_ERROR_CODE, 0);
                String errorMsg = intent.getStringExtra(NetverifySDK.EXTRA_ERROR_MESSAGE);
                showErrorMessage("Cancelled with error code: " + errorCode + ": " + errorMsg);
            }
        } else if (requestCode == DocumentVerificationSDK.REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                callbackContext.success("Document-Verification finished successfully.");
            } else if (resultCode == Activity.RESULT_CANCELED) {
                int errorCode = intent.getIntExtra(DocumentVerificationSDK.EXTRA_ERROR_CODE, 0);
                String errorMsg = intent.getStringExtra(DocumentVerificationSDK.EXTRA_ERROR_MESSAGE);
                showErrorMessage("Cancelled with error code: " + errorCode + ": " + errorMsg);
            }
        }
    }
    
    // Helper methods
    
    private void startSdk(MobileSDK sdk) {
        try {
            sdk.start();
        } catch (MissingPermissionException e) {
            Toast.makeText(cordova.getActivity(), e.getMessage(), Toast.LENGTH_LONG).show();
        }
    }
    
    private void showErrorMessage(String msg) {
        Log.e(TAG, msg);
        callbackContext.error(msg);
    }
}
