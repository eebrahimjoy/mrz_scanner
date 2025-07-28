import Flutter
import UIKit
import MRZScannerSDK

public class SwiftMrzflutterpluginPlugin: NSObject, FlutterPlugin, MRZScannerDelegate {
    
    var _mrzScannerController : MRZScannerController?
    var pendingResult: FlutterResult?
    static var channel: FlutterMethodChannel?
    
    var continuousScanning: Bool = false
    var ignoreDuplicates: Bool = true

    var scannerTypeVar: MRZScannerType = TYPE_MRZ
    var effortLevelVar: MRZEffortLevel = EFFORT_LEVEL_TRY_HARDER
    var maxThreadsVar: Int = 2
    var toggleFlashVar: Bool = false
    var zoomFactorVar: Float = 1.0
    
    var extractPortraitEnabledVar: Bool = false
    var extractSignatureEnabledVar: Bool = false
    var extractFullPassportImageEnabledVar: Bool = false
    var extractIdBackImageEnabledVar: Bool = false
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "mrzscanner_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftMrzflutterpluginPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel!)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startScanner":
            pendingResult = result
            continuousScanning = false
            
            startScanner(partialRect: CGRect.init(x: 0, y: 0, width: 100, height: 100))
            break
        case "startContinuousScanner":
            continuousScanning = true

            if call.arguments != nil {
                if let boolVal = call.arguments as? Bool {
                    ignoreDuplicates = boolVal
                }
            }
            
            startScanner(partialRect: CGRect.init(x: 0, y: 0, width: 100, height: 100))
            break
        case "startScannerWithCustomOverlay":
            pendingResult = result
            continuousScanning = false
            
            if call.arguments != nil {
                if let base64String = call.arguments as? String {
                    startScannerWithCustomOverlay(base64String: base64String)
                }
            }
            
            break
        case "startPartialViewScanner":
            pendingResult = result
            continuousScanning = false
            
            let arguments = call.arguments as! NSArray
            let x = CGFloat.init(exactly: arguments.object(at: 0) as! NSNumber)!
            let y = CGFloat.init(exactly: arguments.object(at: 1) as! NSNumber)!
            let width = CGFloat.init(exactly: arguments.object(at: 2) as! NSNumber)!
            let height = CGFloat.init(exactly: arguments.object(at: 3) as! NSNumber)!
            
            startScanner(partialRect: CGRect.init(x: x, y: y, width: width, height: height))
            break
        case "captureIdImage":
            pendingResult = result
            continuousScanning = false
            
            startScanner(partialRect: CGRect.init(x: 0, y: 0, width: 100, height: 100))
            break
        case "resumeScanner":
            if _mrzScannerController != nil {
                _mrzScannerController?.resumeScanner()
            }
            break
        case "closeScanner":
            if _mrzScannerController != nil {
                _mrzScannerController?.closeScanner()
            }
            break
        case "setNightModeActive":
            if _mrzScannerController != nil && call.arguments != nil {
                if let boolVal = call.arguments as? Bool {
                    _mrzScannerController?.setNightModeActive(boolVal)
                }
            }
            break
        case "getSdkVersion":
            result(MRZScannerController.getSDKVersion())
            break
        case "registerWithLicenceKey":
            if call.arguments != nil {
                if let str = call.arguments as? String {
                    MRZScannerController.registerLicense(withKey: str)
                }
            }
            break
        case "scanFromGallery":
            pendingResult = result
            continuousScanning = false
            
            scanFromGallery()
            break
        case "setDateFormat":
            if call.arguments != nil {
                if let str = call.arguments as? String {
                    MRZScannerController.setDateFormat(str)
                }
            }
            break
        case "setPassportActive":
            if call.arguments != nil {
                if let boolVal = call.arguments as? Bool {
                    MRZScannerController.setPassportActive(boolVal)
                }
            }
            break
        case "setIDActive":
            if call.arguments != nil {
                if let boolVal = call.arguments as? Bool {
                    MRZScannerController.setIDActive(boolVal)
                }
            }
            break
        case "setVisaActive":
            if call.arguments != nil {
                if let boolVal = call.arguments as? Bool {
                    MRZScannerController.setVisaActive(boolVal)
                }
            }
            break
        case "setVibrateOnSuccessfulScan":
            if call.arguments != nil {
                if let boolVal = call.arguments as? Bool {
                    MRZScannerController.enableVibration(onSuccess: boolVal)
                }
            }
            break
        case "setUseFrontCamera":
            if call.arguments != nil {
                if let boolVal = call.arguments as? Bool {
                    MRZScannerController.setUseFrontCamera(boolVal)
                }
            }
            break
        case "setScannerType":
            if call.arguments != nil {
                if let scannerType = call.arguments as? MRZScannerType.RawValue {
                    scannerTypeVar.rawValue = scannerType
                }
            }
            break
        case "setMaxThreads":
            if call.arguments != nil {
                if let maxThreads = call.arguments as? Int {
                    maxThreadsVar = maxThreads
                }
            }
            break
        case "setEffortLevel":
            if call.arguments != nil {
                if let effortLevel = call.arguments as? MRZEffortLevel.RawValue {
                    effortLevelVar.rawValue = effortLevel
                }
            }
            break
        case "toggleFlash":
            if call.arguments != nil {
                if let toggleFlash = call.arguments as? Bool {
                    toggleFlashVar = toggleFlash
                }
            }
            break
        case "setExtractPortraitEnabled":
            if call.arguments != nil {
                if let extractPortraitEnabled = call.arguments as? Bool {
                    extractPortraitEnabledVar = extractPortraitEnabled
                }
            }
            break
        case "setExtractSignatureEnabled":
            if call.arguments != nil {
                if let extractSignatureEnabled = call.arguments as? Bool {
                    extractSignatureEnabledVar = extractSignatureEnabled
                }
            }
            break
        case "setExtractFullPassportImageEnabled":
            if call.arguments != nil {
                if let extractFullPassportImageEnabled = call.arguments as? Bool {
                    extractFullPassportImageEnabledVar = extractFullPassportImageEnabled
                }
            }
            break
        case "setExtractIdBackImageEnabled":
            if call.arguments != nil {
                if let extractIdBackImageEnabled = call.arguments as? Bool {
                    extractIdBackImageEnabledVar = extractIdBackImageEnabled
                }
            }
            break
        case "setZoomFactor":
            if call.arguments != nil {
                if let zoomFactor = call.arguments as? Float {
                    zoomFactorVar = zoomFactor
                    _mrzScannerController?.setZoomFactor(zoomFactorVar)
                }
            }
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func startScanner(partialRect: CGRect) {
        let currentVC = UIApplication.shared.keyWindow?.rootViewController
        _mrzScannerController = MRZScannerController()
        _mrzScannerController?.toggleFlash(toggleFlashVar)
        _mrzScannerController?.setZoomFactor(zoomFactorVar)
        _mrzScannerController!.delegate = self
        _mrzScannerController?.setScannerType(scannerTypeVar)
        _mrzScannerController?.setMaxCPUCores(Int32(maxThreadsVar))
        _mrzScannerController?.setEffortLevel(effortLevelVar)
        _mrzScannerController?.setContinuousScanningEnabled(continuousScanning)
        _mrzScannerController?.setIgnoreDuplicates(ignoreDuplicates)
        _mrzScannerController?.setCustomOverlayImage(UIImage())
        MRZScannerController.setExtractPortraitEnabled(extractPortraitEnabledVar)
        MRZScannerController.setExtractSignatureEnabled(extractSignatureEnabledVar)
        MRZScannerController.setExtractFullPassportImageEnabled(extractFullPassportImageEnabledVar)
        MRZScannerController.setExtractIdBackEnabled(extractIdBackImageEnabledVar)
        currentVC?.addChild(_mrzScannerController!)
        _mrzScannerController?.initUI(currentVC, partialViewRect: partialRect)
        
    }
    
    func startScannerWithCustomOverlay(base64String: String) {
        startScanner(partialRect: CGRect.init(x: 0, y: 0, width: 100, height: 100))
        
        if base64String != "" {
            if let decodedData = Data(base64Encoded: base64String, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) {
                
                _mrzScannerController?.setCustomOverlayImage(UIImage(data: decodedData))
            }
        }
    }
    
    func scanFromGallery(){
        let currentVC = UIApplication.shared.keyWindow?.rootViewController
        MRZScannerController.scan(fromGallery: currentVC, delegate: self)
    }
    
    public func successfulScan(withResult result: MRZResultDataModel!) {
        let jsonResult = jsonResultHandleOptionals(result: result)
        
        if result.portrait != nil
            || result.signature != nil
            || result.fullImage != nil
            || result.idBack != nil
            || result.idFront != nil
        {
            let data = jsonResult.data(using: .utf8)
            
            do {
                var jsonDictionary = try JSONSerialization.jsonObject(with: data!, options:[]) as? Dictionary<String, Any?>
                
                if result.portrait != nil {
                    let imgData = result.portrait.pngData()
                    let base64Image = imgData?.base64EncodedData()
                    jsonDictionary?["portrait"] = String.init(data: base64Image!, encoding: .utf8)
                }
                
                if result.signature != nil {
                    let imgData = result.signature.pngData()
                    let base64Image = imgData?.base64EncodedData()
                    jsonDictionary?["signature"] = String.init(data: base64Image!, encoding: .utf8)
                }
                
                if result.fullImage != nil {
                    let imgData = result.fullImage.pngData()
                    let base64Image = imgData?.base64EncodedData()
                    jsonDictionary?["full_image"] = String.init(data: base64Image!, encoding: .utf8)
                }
                
                if result.idBack != nil {
                    let imgData = result.idBack.pngData()
                    let base64Image = imgData?.base64EncodedData()
                    jsonDictionary?["id_back"] = String.init(data: base64Image!, encoding: .utf8)
                }
                
                if result.idFront != nil {
                    let imgData = result.idFront.pngData()
                    let base64Image = imgData?.base64EncodedData()
                    jsonDictionary?["id_front"] = String.init(data: base64Image!, encoding: .utf8)
                }

                if let theJSONData = try? JSONSerialization.data(withJSONObject: jsonDictionary!,
                                                                 options: [])
                {
                    let theJSONText = String(data: theJSONData, encoding: .utf8)
                    if continuousScanning {
                        SwiftMrzflutterpluginPlugin.channel?.invokeMethod("onScannerResult", arguments: theJSONText)
                    } else {
                        pendingResult?(theJSONText)
                    }
                } else {
                    if continuousScanning {
                        SwiftMrzflutterpluginPlugin.channel?.invokeMethod("onScannerResult", arguments: jsonResult)
                    } else {
                        pendingResult?(jsonResult)
                    }
                }
            } catch {
                if continuousScanning {
                    SwiftMrzflutterpluginPlugin.channel?.invokeMethod("onScannerResult", arguments: jsonResult)
                } else {
                    pendingResult?(jsonResult)
                }
            }
        } else {
            if continuousScanning {
                SwiftMrzflutterpluginPlugin.channel?.invokeMethod("onScannerResult", arguments: jsonResult)
            } else {
                pendingResult?(jsonResult)
            }
        }
        
        if !continuousScanning {
            _mrzScannerController?.dismiss(animated: true, completion: nil)
        }
    }
    
    public func scannerWasDismissed() {
        if continuousScanning {
            SwiftMrzflutterpluginPlugin.channel?.invokeMethod("onScannerResult", arguments: "Error:scannerWasDismissed")
        } else {
            pendingResult?(FlutterError.init(code: "scannerWasDismissed", message: "scannerWasDismissed", details: nil))
        }
    }
    
    public func permissionsWereDenied() {
        if continuousScanning {
            SwiftMrzflutterpluginPlugin.channel?.invokeMethod("onScannerResult", arguments: "Error:permissionsWereDenied")
        } else {
            pendingResult?(FlutterError.init(code: "permissionsWereDenied", message: "permissionsWereDenied", details: nil))
        }
    }
    
    public func scanImageFailed() {
        if continuousScanning {
            SwiftMrzflutterpluginPlugin.channel?.invokeMethod("onScannerResult", arguments: "Error:scanImageFailed")
        } else {
            pendingResult?(FlutterError.init(code: "scanImageFailed", message: "scanImageFailed", details: nil))
        }
    }
    
    public func successfulDocumentScan(withImageResult resultImage: UIImage!) {
        let imgData = resultImage.pngData()
        guard let base64Image = imgData?.base64EncodedData() else {
            if continuousScanning {
                SwiftMrzflutterpluginPlugin.channel?.invokeMethod("onScannerResult", arguments: "Error:Conversion to base64 failed")
            } else {
                pendingResult?(FlutterError.init(code: "scanImageFailed", message: "Conversion to base64 failed", details: nil))
            }
            return
        }
        
        guard let imgString = String.init(data: base64Image, encoding: .utf8) else {
            if continuousScanning {
                SwiftMrzflutterpluginPlugin.channel?.invokeMethod("onScannerResult", arguments: "Error:Conversion to base64 failed")
            } else {
                pendingResult?(FlutterError.init(code: "scanImageFailed", message: "Conversion to base64 failed", details: nil))
            }
            return
        }
        
        if continuousScanning {
            SwiftMrzflutterpluginPlugin.channel?.invokeMethod("onScannerResult", arguments: imgString)
        } else {
            pendingResult?(imgString)
        }
    }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        SwiftMrzflutterpluginPlugin.channel = nil
        pendingResult = nil
    }
    
    public func jsonResultHandleOptionals(result: MRZResultDataModel!) -> String {
        let jsonString = result.toJSON() ?? "{}"
        let commaSeparatedString = result.toCommaSeparatedString() ?? ""
        
        let csvComponents = commaSeparatedString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let optionalValue = csvComponents.count > 1 ? csvComponents[csvComponents.count - 2] : nil

        if let optionalValue = optionalValue, optionalValue != "Unknown", !optionalValue.isEmpty {
            var trimmedJSONString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let lastBraceIndex = trimmedJSONString.lastIndex(of: "}") {
                trimmedJSONString = String(trimmedJSONString[..<lastBraceIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            let updatedJSONString = """
            \(trimmedJSONString),
              "optionals": "\(optionalValue)"
            }
            """
            
            return updatedJSONString
        }

        return jsonString
    }
    
}
