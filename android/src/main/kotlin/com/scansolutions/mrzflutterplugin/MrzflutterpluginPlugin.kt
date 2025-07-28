package com.scansolutions.mrzflutterplugin

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.RectF
import android.util.Base64
import androidx.annotation.NonNull
import com.scansolutions.mrzscannerlib.MRZResultModel
import com.scansolutions.mrzscannerlib.MRZScanner
import com.scansolutions.mrzscannerlib.MRZScannerListener
import com.scansolutions.mrzscannerlib.MRZEffortLevel;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.ByteArrayOutputStream

/** MrzflutterpluginPlugin */
public class MrzflutterpluginPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var mContext: Activity? = null
    var zoomFactor = 0f;
    var scannerTypeVar: Int = 0
    var base64StringVar: String = ""
    var toggleFlashVar: Boolean = false

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "mrzscanner_flutter")
        channel.setMethodCallHandler(this)
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "mrzscanner_flutter")
            channel.setMethodCallHandler(MrzflutterpluginPlugin())
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "startScanner" -> {
                handleStartScanner(result, zoomFactor, scannerTypeVar, null, false, ignoreDuplicates = true)
            }
            "startContinuousScanner" -> {
                var ignoreDuplicates = true
                if (call.arguments is Boolean) {
                    ignoreDuplicates = call.arguments as Boolean
                }
                handleStartScanner(result, zoomFactor, scannerTypeVar, null, true, ignoreDuplicates)
            }
            "startScannerWithCustomOverlay" -> {
                if (call.arguments is String) {
                base64StringVar = call.arguments as String
                handleStartScanner(result, zoomFactor,scannerTypeVar, null, false, ignoreDuplicates = true)
                base64StringVar = ""          
                } 
            }
            "startPartialViewScanner" -> {
                val arguments = call.arguments as ArrayList<Float>
                handleStartScanner(result, zoomFactor, scannerTypeVar, RectF(arguments[0], arguments[1], arguments[2], arguments[3]), false, ignoreDuplicates = true)
            }
            "captureIdImage" -> {
                handleStartScanner(result, zoomFactor,1, null, false, ignoreDuplicates = true)
            }
            "registerWithLicenceKey" -> {
                handleRegisterWithLicenceKey(call)
            }
            "setDateFormat" -> {
                handleSetDateFormat(call)
            }
            "scanFromGallery" -> {
                handleScanFromGallery(result)
            }
            "getSdkVersion" -> {
                result.success(MRZScanner.sdkVersion())
            }
            "setIDActive" -> {
                if (call.arguments is Boolean) {
                    MRZScanner.setIDActive(call.arguments as Boolean)
                }
            }
            "setPassportActive" -> {
                if (call.arguments is Boolean) {
                    MRZScanner.setPassportActive(call.arguments as Boolean)
                }
            }
            "setVisaActive" -> {
                if (call.arguments is Boolean) {
                    MRZScanner.setVisaActive(call.arguments as Boolean)
                }
            }
            "resumeScanner" -> {
                if (ScannerActivity.scannerActivityListener != null) {
                    ScannerActivity.scannerActivityListener.resumeScanning()
                }
            }
            "closeScanner" -> {
                if (ScannerActivity.scannerActivityListener != null) {
                    ScannerActivity.scannerActivityListener.closeScanner()
                }
            }
            "setVibrateOnSuccessfulScan" -> {
                if (call.arguments is Boolean) {
                    MRZScanner.setEnableVibrationOnSuccess(call.arguments as Boolean)
                }
            }
            "setUseFrontCamera" -> {
                if (call.arguments is Boolean) {
                    MRZScanner.setUseFrontCamera(call.arguments as Boolean)
                }
            }
            "setScannerType" -> {
                if (call.arguments is Int) {
                    scannerTypeVar = (call.arguments as Int)
                }
            }
            "setMaxThreads" -> {
                if (call.arguments is Int) {
                    MRZScanner.setMaxThreads(call.arguments as Int)
                }
            }
            "toggleFlash" -> {
                if (call.arguments is Boolean) {
                    toggleFlashVar = (call.arguments as Boolean)
                }
            }
            "setEffortLevel" -> {
                if (call.arguments is Int) {
                    val effortLevelVar = MRZEffortLevel.values()[call.arguments as Int]
                    MRZScanner.setEffortLevel(effortLevelVar)
                }
            }
            "setExtractPortraitEnabled" -> {
                if (call.arguments is Boolean) {
                    MRZScanner.setExtractPortraitEnabled(call.arguments as Boolean)
                }
            }
            "setExtractSignatureEnabled" -> {
                if (call.arguments is Boolean) {
                    MRZScanner.setExtractSignatureEnabled(call.arguments as Boolean)
                }
            }
            "setExtractFullPassportImageEnabled" -> {
                if (call.arguments is Boolean) {
                    MRZScanner.setExtractFullPassportImageEnabled(call.arguments as Boolean)
                }
            }
            "setExtractIdBackImageEnabled" -> {
                if (call.arguments is Boolean) {
                    MRZScanner.setExtractIdBackImageEnabled(call.arguments as Boolean)
                }
            }
            "setWarnIncompatibleCamera" -> {
                if (call.arguments is Boolean) {
                    MRZScanner.warnIncompatibleCamera(call.arguments as Boolean)
                }
            }
            "setZoomFactor" -> {
                if (call.arguments is Double) {

                    zoomFactor = (call.arguments as Double).toFloat()
                    MRZScanner.setZoomFactor(zoomFactor)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun handleScanFromGallery(result: Result) {
        if (mContext != null) {
            MRZScanner.scanFromGallery(mContext, object : MRZScannerListener {
                override fun scanImageFailed() {
                    result.error("scanImageFailed", "scanImageFailed", null)
                }

                override fun permissionsWereDenied() {
                    result.error("permissionsWereDenied", "permissionsWereDenied", null)
                }

                override fun successfulScanWithDocumentImage(p0: Bitmap?) {
                }

                override fun successfulIdFrontImageScan(p0: Bitmap?, p1: Bitmap?) {
                    TODO("Not yet implemented")
                }

                override fun successfulScanWithResult(p0: MRZResultModel?) {
                    if (p0 != null) {
                        val jsonRes = p0.toJSON()

                        if (p0.portrait != null) {
                            jsonRes.put("portrait", convertMapToB64(p0.portrait).toString())
                        }
                        if (p0.signature != null) {
                            jsonRes.put("signature", convertMapToB64(p0.signature).toString())
                        }
                        if (p0.fullImage != null) {
                            jsonRes.put("full_image", convertMapToB64(p0.fullImage).toString())
                        }
                        if (p0.idBack != null) {
                            jsonRes.put("id_back", convertMapToB64(p0.idBack).toString())
                        }
                        if (p0.idFront != null) {
                            jsonRes.put("id_front", convertMapToB64(p0.idFront).toString())
                        }

                        result.success(jsonRes.toString())
                    } else {
                        result.error("scanImageFailed", "scanImageFailed", null)
                    }
                }
            })
        }
    }

    private fun convertMapToB64(bitmap: Bitmap): String? {
        val byteArrayOutputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
        val byteArray: ByteArray = byteArrayOutputStream.toByteArray()
        return Base64.encodeToString(byteArray, Base64.NO_WRAP)
    }

    private fun handleSetDateFormat(call: MethodCall) {
        if (call.arguments is String) {
            val dateFormat = call.arguments as String
            MRZScanner.setDateFormat(dateFormat)
        }
    }

    private fun handleRegisterWithLicenceKey(call: MethodCall) {
        if (mContext != null && call.arguments is String) {
            val licenceKey = call.arguments as String
            MRZScanner.registerWithLicenseKey(mContext, licenceKey)
        }
    }

    private fun handleStartScanner(result: Result, zoomFactor : Float, scannerType: Int, partialRect: RectF?, continuous: Boolean, ignoreDuplicates: Boolean) {
        if (mContext != null) {
            ScannerActivity.setContinuousScanningEnabled(continuous)
            ScannerActivity.setIgnoreDuplicatesEnabled(ignoreDuplicates)

            ScannerActivity.startScanner(mContext,  scannerType,zoomFactor, toggleFlashVar, base64StringVar, partialRect, object : MRZScannerListener {

                override fun scanImageFailed() {
                    result.error("scanImageFailed", "scanImageFailed", null)
                }

                override fun permissionsWereDenied() {
                    if (continuous) {
                        channel.invokeMethod("onScannerResult", "Error:permissionsWereDenied")
                    } else {
                        result.error("permissionsWereDenied", "permissionsWereDenied", null)
                    }
                }

                override fun successfulScanWithDocumentImage(p0: Bitmap?) {
                    if (p0 != null)
                        result.success(convertMapToB64(p0).toString())
                    else {
                        result.error("scanImageFailed", "scanImageFailed", null)
                    }
                }

                override fun successfulIdFrontImageScan(p0: Bitmap?, p1: Bitmap?) {
                    TODO("Not yet implemented")
                }

                override fun successfulScanWithResult(p0: MRZResultModel?) {
                    if (p0 != null) {
                        val jsonRes = p0.toJSON()

                        if (p0.portrait != null) {
                            jsonRes.put("portrait", convertMapToB64(p0.portrait).toString())
                        }
                        if (p0.signature != null) {
                            jsonRes.put("signature", convertMapToB64(p0.signature).toString())
                        }
                        if (p0.fullImage != null) {
                            jsonRes.put("full_image", convertMapToB64(p0.fullImage).toString())
                        }
                        if (p0.idBack != null) {
                            jsonRes.put("id_back", convertMapToB64(p0.idBack).toString())
                        }
                        if (p0.idFront != null) {
                            jsonRes.put("id_front", convertMapToB64(p0.idFront).toString())
                        }

                        if (continuous) {
                            channel.invokeMethod("onScannerResult", jsonRes.toString())
                        } else {
                            result.success(jsonRes.toString())
                        }
                    } else {
                        if (continuous) {
                            channel.invokeMethod("onScannerResult", "Error:scanningFailed")
                        } else {
                            result.error("scanningFailed", "scanningFailed", null)
                        }
                    }
                }

            }) {
                if (continuous) {
                    channel.invokeMethod("onScannerResult", "Error:scannerWasDismissed")
                } else {
                    result.error("scannerWasDismissed", "scannerWasDismissed", null)
                }
            }
        } else {
            if (continuous) {
                channel.invokeMethod("onScannerResult", "Error:scannerWasDismissed")
            } else {
                result.error("context == null", null, null)
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {
        mContext = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mContext = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }
}
