/*
 * Copyright 2017 Jumio Corporation
 * All rights reserved
 */

package com.jumio.mobilesdk;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.util.Log;

import com.jumio.defaultui.JumioActivity;
import com.jumio.sdk.JumioSDK;
import com.jumio.sdk.credentials.JumioCredentialInfo;
import com.jumio.sdk.result.JumioCredentialResult;
import com.jumio.sdk.result.JumioFaceResult;
import com.jumio.sdk.result.JumioIDResult;
import com.jumio.sdk.result.JumioResult;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.cordova.PluginResult.Status;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class JumioMobileSDK extends CordovaPlugin {

    private static String TAG = "JumioMobileSDK";
    private static final int PERMISSION_REQUEST_CODE = 301;
    private final static int REQUEST_CODE = 101;

    private static final String ACTION_INIT = "initialize";
    private static final String ACTION_START = "start";

    private CallbackContext callbackContext;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {
        PluginResult result = null;
        this.callbackContext = callbackContext;

        if (action.equals(ACTION_INIT)) {
            initialize(args);
            result = new PluginResult(Status.NO_RESULT);
            result.setKeepCallback(false);
            return true;
        } else if (action.equals(ACTION_START)) {
            start();
            result = new PluginResult(Status.NO_RESULT);
            result.setKeepCallback(true);
            return true;
        } else {
            result = new PluginResult(Status.INVALID_ACTION);
            callbackContext.error("Invalid Action");
            return false;
        }
    }

    private void initialize(JSONArray data) {
        if (!JumioSDK.isSupportedPlatform(cordova.getActivity())) {
            showErrorMessage("This platform is not supported.");
            return;
        }

        try {
            if (data.isNull(0) || data.isNull(1)) {
                showErrorMessage("Missing required parameters one-time session authorization token or dataCenter.");
                return;
            }

            final String authorizationToken = data.getString(0);
            final String dataCenter = data.getString(1);

            final Intent intent = new Intent(cordova.getActivity(), JumioActivity.class);
            intent.putExtra(JumioActivity.EXTRA_TOKEN, authorizationToken);
            intent.putExtra(JumioActivity.EXTRA_DATACENTER, dataCenter);

            //The following intent extra can be used to customize the Theme of Default UI
//            intent.putExtra(JumioActivity.EXTRA_CUSTOM_THEME, R.style.AppThemeCustomJumio);

            cordova.getActivity().startActivityForResult(intent, REQUEST_CODE);

        } catch (JSONException e) {
            showErrorMessage("Invalid parameters: " + e.getLocalizedMessage());
        }
    }

    private void start() {
        Runnable runnable = () -> {
            try {
                checkPermissionsAndStart();
            } catch (Exception e) {
                showErrorMessage("Error starting the Jumio SDK: " + e.getLocalizedMessage());
            }
        };

        this.cordova.setActivityResultCallback(this);
        this.cordova.getActivity().runOnUiThread(runnable);
    }

    // Permissions
    private void checkPermissionsAndStart() {
        if (!JumioSDK.hasAllRequiredPermissions(cordova.getActivity().getApplicationContext())) {
            //Acquire missing permissions.
            String[] mp = JumioSDK.getMissingPermissions(cordova.getActivity().getApplicationContext());

            cordova.requestPermissions(this, PERMISSION_REQUEST_CODE, mp);
        }
    }

    @Override
    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws
            JSONException {
        boolean allGranted = true;
        for (int grantResult : grantResults) {
            if (grantResult != PackageManager.PERMISSION_GRANTED) {
                allGranted = false;
                break;
            }
        }

        if (!allGranted) {
            showErrorMessage("You need to grant all required permissions to continue");
            super.onRequestPermissionResult(requestCode, permissions, grantResults);
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE) {
            if (data == null) {
                return;
            }

            final JumioResult jumioResult = (JumioResult) data.getSerializableExtra(JumioActivity.EXTRA_RESULT);

            if (jumioResult != null && jumioResult.isSuccess()) {
                sendScanResult(jumioResult);
            } else {
                sendCancelResult(jumioResult);
            }
        }
    }

    private void sendScanResult(final JumioResult jumioResult) {
        final String accountId = jumioResult.getAccountId();
        final List<JumioCredentialInfo> credentialInfoList = jumioResult.getCredentialInfos();

        final JSONObject result = new JSONObject();
        final ArrayList<JSONObject> credentialsArray = new ArrayList<>();


        if (credentialInfoList != null) {
            try {
                if (accountId != null) {
                    result.put("accountId", accountId);
                }
            } catch (JSONException e) {
                showErrorMessage("Result could not be sent: " + e.getLocalizedMessage());
            }

            for (JumioCredentialInfo credentialInfo : credentialInfoList) {
                final JumioCredentialResult jumioCredentialResult = jumioResult.getResult(credentialInfo);
                final JSONObject credentialMap = new JSONObject();
                try {
                    credentialMap.put("credentialId", credentialInfo.getId());
                    credentialMap.put("credentialCategory", credentialInfo.getCategory().toString());


                    if (jumioCredentialResult instanceof JumioIDResult) {
                        final JumioIDResult idResult = (JumioIDResult) jumioCredentialResult;
                        credentialMap.put("selectedCountry", idResult.getCountry());
                        credentialMap.put("selectedDocumentType", idResult.getIdType());
                        credentialMap.put("idNumber", idResult.getDocumentNumber());
                        credentialMap.put("personalNumber", idResult.getPersonalNumber());
                        credentialMap.put("issuingDate", idResult.getIssuingDate());
                        credentialMap.put("expiryDate", idResult.getExpiryDate());
                        credentialMap.put("issuingCountry", idResult.getIssuingCountry());
                        credentialMap.put("lastName", idResult.getLastName());
                        credentialMap.put("firstName", idResult.getFirstName());
                        credentialMap.put("gender", idResult.getGender());
                        credentialMap.put("nationality", idResult.getNationality());
                        credentialMap.put("dateOfBirth", idResult.getDateOfBirth());

                        credentialMap.put("addressLine", idResult.getAddress());
                        credentialMap.put("city", idResult.getCity());
                        credentialMap.put("subdivision", idResult.getSubdivision());
                        credentialMap.put("postCode", idResult.getPostalCode());
                        credentialMap.put("placeOfBirth", idResult.getPlaceOfBirth());

                        credentialMap.put("mrzLine1", idResult.getMrzLine1());
                        credentialMap.put("mrzLine2", idResult.getMrzLine2());
                        credentialMap.put("mrzLine3", idResult.getMrzLine3());
                    } else if (jumioCredentialResult instanceof JumioFaceResult) {
                        //lowercase
                        credentialMap.put("passed", String.valueOf(((JumioFaceResult) jumioCredentialResult).getPassed()));
                    }
                } catch (JSONException e) {
                    showErrorMessage("Result could not be sent: " + e.getLocalizedMessage());
                }
                credentialsArray.add(credentialMap);
            }
            try {
                result.put("credentials", credentialsArray);
            } catch (JSONException e) {
                showErrorMessage("Result could not be sent: " + e.getLocalizedMessage());
            }
        }
        callbackContext.success(result);
    }

    private void sendCancelResult(final JumioResult jumioResult) {
        if (jumioResult != null && jumioResult.getError() != null) {
            String errorMessage = jumioResult.getError().getMessage();
            String errorCode = jumioResult.getError().getCode();
            sendErrorObject(errorCode, errorMessage);
        } else {
            showErrorMessage("There was a problem extracting the scan result");
        }
    }

    private void showErrorMessage(String msg) {
        Log.e(TAG, msg);
        try {
            JSONObject errorResult = new JSONObject();
            errorResult.put("errorMessage", msg != null ? msg : "");
            if (callbackContext != null) {
                callbackContext.error(errorResult);
            }
        } catch (JSONException | NullPointerException e) {
            Log.e(TAG, e.getLocalizedMessage());
        }
    }

    private void sendErrorObject(String errorCode, String errorMsg) {
        try {
            JSONObject errorResult = new JSONObject();
            errorResult.put("errorCode", errorMsg != null ? errorCode : "");
            errorResult.put("errorMessage", errorMsg != null ? errorMsg : "");

            if(callbackContext != null) {
                callbackContext.error(errorResult);
            }
        } catch (JSONException | NullPointerException e) {
            showErrorMessage("Result could not be sent: " + e.getLocalizedMessage());
        }
    }
}
