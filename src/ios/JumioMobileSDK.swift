//
//  JumioMobileSDK.swift
//
//  Copyright © 2021 Jumio Corporation All rights reserved.
//

import Jumio
import UIKit

@objc(JumioMobileSDK)
class JumioMobileSDK: CDVPlugin {
    fileprivate var jumio: Jumio.SDK?
    fileprivate var jumioVC: Jumio.ViewController?
    fileprivate var callbackId: String?
    @objc public static let jumioMobileSDKInstance = JumioMobileSDK()
    @objc class func jumioMobileSDK() -> JumioMobileSDK {
        return jumioMobileSDKInstance
    }

    @objc(initialize:) func initialize(_ command: CDVInvokedUrlCommand) {
        callbackId = command.callbackId

        if command.arguments.count < 2 {
            sendErrorMessage(errorMessage: "Missing required parameters authorizationToken, or dataCenter.")
            return
        }

        let token = command.argument(at: 0) as! String
        let dataCenter = command.argument(at: 1) as! String

        jumio = Jumio.SDK()
        jumio?.defaultUIDelegate = self
        jumio?.token = token

        switch dataCenter.lowercased() {
        case "eu":
            jumio?.dataCenter = .EU
        case "sg":
            jumio?.dataCenter = .SG
        default:
            jumio?.dataCenter = .US
        }
    }

    @objc(start:) func start(_ command: CDVInvokedUrlCommand) {
        callbackId = command.callbackId

        guard let jumio = jumio else { return }
        jumio.startDefaultUI()

        // Check if customization argument is added
        if let customizations = command.argument(at: 0) as? [String: Any?] {
            let customTheme = customizeSDKColors(customizations: customizations)
            jumio.customize(theme: customTheme)
        }

        jumioVC = try? jumio.viewController()

        guard let jumioVC = jumioVC else { return }

        jumioVC.modalPresentationStyle = .fullScreen

        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController
        else { return }

        rootViewController.present(jumioVC, animated: true)
    }

    @objc(handleDeepLink:) func handleDeepLink(url: NSURL) -> Bool {
        guard Jumio.SDK.handleDeeplinkURL(url as URL) else {
            return false
        }
        return true
    }

    private func getIDResult(idResult: Jumio.IDResult) -> [String: Any] {
        let result: [String: Any?] = [
            "selectedCountry": idResult.country,
            "selectedDocumentType": idResult.idType,
            "idNumber": idResult.documentNumber,
            "personalNumber": idResult.personalNumber,
            "issuingDate": idResult.issuingDate,
            "expiryDate": idResult.expiryDate,
            "issuingCountry": idResult.issuingCountry,
            "firstName": idResult.firstName,
            "lastName": idResult.lastName,
            "gender": idResult.gender,
            "nationality": idResult.nationality,
            "dateOfBirth": idResult.dateOfBirth,
            "addressLine": idResult.address,
            "city": idResult.city,
            "subdivision": idResult.subdivision,
            "postCode": idResult.postalCode,
            "placeOfBirth": idResult.placeOfBirth,
            "mrzLine1": idResult.mrzLine1,
            "mrzLine2": idResult.mrzLine2,
            "mrzLine3": idResult.mrzLine3,
        ]

        return result.compactMapValues { $0 }
    }

    private func getFaceResult(faceResult: Jumio.FaceResult) -> [String: Any] {
        let result: [String: Any?] = [
            "passed": (faceResult.passed ?? false) ? "true" : "false",
        ]

        return result.compactMapValues { $0 }
    }
}

extension JumioMobileSDK: Jumio.DefaultUIDelegate {
    func jumio(sdk: Jumio.SDK, finished result: Jumio.Result) {
        jumioVC?.dismiss(animated: true) { [weak self] in
            guard let weakself = self else { return }

            weakself.jumioVC = nil
            weakself.jumio = nil

            weakself.handleResult(jumioResult: result)
        }
    }

    private func handleResult(jumioResult: Jumio.Result) {
        let accountId = jumioResult.accountId
        let authenticationResult = jumioResult.isSuccess
        let credentialInfos = jumioResult.credentialInfos

        if authenticationResult == true {
            var body: [String: Any?] = [
                "accountId": accountId,
            ]
            var credentialArray = [[String: Any?]]()

            credentialInfos.forEach { credentialInfo in
                var eventResultMap: [String: Any?] = [
                    "credentialId": credentialInfo.id,
                    "credentialCategory": "\(credentialInfo.category)",
                ]

                if credentialInfo.category == .id, let idResult = jumioResult.getIDResult(of: credentialInfo) {
                    eventResultMap = eventResultMap.merging(getIDResult(idResult: idResult), uniquingKeysWith: { first, _ in first })
                } else if credentialInfo.category == .face, let faceResult = jumioResult.getFaceResult(of: credentialInfo) {
                    eventResultMap = eventResultMap.merging(getFaceResult(faceResult: faceResult), uniquingKeysWith: { first, _ in first })
                }

                credentialArray.append(eventResultMap)
            }
            body["credentials"] = credentialArray

            sendScanResult(body: body)
        } else {
            guard let error = jumioResult.error else { return }
            let errorMessage = error.message
            let errorCode = error.code

            let body: [String: Any?] = [
                "errorCode": errorCode,
                "errorMessage": errorMessage,
            ]

            sendScanErrorMessage(body: body)
        }
    }

    private func sendErrorMessage(errorMessage: String) {
        let result = ["errorMessage": errorMessage]
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: result)
        commandDelegate.send(pluginResult, callbackId: callbackId)
    }

    private func sendScanErrorMessage(body: [String: Any?]) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: body as [AnyHashable: Any])
        commandDelegate.send(pluginResult, callbackId: callbackId)
    }

    private func sendScanResult(body: [String: Any?]) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: body as [AnyHashable: Any])
        commandDelegate.send(pluginResult, callbackId: callbackId)
    }
}

extension JumioMobileSDK {
    func customizeSDKColors(customizations: [String: Any?]) -> Jumio.Theme {
        var customTheme = Jumio.Theme()

        // ScanHelp
        if let faceAnimationForeground = customizations["faceAnimationForeground"] as? [String: String?], let light = faceAnimationForeground["light"] as? String, let dark = faceAnimationForeground["dark"] as? String {
            customTheme.scanHelp.faceAnimationForeground = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let faceAnimationForeground = customizations["faceAnimationForeground"] as? String {
            customTheme.scanHelp.faceAnimationForeground = Jumio.Theme.Value(UIColor(hexString: faceAnimationForeground))
        }

        if let faceAnimationBackground = customizations["faceAnimationBackground"] as? [String: String?], let light = faceAnimationBackground["light"] as? String, let dark = faceAnimationBackground["dark"] as? String {
            customTheme.scanHelp.faceAnimationBackground = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let faceAnimationBackground = customizations["faceAnimationBackground"] as? String {
            customTheme.scanHelp.faceAnimationBackground = Jumio.Theme.Value(UIColor(hexString: faceAnimationBackground))
        }

        // IProov
        if let iProovFilterForegroundColor = customizations["iProovFilterForegroundColor"] as? [String: String?], let light = iProovFilterForegroundColor["light"] as? String, let dark = iProovFilterForegroundColor["dark"] as? String {
            customTheme.iProov.filterForegroundColor = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let iProovFilterForegroundColor = customizations["iProovFilterForegroundColor"] as? String {
            customTheme.iProov.filterForegroundColor = Jumio.Theme.Value(UIColor(hexString: iProovFilterForegroundColor))
        }

        if let iProovFilterBackgroundColor = customizations["iProovFilterBackgroundColor"] as? [String: String?], let light = iProovFilterBackgroundColor["light"] as? String, let dark = iProovFilterBackgroundColor["dark"] as? String {
            customTheme.iProov.filterBackgroundColor = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let iProovFilterBackgroundColor = customizations["iProovFilterBackgroundColor"] as? String {
            customTheme.iProov.filterBackgroundColor = Jumio.Theme.Value(UIColor(hexString: iProovFilterBackgroundColor))
        }

        if let iProovTitleTextColor = customizations["iProovTitleTextColor"] as? [String: String?], let light = iProovTitleTextColor["light"] as? String, let dark = iProovTitleTextColor["dark"] as? String {
            customTheme.iProov.titleTextColor = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let iProovTitleTextColor = customizations["iProovTitleTextColor"] as? String {
            customTheme.iProov.titleTextColor = Jumio.Theme.Value(UIColor(hexString: iProovTitleTextColor))
        }

        if let iProovCloseButtonTintColor = customizations["iProovCloseButtonTintColor"] as? [String: String?], let light = iProovCloseButtonTintColor["light"] as? String, let dark = iProovCloseButtonTintColor["dark"] as? String {
            customTheme.iProov.closeButtonTintColor = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let iProovCloseButtonTintColor = customizations["iProovCloseButtonTintColor"] as? String {
            customTheme.iProov.closeButtonTintColor = Jumio.Theme.Value(UIColor(hexString: iProovCloseButtonTintColor))
        }

        if let iProovSurroundColor = customizations["iProovSurroundColor"] as? [String: String?], let light = iProovSurroundColor["light"] as? String, let dark = iProovSurroundColor["dark"] as? String {
            customTheme.iProov.surroundColor = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let iProovSurroundColor = customizations["iProovSurroundColor"] as? String {
            customTheme.iProov.surroundColor = Jumio.Theme.Value(UIColor(hexString: iProovSurroundColor))
        }

        if let iProovPromptTextColor = customizations["iProovPromptTextColor"] as? [String: String?], let light = iProovPromptTextColor["light"] as? String, let dark = iProovPromptTextColor["dark"] as? String {
            customTheme.iProov.promptTextColor = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let iProovPromptTextColor = customizations["iProovPromptTextColor"] as? String {
            customTheme.iProov.promptTextColor = Jumio.Theme.Value(UIColor(hexString: iProovPromptTextColor))
        }

        if let iProovPromptBackgroundColor = customizations["iProovPromptBackgroundColor"] as? [String: String?], let light = iProovPromptBackgroundColor["light"] as? String, let dark = iProovPromptBackgroundColor["dark"] as? String {
            customTheme.iProov.promptBackgroundColor = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let iProovPromptBackgroundColor = customizations["iProovPromptBackgroundColor"] as? String {
            customTheme.iProov.promptBackgroundColor = Jumio.Theme.Value(UIColor(hexString: iProovPromptBackgroundColor))
        }

        if let genuinePresenceAssuranceReadyOvalStrokeColor = customizations["genuinePresenceAssuranceReadyOvalStrokeColor"] as? [String: String?], let light = genuinePresenceAssuranceReadyOvalStrokeColor["light"] as? String, let dark = genuinePresenceAssuranceReadyOvalStrokeColor["dark"] as? String {
            customTheme.iProov.genuinePresenceAssuranceReadyOvalStrokeColor = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let genuinePresenceAssuranceReadyOvalStrokeColor = customizations["genuinePresenceAssuranceReadyOvalStrokeColor"] as? String {
            customTheme.iProov.genuinePresenceAssuranceReadyOvalStrokeColor = Jumio.Theme.Value(UIColor(hexString: genuinePresenceAssuranceReadyOvalStrokeColor))
        }

        if let genuinePresenceAssuranceNotReadyOvalStrokeColor = customizations["genuinePresenceAssuranceNotReadyOvalStrokeColor"] as? [String: String?], let light = genuinePresenceAssuranceNotReadyOvalStrokeColor["light"] as? String, let dark = genuinePresenceAssuranceNotReadyOvalStrokeColor["dark"] as? String {
            customTheme.iProov.genuinePresenceAssuranceNotReadyOvalStrokeColor = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let genuinePresenceAssuranceNotReadyOvalStrokeColor = customizations["genuinePresenceAssuranceNotReadyOvalStrokeColor"] as? String {
            customTheme.iProov.genuinePresenceAssuranceNotReadyOvalStrokeColor = Jumio.Theme.Value(UIColor(hexString: genuinePresenceAssuranceNotReadyOvalStrokeColor))
        }

        if let livenessAssuranceOvalStrokeColor = customizations["livenessAssuranceOvalStrokeColor"] as? [String: String?], let light = livenessAssuranceOvalStrokeColor["light"] as? String, let dark = livenessAssuranceOvalStrokeColor["dark"] as? String {
            customTheme.iProov.livenessAssuranceOvalStrokeColor = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let livenessAssuranceOvalStrokeColor = customizations["livenessAssuranceOvalStrokeColor"] as? String {
            customTheme.iProov.livenessAssuranceOvalStrokeColor = Jumio.Theme.Value(UIColor(hexString: livenessAssuranceOvalStrokeColor))
        }

        if let livenessAssuranceCompletedOvalStrokeColor = customizations["livenessAssuranceCompletedOvalStrokeColor"] as? [String: String?], let light = livenessAssuranceCompletedOvalStrokeColor["light"] as? String, let dark = livenessAssuranceCompletedOvalStrokeColor["dark"] as? String {
            customTheme.iProov.livenessAssuranceCompletedOvalStrokeColor = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let livenessAssuranceCompletedOvalStrokeColor = customizations["livenessAssuranceCompletedOvalStrokeColor"] as? String {
            customTheme.iProov.livenessAssuranceCompletedOvalStrokeColor = Jumio.Theme.Value(UIColor(hexString: livenessAssuranceCompletedOvalStrokeColor))
        }

        // Primary & Secondry Buttons
        if let primaryButtonBackground = customizations["primaryButtonBackground"] as? [String: String?], let light = primaryButtonBackground["light"] as? String, let dark = primaryButtonBackground["dark"] as? String {
            customTheme.primaryButton.background = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let primaryButtonBackground = customizations["primaryButtonBackground"] as? String {
            customTheme.primaryButton.background = Jumio.Theme.Value(UIColor(hexString: primaryButtonBackground))
        }

        if let primaryButtonBackgroundPressed = customizations["primaryButtonBackgroundPressed"] as? [String: String?], let light = primaryButtonBackgroundPressed["light"] as? String, let dark = primaryButtonBackgroundPressed["dark"] as? String {
            customTheme.primaryButton.backgroundPressed = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let primaryButtonBackgroundPressed = customizations["primaryButtonBackgroundPressed"] as? String {
            customTheme.primaryButton.backgroundPressed = Jumio.Theme.Value(UIColor(hexString: primaryButtonBackgroundPressed))
        }

        if let primaryButtonBackgroundDisabled = customizations["primaryButtonBackgroundDisabled"] as? [String: String?], let light = primaryButtonBackgroundDisabled["light"] as? String, let dark = primaryButtonBackgroundDisabled["dark"] as? String {
            customTheme.primaryButton.backgroundDisabled = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let primaryButtonBackgroundDisabled = customizations["primaryButtonBackgroundDisabled"] as? String {
            customTheme.primaryButton.backgroundDisabled = Jumio.Theme.Value(UIColor(hexString: primaryButtonBackgroundDisabled))
        }

        if let primaryButtonForeground = customizations["primaryButtonForeground"] as? [String: String?], let light = primaryButtonForeground["light"] as? String, let dark = primaryButtonForeground["dark"] as? String {
            customTheme.primaryButton.foreground = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let primaryButtonForeground = customizations["primaryButtonForeground"] as? String {
            customTheme.primaryButton.foreground = Jumio.Theme.Value(UIColor(hexString: primaryButtonForeground))
        }

        if let primaryButtonForegroundPressed = customizations["primaryButtonForegroundPressed"] as? [String: String?], let light = primaryButtonForegroundPressed["light"] as? String, let dark = primaryButtonForegroundPressed["dark"] as? String {
            customTheme.primaryButton.foregroundPressed = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let primaryButtonForegroundPressed = customizations["primaryButtonForegroundPressed"] as? String {
            customTheme.primaryButton.foregroundPressed = Jumio.Theme.Value(UIColor(hexString: primaryButtonForegroundPressed))
        }

        if let primaryButtonForegroundDisabled = customizations["primaryButtonForegroundDisabled"] as? [String: String?], let light = primaryButtonForegroundDisabled["light"] as? String, let dark = primaryButtonForegroundDisabled["dark"] as? String {
            customTheme.primaryButton.foregroundDisabled = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let primaryButtonForegroundDisabled = customizations["primaryButtonForegroundDisabled"] as? String {
            customTheme.primaryButton.foregroundDisabled = Jumio.Theme.Value(UIColor(hexString: primaryButtonForegroundDisabled))
        }

        if let secondaryButtonBackground = customizations["secondaryButtonBackground"] as? [String: String?], let light = secondaryButtonBackground["light"] as? String, let dark = secondaryButtonBackground["dark"] as? String {
            customTheme.secondaryButton.background = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let secondaryButtonBackground = customizations["secondaryButtonBackground"] as? String {
            customTheme.secondaryButton.background = Jumio.Theme.Value(UIColor(hexString: secondaryButtonBackground))
        }

        if let secondaryButtonBackgroundPressed = customizations["secondaryButtonBackgroundPressed"] as? [String: String?], let light = secondaryButtonBackgroundPressed["light"] as? String, let dark = secondaryButtonBackgroundPressed["dark"] as? String {
            customTheme.secondaryButton.backgroundPressed = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let secondaryButtonBackgroundPressed = customizations["secondaryButtonBackgroundPressed"] as? String {
            customTheme.secondaryButton.backgroundPressed = Jumio.Theme.Value(UIColor(hexString: secondaryButtonBackgroundPressed))
        }

        if let secondaryButtonBackgroundDisabled = customizations["secondaryButtonBackgroundDisabled"] as? [String: String?], let light = secondaryButtonBackgroundDisabled["light"] as? String, let dark = secondaryButtonBackgroundDisabled["dark"] as? String {
            customTheme.secondaryButton.backgroundDisabled = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let secondaryButtonBackgroundDisabled = customizations["secondaryButtonBackgroundDisabled"] as? String {
            customTheme.secondaryButton.backgroundDisabled = Jumio.Theme.Value(UIColor(hexString: secondaryButtonBackgroundDisabled))
        }

        if let secondaryButtonForeground = customizations["secondaryButtonForeground"] as? [String: String?], let light = secondaryButtonForeground["light"] as? String, let dark = secondaryButtonForeground["dark"] as? String {
            customTheme.secondaryButton.foreground = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let secondaryButtonForeground = customizations["secondaryButtonForeground"] as? String {
            customTheme.secondaryButton.foreground = Jumio.Theme.Value(UIColor(hexString: secondaryButtonForeground))
        }

        // Bubble, Circle and Selection Icon
        if let bubbleBackground = customizations["bubbleBackground"] as? [String: String?], let light = bubbleBackground["light"] as? String, let dark = bubbleBackground["dark"] as? String {
            customTheme.bubble.background = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let bubbleBackground = customizations["bubbleBackground"] as? String {
            customTheme.bubble.background = Jumio.Theme.Value(UIColor(hexString: bubbleBackground))
        }

        if let bubbleForeground = customizations["bubbleForeground"] as? [String: String?], let light = bubbleForeground["light"] as? String, let dark = bubbleForeground["dark"] as? String {
            customTheme.bubble.foreground = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let bubbleForeground = customizations["bubbleForeground"] as? String {
            customTheme.bubble.foreground = Jumio.Theme.Value(UIColor(hexString: bubbleForeground))
        }

        if let bubbleBackgroundSelected = customizations["bubbleBackgroundSelected"] as? [String: String?], let light = bubbleBackgroundSelected["light"] as? String, let dark = bubbleBackgroundSelected["dark"] as? String {
            customTheme.bubble.backgroundSelected = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let bubbleBackgroundSelected = customizations["bubbleBackgroundSelected"] as? String {
            customTheme.bubble.backgroundSelected = Jumio.Theme.Value(UIColor(hexString: bubbleBackgroundSelected))
        }

        if let bubbleCircleItemForeground = customizations["bubbleCircleItemForeground"] as? [String: String?], let light = bubbleCircleItemForeground["light"] as? String, let dark = bubbleCircleItemForeground["dark"] as? String {
            customTheme.bubble.circleItemForeground = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let bubbleCircleItemForeground = customizations["bubbleCircleItemForeground"] as? String {
            customTheme.bubble.circleItemForeground = Jumio.Theme.Value(UIColor(hexString: bubbleCircleItemForeground))
        }

        if let bubbleCircleItemBackground = customizations["bubbleCircleItemBackground"] as? [String: String?], let light = bubbleCircleItemBackground["light"] as? String, let dark = bubbleCircleItemBackground["dark"] as? String {
            customTheme.bubble.circleItemBackground = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let bubbleCircleItemBackground = customizations["bubbleCircleItemBackground"] as? String {
            customTheme.bubble.circleItemBackground = Jumio.Theme.Value(UIColor(hexString: bubbleCircleItemBackground))
        }

        if let bubbleSelectionIconForeground = customizations["bubbleSelectionIconForeground"] as? [String: String?], let light = bubbleSelectionIconForeground["light"] as? String, let dark = bubbleSelectionIconForeground["dark"] as? String {
            customTheme.bubble.selectionIconForeground = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let bubbleSelectionIconForeground = customizations["bubbleSelectionIconForeground"] as? String {
            customTheme.bubble.selectionIconForeground = Jumio.Theme.Value(UIColor(hexString: bubbleSelectionIconForeground))
        }

        // Loading, Error
        if let loadingCirclePlain = customizations["loadingCirclePlain"] as? [String: String?], let light = loadingCirclePlain["light"] as? String, let dark = loadingCirclePlain["dark"] as? String {
            customTheme.loading.circlePlain = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let loadingCirclePlain = customizations["loadingCirclePlain"] as? String {
            customTheme.loading.circlePlain = Jumio.Theme.Value(UIColor(hexString: loadingCirclePlain))
        }

        if let loadingCircleGradientStart = customizations["loadingCircleGradientStart"] as? [String: String?], let light = loadingCircleGradientStart["light"] as? String, let dark = loadingCircleGradientStart["dark"] as? String {
            customTheme.loading.loadingCircleGradientStart = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let loadingCircleGradientStart = customizations["loadingCircleGradientStart"] as? String {
            customTheme.loading.loadingCircleGradientStart = Jumio.Theme.Value(UIColor(hexString: loadingCircleGradientStart))
        }

        if let loadingCircleGradientEnd = customizations["loadingCircleGradientEnd"] as? [String: String?], let light = loadingCircleGradientEnd["light"] as? String, let dark = loadingCircleGradientEnd["dark"] as? String {
            customTheme.loading.loadingCircleGradientEnd = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let loadingCircleGradientEnd = customizations["loadingCircleGradientEnd"] as? String {
            customTheme.loading.loadingCircleGradientEnd = Jumio.Theme.Value(UIColor(hexString: loadingCircleGradientEnd))
        }

        if let loadingErrorCircleGradientStart = customizations["loadingErrorCircleGradientStart"] as? [String: String?], let light = loadingErrorCircleGradientStart["light"] as? String, let dark = loadingErrorCircleGradientStart["dark"] as? String {
            customTheme.loading.errorCircleGradientStart = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let loadingErrorCircleGradientStart = customizations["loadingErrorCircleGradientStart"] as? String {
            customTheme.loading.errorCircleGradientStart = Jumio.Theme.Value(UIColor(hexString: loadingErrorCircleGradientStart))
        }

        if let loadingErrorCircleGradientEnd = customizations["loadingErrorCircleGradientEnd"] as? [String: String?], let light = loadingErrorCircleGradientEnd["light"] as? String, let dark = loadingErrorCircleGradientEnd["dark"] as? String {
            customTheme.loading.errorCircleGradientEnd = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let loadingErrorCircleGradientEnd = customizations["loadingErrorCircleGradientEnd"] as? String {
            customTheme.loading.errorCircleGradientEnd = Jumio.Theme.Value(UIColor(hexString: loadingErrorCircleGradientEnd))
        }

        if let loadingCircleIcon = customizations["loadingCircleIcon"] as? [String: String?], let light = loadingCircleIcon["light"] as? String, let dark = loadingCircleIcon["dark"] as? String {
            customTheme.loading.circleIcon = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let loadingCircleIcon = customizations["loadingCircleIcon"] as? String {
            customTheme.loading.circleIcon = Jumio.Theme.Value(UIColor(hexString: loadingCircleIcon))
        }

        // Scan Overlay
        if let scanOverlay = customizations["scanOverlay"] as? [String: String?], let light = scanOverlay["light"] as? String, let dark = scanOverlay["dark"] as? String {
            customTheme.scanOverlay.scanOverlay = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let scanOverlay = customizations["scanOverlay"] as? String {
            customTheme.scanOverlay.scanOverlay = Jumio.Theme.Value(UIColor(hexString: scanOverlay))
        }

        if let scanOverlayFill = customizations["scanOverlayFill"] as? [String: String?], let light = scanOverlayFill["light"] as? String, let dark = scanOverlayFill["dark"] as? String {
            customTheme.scanOverlay.fill = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let scanOverlayFill = customizations["scanOverlayFill"] as? String {
            customTheme.scanOverlay.fill = Jumio.Theme.Value(UIColor(hexString: scanOverlayFill))
        }

        if let scanOverlayTransparent = customizations["scanOverlayTransparent"] as? [String: String?], let light = scanOverlayTransparent["light"] as? String, let dark = scanOverlayTransparent["dark"] as? String {
            customTheme.scanOverlay.scanOverlayTransparent = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let scanOverlayTransparent = customizations["scanOverlayTransparent"] as? String {
            customTheme.scanOverlay.scanOverlayTransparent = Jumio.Theme.Value(UIColor(hexString: scanOverlayTransparent))
        }

        if let scanOverlayBackground = customizations["scanOverlayBackground"] as? [String: String?], let light = scanOverlayBackground["light"] as? String, let dark = scanOverlayBackground["dark"] as? String {
            customTheme.scanOverlay.scanBackground = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let scanOverlayBackground = customizations["scanOverlayBackground"] as? String {
            customTheme.scanOverlay.scanBackground = Jumio.Theme.Value(UIColor(hexString: scanOverlayBackground))
        }

        // NFC
        if let nfcPassportCover = customizations["nfcPassportCover"] as? [String: String?], let light = nfcPassportCover["light"] as? String, let dark = nfcPassportCover["dark"] as? String {
            customTheme.nfc.passportCover = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let nfcPassportCover = customizations["nfcPassportCover"] as? String {
            customTheme.nfc.passportCover = Jumio.Theme.Value(UIColor(hexString: nfcPassportCover))
        }

        if let nfcPassportPageDark = customizations["nfcPassportPageDark"] as? [String: String?], let light = nfcPassportPageDark["light"] as? String, let dark = nfcPassportPageDark["dark"] as? String {
            customTheme.nfc.passportPageDark = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let nfcPassportPageDark = customizations["nfcPassportPageDark"] as? String {
            customTheme.nfc.passportPageDark = Jumio.Theme.Value(UIColor(hexString: nfcPassportPageDark))
        }

        if let nfcPassportPageLight = customizations["nfcPassportPageLight"] as? [String: String?], let light = nfcPassportPageLight["light"] as? String, let dark = nfcPassportPageLight["dark"] as? String {
            customTheme.nfc.passportPageLight = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let nfcPassportPageLight = customizations["nfcPassportPageLight"] as? String {
            customTheme.nfc.passportPageLight = Jumio.Theme.Value(UIColor(hexString: nfcPassportPageLight))
        }

        if let nfcPassportForeground = customizations["nfcPassportForeground"] as? [String: String?], let light = nfcPassportForeground["light"] as? String, let dark = nfcPassportForeground["dark"] as? String {
            customTheme.nfc.passportForeground = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let nfcPassportForeground = customizations["nfcPassportForeground"] as? String {
            customTheme.nfc.passportForeground = Jumio.Theme.Value(UIColor(hexString: nfcPassportForeground))
        }

        if let nfcPhoneCover = customizations["nfcPhoneCover"] as? [String: String?], let light = nfcPhoneCover["light"] as? String, let dark = nfcPhoneCover["dark"] as? String {
            customTheme.nfc.phoneCover = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let nfcPhoneCover = customizations["nfcPhoneCover"] as? String {
            customTheme.nfc.phoneCover = Jumio.Theme.Value(UIColor(hexString: nfcPhoneCover))
        }

        // ScanView
        if let scanViewBubbleForeground = customizations["scanViewBubbleForeground"] as? [String: String?], let light = scanViewBubbleForeground["light"] as? String, let dark = scanViewBubbleForeground["dark"] as? String {
            customTheme.scanView.bubbleForeground = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let scanViewBubbleForeground = customizations["scanViewBubbleForeground"] as? String {
            customTheme.scanView.bubbleForeground = Jumio.Theme.Value(UIColor(hexString: scanViewBubbleForeground))
        }

        if let scanViewBubbleBackground = customizations["scanViewBubbleBackground"] as? [String: String?], let light = scanViewBubbleBackground["light"] as? String, let dark = scanViewBubbleBackground["dark"] as? String {
            customTheme.scanView.bubbleBackground = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let scanViewBubbleBackground = customizations["scanViewBubbleBackground"] as? String {
            customTheme.scanView.bubbleBackground = Jumio.Theme.Value(UIColor(hexString: scanViewBubbleBackground))
        }

        if let scanViewForeground = customizations["scanViewForeground"] as? [String: String?], let light = scanViewForeground["light"] as? String, let dark = scanViewForeground["dark"] as? String {
            customTheme.scanView.foreground = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let scanViewForeground = customizations["scanViewForeground"] as? String {
            customTheme.scanView.foreground = Jumio.Theme.Value(UIColor(hexString: scanViewForeground))
        }

        if let scanViewDocumentShutter = customizations["scanViewDocumentShutter"] as? [String: String?], let light = scanViewDocumentShutter["light"] as? String, let dark = scanViewDocumentShutter["dark"] as? String {
            customTheme.scanView.documentShutter = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let scanViewDocumentShutter = customizations["scanViewDocumentShutter"] as? String {
            customTheme.scanView.documentShutter = Jumio.Theme.Value(UIColor(hexString: scanViewDocumentShutter))
        }

        if let scanViewFaceShutter = customizations["scanViewFaceShutter"] as? [String: String?], let light = scanViewFaceShutter["light"] as? String, let dark = scanViewFaceShutter["dark"] as? String {
            customTheme.scanView.faceShutter = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let scanViewFaceShutter = customizations["scanViewFaceShutter"] as? String {
            customTheme.scanView.faceShutter = Jumio.Theme.Value(UIColor(hexString: scanViewFaceShutter))
        }

        // Search Bubble
        if let searchBubbleBackground = customizations["searchBubbleBackground"] as? [String: String?], let light = searchBubbleBackground["light"] as? String, let dark = searchBubbleBackground["dark"] as? String {
            customTheme.searchBubble.background = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let searchBubbleBackground = customizations["searchBubbleBackground"] as? String {
            customTheme.searchBubble.background = Jumio.Theme.Value(UIColor(hexString: searchBubbleBackground))
        }

        if let searchBubbleForeground = customizations["searchBubbleForeground"] as? [String: String?], let light = searchBubbleForeground["light"] as? String, let dark = searchBubbleForeground["dark"] as? String {
            customTheme.searchBubble.foreground = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let searchBubbleForeground = customizations["searchBubbleForeground"] as? String {
            customTheme.searchBubble.foreground = Jumio.Theme.Value(UIColor(hexString: searchBubbleForeground))
        }

        if let searchBubbleListItemSelected = customizations["searchBubbleListItemSelected"] as? [String: String?], let light = searchBubbleListItemSelected["light"] as? String, let dark = searchBubbleListItemSelected["dark"] as? String {
            customTheme.searchBubble.listItemSelected = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let searchBubbleListItemSelected = customizations["searchBubbleListItemSelected"] as? String {
            customTheme.searchBubble.listItemSelected = Jumio.Theme.Value(UIColor(hexString: searchBubbleListItemSelected))
        }

        // Confirmation
        if let confirmationImageBackground = customizations["confirmationImageBackground"] as? [String: String?], let light = confirmationImageBackground["light"] as? String, let dark = confirmationImageBackground["dark"] as? String {
            customTheme.confirmation.imageBackground = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let confirmationImageBackground = customizations["confirmationImageBackground"] as? String {
            customTheme.confirmation.imageBackground = Jumio.Theme.Value(UIColor(hexString: confirmationImageBackground))
        }

        if let confirmationImageBackgroundBorder = customizations["confirmationImageBackgroundBorder"] as? [String: String?], let light = confirmationImageBackgroundBorder["light"] as? String, let dark = confirmationImageBackgroundBorder["dark"] as? String {
            customTheme.confirmation.imageBackgroundBorder = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let confirmationImageBackgroundBorder = customizations["confirmationImageBackgroundBorder"] as? String {
            customTheme.confirmation.imageBackgroundBorder = Jumio.Theme.Value(UIColor(hexString: confirmationImageBackgroundBorder))
        }

        if let confirmationIndicatorActive = customizations["confirmationIndicatorActive"] as? [String: String?], let light = confirmationIndicatorActive["light"] as? String, let dark = confirmationIndicatorActive["dark"] as? String {
            customTheme.confirmation.indicatorActive = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let confirmationIndicatorActive = customizations["confirmationIndicatorActive"] as? String {
            customTheme.confirmation.indicatorActive = Jumio.Theme.Value(UIColor(hexString: confirmationIndicatorActive))
        }

        if let confirmationIndicatorDefault = customizations["confirmationIndicatorDefault"] as? [String: String?], let light = confirmationIndicatorDefault["light"] as? String, let dark = confirmationIndicatorDefault["dark"] as? String {
            customTheme.confirmation.indicatorDefault = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let confirmationIndicatorDefault = customizations["confirmationIndicatorDefault"] as? String {
            customTheme.confirmation.indicatorDefault = Jumio.Theme.Value(UIColor(hexString: confirmationIndicatorDefault))
        }

        // Global
        if let background = customizations["background"] as? [String: String?], let light = background["light"] as? String, let dark = background["dark"] as? String {
            customTheme.background = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let background = customizations["background"] as? String {
            customTheme.background = Jumio.Theme.Value(UIColor(hexString: background))
        }

        if let navigationIconColor = customizations["navigationIconColor"] as? [String: String?], let light = navigationIconColor["light"] as? String, let dark = navigationIconColor["dark"] as? String {
            customTheme.navigationIconColor = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let navigationIconColor = customizations["navigationIconColor"] as? String {
            customTheme.navigationIconColor = Jumio.Theme.Value(UIColor(hexString: navigationIconColor))
        }

        if let textForegroundColor = customizations["textForegroundColor"] as? [String: String?], let light = textForegroundColor["light"] as? String, let dark = textForegroundColor["dark"] as? String {
            customTheme.textForegroundColor = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let textForegroundColor = customizations["textForegroundColor"] as? String {
            customTheme.textForegroundColor = Jumio.Theme.Value(UIColor(hexString: textForegroundColor))
        }

        if let primaryColor = customizations["primaryColor"] as? [String: String?], let light = primaryColor["light"] as? String, let dark = primaryColor["dark"] as? String {
            customTheme.primaryColor = Jumio.Theme.Value(light: UIColor(hexString: light), dark: UIColor(hexString: dark))
        } else if let primaryColor = customizations["primaryColor"] as? String {
            customTheme.primaryColor = Jumio.Theme.Value(UIColor(hexString: primaryColor))
        }

        return customTheme
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
