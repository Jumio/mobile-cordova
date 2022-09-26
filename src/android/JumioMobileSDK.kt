package com.jumio.mobilesdk

import android.content.Intent
import android.content.pm.PackageManager.PERMISSION_GRANTED
import android.util.Log
import com.jumio.cordova.demo.R
import com.jumio.defaultui.JumioActivity
import com.jumio.sdk.JumioSDK
import com.jumio.sdk.credentials.JumioCredentialCategory.FACE
import com.jumio.sdk.credentials.JumioCredentialCategory.ID
import com.jumio.sdk.enums.JumioDataCenter
import com.jumio.sdk.result.JumioIDResult
import com.jumio.sdk.result.JumioResult
import org.apache.cordova.CallbackContext
import org.apache.cordova.CordovaPlugin
import org.apache.cordova.PluginResult
import org.apache.cordova.PluginResult.Status.INVALID_ACTION
import org.apache.cordova.PluginResult.Status.NO_RESULT
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

class JumioMobileSDK : CordovaPlugin() {
    companion object {
        private const val TAG = "JumioMobileSDK"
        private const val PERMISSION_REQUEST_CODE = 301
        private const val REQUEST_CODE = 101
        private const val ACTION_INIT = "initialize"
        private const val ACTION_START = "start"
    }

    private var callbackContext: CallbackContext? = null

    override fun execute(action: String, args: JSONArray, callbackContext: CallbackContext): Boolean {
        this.callbackContext = callbackContext

        val result: PluginResult?
        return when (action) {
            ACTION_INIT -> {
                initialize(args)
                result = PluginResult(NO_RESULT)
                result.keepCallback = false
                true
            }
            ACTION_START -> {
                start()
                result = PluginResult(NO_RESULT)
                result.keepCallback = true
                true
            }
            else -> {
                result = PluginResult(INVALID_ACTION)
                callbackContext.error("Invalid Action")
                false
            }
        }
    }

    @Throws(JSONException::class)
    override fun onRequestPermissionResult(requestCode: Int, permissions: Array<String?>?, grantResults: IntArray) {
        val hasMissingPermission = grantResults.any { it != PERMISSION_GRANTED }

        if (hasMissingPermission) {
            showErrorMessage("You need to grant all required permissions to continue")
            super.onRequestPermissionResult(requestCode, permissions, grantResults)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_CODE) {
            data?.let {
                val jumioResult = it.getSerializableExtra(JumioActivity.EXTRA_RESULT) as JumioResult?
                if (jumioResult != null && jumioResult.isSuccess) {
                    sendScanResult(jumioResult)
                } else {
                    sendCancelResult(jumioResult)
                }
            }
        }
    }

    private fun initialize(data: JSONArray) {
        val authorizationToken = data.getString(0)
        val dataCenter = data.getString(1)
        val jumioDataCenter = getJumioDataCenter(dataCenter)

        when {
            !JumioSDK.isSupportedPlatform(cordova.activity) -> showErrorMessage("This platform is not supported.")
            jumioDataCenter == null -> showErrorMessage("Invalid Datacenter value.")
            authorizationToken == null || authorizationToken.isEmpty() -> showErrorMessage("Missing required parameters one-time session authorization token.")
            else -> {
                try {
                    initSdk(dataCenter, authorizationToken)
                } catch (e: JSONException) {
                    showErrorMessage("Invalid parameters: " + e.localizedMessage)
                }
            }
        }
    }

    private fun initSdk(dataCenter: String, authorizationToken: String) {
        val intent = Intent(cordova.activity, JumioActivity::class.java).apply {
            putExtra(JumioActivity.EXTRA_TOKEN, authorizationToken)
            putExtra(JumioActivity.EXTRA_DATACENTER, dataCenter)

            //The following intent extra can be used to customize the Theme of Default UI
            putExtra(JumioActivity.EXTRA_CUSTOM_THEME, R.style.AppThemeCustomJumio)
        }

        cordova.activity.startActivityForResult(intent, REQUEST_CODE)
    }

    private fun start() {
        val runnable = Runnable {
            try {
                checkPermissionsAndStart()
            } catch (e: Exception) {
                showErrorMessage("Error starting the Jumio SDK: " + e.localizedMessage)
            }
        }
        cordova.setActivityResultCallback(this)
        cordova.activity.runOnUiThread(runnable)
    }

    // Permissions
    private fun checkPermissionsAndStart() {
        if (!JumioSDK.hasAllRequiredPermissions(cordova.activity.applicationContext)) {
            //Acquire missing permissions.
            val mp = JumioSDK.getMissingPermissions(cordova.activity.applicationContext)
            cordova.requestPermissions(this, PERMISSION_REQUEST_CODE, mp)
        }
    }

    private fun sendScanResult(jumioResult: JumioResult) {
        val accountId = jumioResult.accountId
        val credentialInfoList = jumioResult.credentialInfos

        val result = JSONObject()
        val credentialsArray = ArrayList<JSONObject>()

        credentialInfoList?.let {
            try {
                accountId?.let { result.put("accountId", it) }
            } catch (e: JSONException) {
                showErrorMessage("Result could not be sent: " + e.localizedMessage)
            }

            credentialInfoList.forEach {
                val credentialMap = JSONObject()
                try {
                    credentialMap.put("credentialId", it.id)
                    credentialMap.put("credentialCategory", it.category.toString())

                    if (it.category == ID) {
                        val idResult = jumioResult.getIDResult(it)

                        idResult?.let { handleIdResult(idResult, credentialMap) }
                    } else if (it.category == FACE) {
                        val faceResult = jumioResult.getFaceResult(it)

                        faceResult?.passed?.let { passed -> credentialMap.put("passed", passed.toString()) }
                    }
                } catch (e: JSONException) {
                    showErrorMessage("Result could not be sent: " + e.localizedMessage)
                }
                credentialsArray.add(credentialMap)
            }
            try {
                result.put("credentials", credentialsArray)
            } catch (e: JSONException) {
                showErrorMessage("Result could not be sent: " + e.localizedMessage)
            }
        }
        callbackContext?.success(result)
    }

    private fun handleIdResult(idResult: JumioIDResult, credentialMap: JSONObject) =
            with(idResult) {
                credentialMap.apply {
                    country?.let { put("selectedCountry", it) }
                    idType?.let { put("selectedDocumentType", it) }
                    documentNumber?.let { put("idNumber", it) }
                    personalNumber?.let { put("personalNumber", it) }
                    issuingDate?.let { put("issuingDate", it) }
                    expiryDate?.let { put("expiryDate", it) }
                    issuingCountry?.let { put("issuingCountry", it) }
                    lastName?.let { put("lastName", it) }
                    firstName?.let { put("firstName", it) }
                    gender?.let { put("gender", it) }
                    nationality?.let { put("nationality", it) }
                    dateOfBirth?.let { put("dateOfBirth", it) }
                    address?.let { put("addressLine", it) }
                    city?.let { put("city", it) }
                    subdivision?.let { put("subdivision", it) }
                    postalCode?.let { put("postCode", it) }
                    placeOfBirth?.let { put("placeOfBirth", it) }
                    mrzLine1?.let { put("mrzLine1", it) }
                    mrzLine2?.let { put("mrzLine2", it) }
                    mrzLine3?.let { put("mrzLine3", it) }
                }
            }


    private fun sendCancelResult(jumioResult: JumioResult?) {
        if (jumioResult?.error != null) {
            val errorMessage = jumioResult.error!!.message
            val errorCode = jumioResult.error!!.code
            sendErrorObject(errorCode, errorMessage)
        } else {
            showErrorMessage("There was a problem extracting the scan result")
        }
    }

    private fun showErrorMessage(msg: String?) {
        Log.e(TAG, msg ?: "")
        try {
            val errorResult = JSONObject().apply {
                put("errorMessage", msg ?: "")
            }
            callbackContext?.error(errorResult)
        } catch (e: JSONException) {
            Log.e(TAG, e.localizedMessage)
        }
    }

    private fun sendErrorObject(errorCode: String, errorMsg: String?) {
        try {
            val errorResult = JSONObject().apply {
                put("errorCode", if (errorMsg != null) errorCode else "")
                put("errorMessage", errorMsg ?: "")
            }
            callbackContext?.error(errorResult)
        } catch (e: JSONException) {
            showErrorMessage("Result could not be sent: " + e.localizedMessage)
        } catch (e: NullPointerException) {
            showErrorMessage("Result could not be sent: " + e.localizedMessage)
        }
    }

    private fun getJumioDataCenter(dataCenter: String) = try {
        JumioDataCenter.valueOf(dataCenter)
    } catch (e: IllegalArgumentException) {
        null
    }
}