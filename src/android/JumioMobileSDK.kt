package com.jumio.mobilesdk

import android.content.Intent
import android.content.pm.PackageManager.PERMISSION_GRANTED
import android.os.Build
import android.util.Log
import com.jumio.defaultui.JumioActivity
import com.jumio.sdk.JumioSDK
import com.jumio.sdk.credentials.JumioCredentialCategory.FACE
import com.jumio.sdk.credentials.JumioCredentialCategory.ID
import com.jumio.sdk.enums.JumioDataCenter
import com.jumio.sdk.preload.JumioPreloadCallback
import com.jumio.sdk.preload.JumioPreloader
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

class JumioMobileSDK : CordovaPlugin(), JumioPreloadCallback {
    companion object {
        private const val TAG = "JumioMobileSDK"
        private const val PERMISSION_REQUEST_CODE = 301
        private const val REQUEST_CODE = 101
        private const val ACTION_INIT = "initialize"
        private const val ACTION_START = "start"
        private const val ACTION_SET_PRELOADER_FINISHED_BLOCK = "setPreloaderFinishedBlock"
        private const val ACTION_PRELOAD_IF_NEEDED = "preloadIfNeeded"
        private const val ACTION_GET_CACHED_RESULT = "getCachedResult"
        var pendingResult: JSONObject? = null
        var pendingError: JSONObject? = null
    }

    private var callbackContext: CallbackContext? = null
    private var preloaderFinishedCallback: (() -> Unit)? = null
    private var authorizationToken: String? = null
    private var dataCenter: String? = null

    override fun execute(action: String, args: JSONArray, callbackContext: CallbackContext): Boolean {
        if (action == ACTION_START || action == ACTION_SET_PRELOADER_FINISHED_BLOCK || action == ACTION_PRELOAD_IF_NEEDED) {
            this.callbackContext = callbackContext
        }

        val result: PluginResult?
        return when (action) {
            ACTION_INIT -> {
                initialize(args, callbackContext)
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
            ACTION_SET_PRELOADER_FINISHED_BLOCK -> {
                setPreloaderFinishedBlock {
                    callbackContext.success()
                }
                result = PluginResult(NO_RESULT)
                result.keepCallback = true
                true
            }
            ACTION_PRELOAD_IF_NEEDED -> {
                preloadIfNeeded()
                result = PluginResult(NO_RESULT)
                result.keepCallback = true
                true
            }
            ACTION_GET_CACHED_RESULT -> {
                checkAndSendCachedResult(callbackContext)
                result = PluginResult(NO_RESULT)
                result.keepCallback = false
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
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val hasMissingPermission = grantResults.any { it != PERMISSION_GRANTED }

            if (hasMissingPermission) {
                showErrorMessage("You need to grant all required permissions to continue")
            } else {
                initSdk()
            }
        } else {
            super.onRequestPermissionResult(requestCode, permissions, grantResults)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_CODE) {
            data?.let {
                val jumioResult = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    it.getSerializableExtra(JumioActivity.EXTRA_RESULT, JumioResult::class.java)
                } else {
                    @Suppress("DEPRECATION")
                    it.getSerializableExtra(JumioActivity.EXTRA_RESULT) as JumioResult?
                }

                if (jumioResult?.isSuccess == true) sendScanResult(jumioResult) else sendCancelResult(jumioResult)
            }
        }
    }

    private fun initialize(data: JSONArray, callbackContext: CallbackContext) {
        val authorizationToken = data.getString(0)
        val dataCenter = data.getString(1)
        val jumioDataCenter = getJumioDataCenter(dataCenter)

        when {
            !JumioSDK.isSupportedPlatform(cordova.activity) -> {
                callbackContext.error("This platform is not supported.")
                return
            }
            authorizationToken.isNullOrBlank() -> {
                callbackContext.error("Missing required parameters one-time session authorization token.")
            }
            jumioDataCenter == null -> {
                callbackContext.error("Invalid Datacenter value.")
            }
            else -> {
                this.authorizationToken = authorizationToken
                this.dataCenter = dataCenter
                callbackContext.success()
            }
        }
    }

    private fun initSdk() {
        val intent = Intent(cordova.activity, JumioActivity::class.java).apply {
            putExtra(JumioActivity.EXTRA_TOKEN, authorizationToken)
            putExtra(JumioActivity.EXTRA_DATACENTER, dataCenter)

            //The following intent extra can be used to customize the Theme of Default UI
            putExtra(JumioActivity.EXTRA_CUSTOM_THEME, cordova.activity.applicationContext.resources.getIdentifier("AppThemeCustomJumio", "style", cordova.activity.applicationContext.packageName))
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

    private fun setPreloaderFinishedBlock(completion: (() -> Unit)) {
        with(JumioPreloader) {
            init(cordova.activity)
            setCallback(this@JumioMobileSDK)
        }
        preloaderFinishedCallback = completion
    }

    private fun preloadIfNeeded() {
        with(JumioPreloader) {
            preloadIfNeeded()
        }
    }

    override fun preloadFinished() {
        preloaderFinishedCallback?.invoke()
    }

    // Permissions
    private fun checkPermissionsAndStart() {
        if (!JumioSDK.hasAllRequiredPermissions(cordova.activity.applicationContext)) {
            val permissions = JumioSDK.getMissingPermissions(cordova.activity.applicationContext)
            cordova.requestPermissions(this, PERMISSION_REQUEST_CODE, permissions)
        } else {
            initSdk()
        }
    }

    private fun sendScanResult(jumioResult: JumioResult?) {
        val accountId = jumioResult?.accountId
        val workflowId = jumioResult?.workflowExecutionId
        val credentialInfoList = jumioResult?.credentialInfos

        val result = JSONObject()
        val credentialsArray = ArrayList<JSONObject>()

        try {
            credentialInfoList?.let {
                accountId?.let { result.put("accountId", it) }
                workflowId?.let { result.put("workflowId", it) }

                credentialInfoList.forEach {
                    val credentialMap = JSONObject()
                    credentialMap.put("credentialId", it.id)
                    credentialMap.put("credentialCategory", it.category.toString())

                    if (it.category == ID) {
                        val idResult = jumioResult.getIDResult(it)
                        idResult?.let { handleIdResult(idResult, credentialMap) }
                    } else if (it.category == FACE) {
                        val faceResult = jumioResult.getFaceResult(it)
                        faceResult?.passed?.let { passed -> credentialMap.put("passed", passed.toString()) }
                    }
                    credentialsArray.add(credentialMap)
                }
                result.put("credentials", credentialsArray)
            }
        } catch (e: JSONException) {
            showErrorMessage("Result could not be sent: " + e.localizedMessage)
            return
        }

        if (this.callbackContext != null) {
            this.callbackContext?.success(result)
        } else {
            pendingResult = result
            pendingError = null
        }
        this.callbackContext = null
    }
    private fun handleIdResult(idResult: JumioIDResult, credentialMap: JSONObject) =
        with(idResult) {
            credentialMap.apply {
                country?.let { put("selectedCountry", it) }
                idType?.let { put("selectedDocumentType", it) }
                idSubType?.let { put("selectedDocumentSubType", it) }
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
        jumioResult?.error?.let {
            sendErrorObject(it.code, it.message)
        } ?: showErrorMessage("There was a problem extracting the scan result")
    }

    private fun showErrorMessage(msg: String?) {
        Log.e(TAG, msg ?: "")
        sendErrorObject("", msg ?: "Unknown error")
    }

    private fun sendErrorObject(errorCode: String, errorMsg: String?) {
        try {
            val errorResult = JSONObject().apply {
                put("errorCode", if (errorMsg != null) errorCode else "")
                put("errorMessage", errorMsg ?: "")
            }

            if (this.callbackContext != null) {
                this.callbackContext?.error(errorResult)
            } else {
                pendingError = errorResult
                pendingResult = null
            }
            this.callbackContext = null
        } catch (e: JSONException) {
            Log.e(TAG, "Result could not be sent: " + e.localizedMessage)
        } catch (e: NullPointerException) {
            Log.e(TAG, "Result could not be sent: " + e.localizedMessage)
        }
    }

    private fun checkAndSendCachedResult(callbackContext: CallbackContext?) {
        pendingResult?.let {
            callbackContext?.success(it)
            pendingResult = null
            pendingError = null
            return
        }
        pendingError?.let {
            callbackContext?.error(it)
            pendingResult = null
            pendingError = null
            return
        }
    }

    private fun getJumioDataCenter(dataCenter: String) = try {
        JumioDataCenter.valueOf(dataCenter)
    } catch (_: IllegalArgumentException) {
        null
    }
}