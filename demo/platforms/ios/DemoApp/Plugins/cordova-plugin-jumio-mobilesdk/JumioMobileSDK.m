//
//  JumioMobileSDK.h
//  Jumio Software Development GmbH
//

#import "JumioMobileSDK.h"

@implementation JumioMobileSDK
    
#pragma mark - BAM Checkout
    
- (void)initBAM:(CDVInvokedUrlCommand*)command
    {
        self.callbackId = command.callbackId;
        
        NSUInteger argc = [command.arguments count];
        if (argc < 3) {
            [self sendErrorMessage: @"Missing required parameters apiToken, apiSecret or dataCenter."];
            return;
        }
        
        NSString *apiToken = [command.arguments objectAtIndex: 0];
        NSString *apiSecret = [command.arguments objectAtIndex: 1];
        NSString *dataCenterString = [command.arguments objectAtIndex: 2];
        NSString *dataCenterLowercase = [dataCenterString lowercaseString];
        JumioDataCenter dataCenter = ([dataCenterLowercase isEqualToString: @"us"]) ? JumioDataCenterUS : JumioDataCenterEU;
        
        // Initialization
        self.bamConfiguration = [BAMCheckoutConfiguration new];
        self.bamConfiguration.delegate = self;
        self.bamConfiguration.merchantApiToken = apiToken;
        self.bamConfiguration.merchantApiSecret = apiSecret;
        self.bamConfiguration.dataCenter = dataCenter;
        
        // Configuration
        NSDictionary *options = [command.arguments objectAtIndex: 3];
        if (![options isEqual: [NSNull null]]) {
            for (NSString *key in options) {
                if ([key isEqualToString: @"cardHolderNameRequired"]) {
                    self.bamConfiguration.cardHolderNameRequired = [self getBoolValue: [options objectForKey: key]];
                } else if ([key isEqualToString: @"sortCodeAndAccountNumberRequired"]) {
                    self.bamConfiguration.sortCodeAndAccountNumberRequired = [self getBoolValue: [options objectForKey: key]];
                } else if ([key isEqualToString: @"expiryRequired"]) {
                    self.bamConfiguration.expiryRequired = [self getBoolValue: [options objectForKey: key]];
                } else if ([key isEqualToString: @"cvvRequired"]) {
                    self.bamConfiguration.cvvRequired = [self getBoolValue: [options objectForKey: key]];
                } else if ([key isEqualToString: @"expiryEditable"]) {
                    self.bamConfiguration.expiryEditable = [self getBoolValue: [options objectForKey: key]];
                } else if ([key isEqualToString: @"cardHolderNameEditable"]) {
                    self.bamConfiguration.cardHolderNameEditable = [self getBoolValue: [options objectForKey: key]];
                } else if ([key isEqualToString: @"merchantReportingCriteria"]) {
                    self.bamConfiguration.merchantReportingCriteria = [options objectForKey: key];
                } else if ([key isEqualToString: @"vibrationEffectEnabled"]) {
                    self.bamConfiguration.vibrationEffectEnabled = [self getBoolValue: [options objectForKey: key]];
                } else if ([key isEqualToString: @"enableFlashOnScanStart"]) {
                    self.bamConfiguration.enableFlashOnScanStart = [self getBoolValue: [options objectForKey: key]];
                } else if ([key isEqualToString: @"cardNumberMaskingEnabled"]) {
                    self.bamConfiguration.cardNumberMaskingEnabled = [self getBoolValue: [options objectForKey: key]];
                } else if ([key isEqualToString: @"offlineToken"]) {
                    self.bamConfiguration.offlineToken = [options objectForKey: key];
                } else if ([key isEqualToString: @"cameraPosition"]) {
                    NSString *cameraString = [[options objectForKey: key] lowercaseString];
                    JumioCameraPosition cameraPosition = ([cameraString isEqualToString: @"front"]) ? JumioCameraPositionFront : JumioCameraPositionBack;
                    self.bamConfiguration.cameraPosition = cameraPosition;
                } else if ([key isEqualToString: @"cardTypes"]) {
                    NSMutableArray *jsonTypes = [options objectForKey: key];
                    BAMCheckoutCreditCardTypes cardTypes = 0;
                    
                    int i;
                    for (i = 0; i < [jsonTypes count]; i++) {
                        id type = [jsonTypes objectAtIndex: i];
                        
                        if ([[type lowercaseString] isEqualToString: @"visa"]) {
                            cardTypes = cardTypes | BAMCheckoutCreditCardTypeVisa;
                        } else if ([[type lowercaseString] isEqualToString: @"master_card"]) {
                            cardTypes = cardTypes | BAMCheckoutCreditCardTypeMasterCard;
                        } else if ([[type lowercaseString] isEqualToString: @"american_express"]) {
                            cardTypes = cardTypes | BAMCheckoutCreditCardTypeAmericanExpress;
                        } else if ([[type lowercaseString] isEqualToString: @"china_unionpay"]) {
                            cardTypes = cardTypes | BAMCheckoutCreditCardTypeChinaUnionPay;
                        } else if ([[type lowercaseString] isEqualToString: @"diners_club"]) {
                            cardTypes = cardTypes | BAMCheckoutCreditCardTypeDiners;
                        } else if ([[type lowercaseString] isEqualToString: @"discover"]) {
                            cardTypes = cardTypes | BAMCheckoutCreditCardTypeDiscover;
                        } else if ([[type lowercaseString] isEqualToString: @"jcb"]) {
                            cardTypes = cardTypes | BAMCheckoutCreditCardTypeJCB;
                        } else if ([[type lowercaseString] isEqualToString: @"starbucks"]) {
                            cardTypes = cardTypes | BAMCheckoutCreditCardTypeStarbucks;
                        }
                    }
                    
                    self.bamConfiguration.supportedCreditCardTypes = cardTypes;
                }
            }
        }
        
        // Customization
        NSDictionary *customization = [command.arguments objectAtIndex: 4];
        if (![customization isEqual:[NSNull null]]) {
            for (NSString *key in customization) {
                if ([key isEqualToString: @"disableBlur"]) {
                    [[BAMCheckoutBaseView bamCheckoutAppearance] setDisableBlur: @YES];
                } else {
                    UIColor *color = [self colorWithHexString: [customization objectForKey: key]];
                    
                    if ([key isEqualToString: @"backgroundColor"]) {
                        [[BAMCheckoutBaseView bamCheckoutAppearance] setBackgroundColor: color];
                    } else if ([key isEqualToString: @"tintColor"]) {
                        [[UINavigationBar bamCheckoutAppearance] setTintColor: color];
                    } else if ([key isEqualToString: @"barTintColor"]) {
                        [[UINavigationBar bamCheckoutAppearance] setBarTintColor: color];
                    } else if ([key isEqualToString: @"textTitleColor"]) {
                        [[UINavigationBar bamCheckoutAppearance] setTitleTextAttributes: @{NSForegroundColorAttributeName: color}];
                    } else if ([key isEqualToString: @"foregroundColor"]) {
                        [[BAMCheckoutBaseView bamCheckoutAppearance] setForegroundColor: color];
                    } else if ([key isEqualToString: @"positiveButtonBackgroundColor"]) {
                        [[BAMCheckoutPositiveButton bamCheckoutAppearance] setBackgroundColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"positiveButtonBorderColor"]) {
                        [[BAMCheckoutPositiveButton bamCheckoutAppearance] setBorderColor: color];
                    } else if ([key isEqualToString: @"positiveButtonTitleColor"]) {
                        [[BAMCheckoutPositiveButton bamCheckoutAppearance] setTitleColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"negativeButtonBackgroundColor"]) {
                        [[BAMCheckoutNegativeButton bamCheckoutAppearance] setBackgroundColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"negativeButtonBorderColor"]) {
                        [[BAMCheckoutNegativeButton bamCheckoutAppearance] setBorderColor: color];
                    } else if ([key isEqualToString: @"negativeButtonTitleColor"]) {
                        [[BAMCheckoutNegativeButton bamCheckoutAppearance] setTitleColor: color forState:UIControlStateNormal];
                    }  else if ([key isEqualToString: @"scanOverlayTextColor"]) {
                        [[BAMCheckoutScanOverlay bamCheckoutAppearance] setTextColor: color];
                    }  else if ([key isEqualToString: @"scanOverlayBorderColor"]) {
                        [[BAMCheckoutScanOverlay bamCheckoutAppearance] setBorderColor: color];
                    }
                }
            }
        }

        @try {
            self.bamViewController = [[BAMCheckoutViewController alloc] initWithConfiguration: self.bamConfiguration];
        } @catch (NSException *exception) {
            NSString *msg = [NSString stringWithFormat: @"Cancelled with exception %@: %@", exception.name, exception.reason];
            [self sendErrorMessage: msg];
        }
    }
    
- (void)startBAM:(CDVInvokedUrlCommand*)command
    {
        self.callbackId = command.callbackId;
        
        if (self.bamViewController == nil) {
            [self sendErrorMessage: @"The BAM SDK is not initialized yet. Call initBAM() first."];
            return;
        }
        
        [self.viewController presentViewController: self.bamViewController animated: YES completion: nil];
    }
    
#pragma mark - Netverify
    
- (void)initNetverify:(CDVInvokedUrlCommand*)command
    {
        self.callbackId = command.callbackId;
        
        NSUInteger argc = [command.arguments count];
        if (argc < 3) {
            [self sendErrorMessage: @"Missing required parameters apiToken, apiSecret or dataCenter."];
            return;
        }
        
        NSString *apiToken = [command.arguments objectAtIndex: 0];
        NSString *apiSecret = [command.arguments objectAtIndex: 1];
        NSString *dataCenterString = [command.arguments objectAtIndex: 2];
        NSString *dataCenterLowercase = [dataCenterString lowercaseString];
        JumioDataCenter dataCenter = ([dataCenterLowercase isEqualToString: @"us"]) ? JumioDataCenterUS : JumioDataCenterEU;
        
        // Initialization
        self.netverifyConfiguration = [NetverifyConfiguration new];
        self.netverifyConfiguration.delegate = self;
        self.netverifyConfiguration.merchantApiToken = apiToken;
        self.netverifyConfiguration.merchantApiSecret = apiSecret;
        self.netverifyConfiguration.dataCenter = dataCenter;
        
        // Configuration
        NSDictionary *options = [command.arguments objectAtIndex: 3];
        if (![options isEqual:[NSNull null]]) {
            for (NSString *key in options) {
                if ([key isEqualToString: @"requireVerification"]) {
                    self.netverifyConfiguration.requireVerification = [options objectForKey: key];
                } else if ([key isEqualToString: @"callbackUrl"]) {
                    self.netverifyConfiguration.callbackUrl = [options objectForKey: key];
                } else if ([key isEqualToString: @"requireFaceMatch"]) {
                    self.netverifyConfiguration.requireFaceMatch = [options objectForKey: key];
                } else if ([key isEqualToString: @"preselectedCountry"]) {
                    self.netverifyConfiguration.preselectedCountry = [options objectForKey: key];
                } else if ([key isEqualToString: @"merchantScanReference"]) {
                    self.netverifyConfiguration.merchantScanReference = [options objectForKey: key];
                } else if ([key isEqualToString: @"merchantReportingCriteria"]) {
                    self.netverifyConfiguration.merchantReportingCriteria = [options objectForKey: key];
                } else if ([key isEqualToString: @"customerId"]) {
                    self.netverifyConfiguration.customerId = [options objectForKey: key];
                } else if ([key isEqualToString: @"sendDebugInfoToJumio"]) {
                    self.netverifyConfiguration.sendDebugInfoToJumio = [options objectForKey: key];
                } else if ([key isEqualToString: @"dataExtractionOnMobileOnly"]) {
                    self.netverifyConfiguration.dataExtractionOnMobileOnly = [options objectForKey: key];
                } else if ([key isEqualToString: @"cameraPosition"]) {
                    NSString *cameraString = [[options objectForKey: key] lowercaseString];
                    JumioCameraPosition cameraPosition = ([cameraString isEqualToString: @"front"]) ? JumioCameraPositionFront : JumioCameraPositionBack;
                    self.netverifyConfiguration.cameraPosition = cameraPosition;
                } else if ([key isEqualToString: @"preselectedDocumentVariant"]) {
                    NSString *variantString = [[options objectForKey: key] lowercaseString];
                    NetverifyDocumentVariant variant = ([variantString isEqualToString: @"paper"]) ? NetverifyDocumentVariantPaper : NetverifyDocumentVariantPlastic;
                    self.netverifyConfiguration.preselectedDocumentVariant = variant;
                } else if ([key isEqualToString: @"documentTypes"]) {
                    NSMutableArray *jsonTypes = [options objectForKey: key];
                    NetverifyDocumentType documentTypes = 0;
                    
                    int i;
                    for (i = 0; i < [jsonTypes count]; i++) {
                        id type = [jsonTypes objectAtIndex: i];
                        
                        if ([[type lowercaseString] isEqualToString: @"passport"]) {
                            documentTypes = documentTypes | NetverifyDocumentTypePassport;
                        } else if ([[type lowercaseString] isEqualToString: @"driver_license"]) {
                            documentTypes = documentTypes | NetverifyDocumentTypeDriverLicense;
                        } else if ([[type lowercaseString] isEqualToString: @"identity_card"]) {
                            documentTypes = documentTypes | NetverifyDocumentTypeIdentityCard;
                        } else if ([[type lowercaseString] isEqualToString: @"visa"]) {
                            documentTypes = documentTypes | NetverifyDocumentTypeVisa;
                        }
                    }
                    
                    self.netverifyConfiguration.preselectedDocumentTypes = documentTypes;
                } else if ([key isEqualToString: @"offlineToken"]) {
                    self.netverifyConfiguration.offlineToken = [options objectForKey: key];
                }
            }
        }
        
        // Customization
        NSDictionary *customization = [command.arguments objectAtIndex: 4];
        if (![customization isEqual:[NSNull null]]) {
            for (NSString *key in customization) {
                if ([key isEqualToString: @"disableBlur"]) {
                    [[NetverifyBaseView netverifyAppearance] setDisableBlur: @YES];
                } else {
                    UIColor *color = [self colorWithHexString: [customization objectForKey: key]];
                    
                    if ([key isEqualToString: @"backgroundColor"]) {
                        [[NetverifyBaseView netverifyAppearance] setBackgroundColor: color];
                    } else if ([key isEqualToString: @"tintColor"]) {
                        [[UINavigationBar netverifyAppearance] setTintColor: color];
                    } else if ([key isEqualToString: @"barTintColor"]) {
                        [[UINavigationBar netverifyAppearance] setBarTintColor: color];
                    } else if ([key isEqualToString: @"textTitleColor"]) {
                        [[UINavigationBar netverifyAppearance] setTitleTextAttributes: @{NSForegroundColorAttributeName: color}];
                    } else if ([key isEqualToString: @"foregroundColor"]) {
                        [[NetverifyBaseView netverifyAppearance] setForegroundColor: color];
                    } else if ([key isEqualToString: @"documentSelectionHeaderBackgroundColor"]) {
                        [[NetverifyDocumentSelectionHeaderView netverifyAppearance] setBackgroundColor: color];
                    } else if ([key isEqualToString: @"documentSelectionHeaderTitleColor"]) {
                        [[NetverifyDocumentSelectionHeaderView netverifyAppearance] setTitleColor: color];
                    } else if ([key isEqualToString: @"documentSelectionHeaderIconColor"]) {
                        [[NetverifyDocumentSelectionHeaderView netverifyAppearance] setIconColor: color];
                    } else if ([key isEqualToString: @"documentSelectionButtonBackgroundColor"]) {
                        [[NetverifyDocumentSelectionButton netverifyAppearance] setBackgroundColor: color forState: UIControlStateNormal];
                    } else if ([key isEqualToString: @"documentSelectionButtonTitleColor"]) {
                        [[NetverifyDocumentSelectionButton netverifyAppearance] setTitleColor: color forState: UIControlStateNormal];
                    } else if ([key isEqualToString: @"documentSelectionButtonIconColor"]) {
                        [[NetverifyDocumentSelectionButton netverifyAppearance] setIconColor: color forState: UIControlStateNormal];
                    } else if ([key isEqualToString: @"fallbackButtonBackgroundColor"]) {
                        [[NetverifyFallbackButton netverifyAppearance] setBackgroundColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"fallbackButtonBorderColor"]) {
                        [[NetverifyFallbackButton netverifyAppearance] setBorderColor: color];
                    } else if ([key isEqualToString: @"fallbackButtonTitleColor"]) {
                        [[NetverifyFallbackButton netverifyAppearance] setTitleColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"positiveButtonBackgroundColor"]) {
                        [[NetverifyPositiveButton netverifyAppearance] setBackgroundColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"positiveButtonBorderColor"]) {
                        [[NetverifyPositiveButton netverifyAppearance] setBorderColor: color];
                    } else if ([key isEqualToString: @"positiveButtonTitleColor"]) {
                        [[NetverifyPositiveButton netverifyAppearance] setTitleColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"negativeButtonBackgroundColor"]) {
                        [[NetverifyNegativeButton netverifyAppearance] setBackgroundColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"negativeButtonBorderColor"]) {
                        [[NetverifyNegativeButton netverifyAppearance] setBorderColor: color];
                    } else if ([key isEqualToString: @"negativeButtonTitleColor"]) {
                        [[NetverifyNegativeButton netverifyAppearance] setTitleColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"scanOverlayStandardColor"]) {
                        [[NetverifyScanOverlayView netverifyAppearance] setColorOverlayStandard: color];
                    } else if ([key isEqualToString: @"scanOverlayValidColor"]) {
                        [[NetverifyScanOverlayView netverifyAppearance] setColorOverlayValid: color];
                    } else if ([key isEqualToString: @"scanOverlayInvalidColor"]) {
                        [[NetverifyScanOverlayView netverifyAppearance] setColorOverlayInvalid: color];
                    }
                }
            }
        }

        @try {
            self.netverifyViewController = [[NetverifyViewController alloc] initWithConfiguration: self.netverifyConfiguration];
        } @catch (NSException *exception) {
            NSString *msg = [NSString stringWithFormat: @"Cancelled with exception %@: %@", exception.name, exception.reason];
            [self sendErrorMessage: msg];
        }
    }
    
- (void)startNetverify:(CDVInvokedUrlCommand*)command
    {
        self.callbackId = command.callbackId;
        
        if (self.netverifyViewController == nil) {
            [self sendErrorMessage: @"The Netverify SDK is not initialized yet. Call initNetverify() first."];
            return;
        }
        
        [self.viewController presentViewController: self.netverifyViewController animated: YES completion: nil];
    }
    
#pragma mark - Document Verification
    
- (void)initDocumentVerification:(CDVInvokedUrlCommand*)command
    {
        self.callbackId = command.callbackId;
        
        NSUInteger argc = [command.arguments count];
        if (argc < 3) {
            [self sendErrorMessage: @"Missing required parameters apiToken, apiSecret or dataCenter."];
            return;
        }
        
        NSString *apiToken = [command.arguments objectAtIndex: 0];
        NSString *apiSecret = [command.arguments objectAtIndex: 1];
        NSString *dataCenterString = [command.arguments objectAtIndex: 2];
        NSString *dataCenterLowercase = [dataCenterString lowercaseString];
        JumioDataCenter dataCenter = ([dataCenterLowercase isEqualToString: @"us"]) ? JumioDataCenterUS : JumioDataCenterEU;
        
        // Initialization
        self.documentVerifcationConfiguration = [DocumentVerificationConfiguration new];
        self.documentVerifcationConfiguration.delegate = self;
        self.documentVerifcationConfiguration.merchantApiToken = apiToken;
        self.documentVerifcationConfiguration.merchantApiSecret = apiSecret;
        self.documentVerifcationConfiguration.dataCenter = dataCenter;
        
        // Configuration
        NSDictionary *options = [command.arguments objectAtIndex: 3];
        if (![options isEqual:[NSNull null]]) {
            for (NSString *key in options) {
                if ([key isEqualToString: @"type"]) {
                    self.documentVerifcationConfiguration.type = [options objectForKey: key];
                } else if ([key isEqualToString: @"customDocumentCode"]) {
                    self.documentVerifcationConfiguration.customDocumentCode = [options objectForKey: key];
                } else if ([key isEqualToString: @"country"]) {
                    self.documentVerifcationConfiguration.country = [options objectForKey: key];
                } else if ([key isEqualToString: @"merchantReportingCriteria"]) {
                    self.documentVerifcationConfiguration.merchantReportingCriteria = [options objectForKey: key];
                } else if ([key isEqualToString: @"callbackUrl"]) {
                    self.documentVerifcationConfiguration.callbackUrl = [options objectForKey: key];
                } else if ([key isEqualToString: @"merchantScanReference"]) {
                    self.documentVerifcationConfiguration.merchantScanReference = [options objectForKey: key];
                } else if ([key isEqualToString: @"customerId"]) {
                    self.documentVerifcationConfiguration.customerId = [options objectForKey: key];
                } else if ([key isEqualToString: @"enableExtraction"]) {
                    self.documentVerifcationConfiguration.enableExtraction = [options objectForKey: key];
                } else if ([key isEqualToString: @"documentName"]) {
                    self.documentVerifcationConfiguration.documentName = [options objectForKey: key];
                } else if ([key isEqualToString: @"cameraPosition"]) {
                    NSString *cameraString = [[options objectForKey: key] lowercaseString];
                    JumioCameraPosition cameraPosition = ([cameraString isEqualToString: @"front"]) ? JumioCameraPositionFront : JumioCameraPositionBack;
                    self.documentVerifcationConfiguration.cameraPosition = cameraPosition;
                }
            }
        }
        
        // Customization
        NSDictionary *customization = [command.arguments objectAtIndex: 4];
        if (![customization isEqual:[NSNull null]]) {
            for (NSString *key in customization) {
                if ([key isEqualToString: @"disableBlur"]) {
                    [[NetverifyBaseView netverifyAppearance] setDisableBlur: @YES];
                } else {
                    UIColor *color = [self colorWithHexString: [customization objectForKey: key]];
                    
                    if ([key isEqualToString: @"backgroundColor"]) {
                        [[NetverifyBaseView netverifyAppearance] setBackgroundColor: color];
                    } else if ([key isEqualToString: @"tintColor"]) {
                        [[UINavigationBar netverifyAppearance] setTintColor: color];
                    } else if ([key isEqualToString: @"barTintColor"]) {
                        [[UINavigationBar netverifyAppearance] setBarTintColor: color];
                    } else if ([key isEqualToString: @"textTitleColor"]) {
                        [[UINavigationBar netverifyAppearance] setTitleTextAttributes: @{NSForegroundColorAttributeName: color}];
                    } else if ([key isEqualToString: @"foregroundColor"]) {
                        [[NetverifyBaseView netverifyAppearance] setForegroundColor: color];
                    } else if ([key isEqualToString: @"positiveButtonBackgroundColor"]) {
                        [[NetverifyPositiveButton netverifyAppearance] setBackgroundColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"positiveButtonBorderColor"]) {
                        [[NetverifyPositiveButton netverifyAppearance] setBorderColor: color];
                    } else if ([key isEqualToString: @"positiveButtonTitleColor"]) {
                        [[NetverifyPositiveButton netverifyAppearance] setTitleColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"negativeButtonBackgroundColor"]) {
                        [[NetverifyNegativeButton netverifyAppearance] setBackgroundColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"negativeButtonBorderColor"]) {
                        [[NetverifyNegativeButton netverifyAppearance] setBorderColor: color];
                    } else if ([key isEqualToString: @"negativeButtonTitleColor"]) {
                        [[NetverifyNegativeButton netverifyAppearance] setTitleColor: color forState:UIControlStateNormal];
                    }
                }
            }
        }
        
        @try {
            self.documentVerificationViewController = [[DocumentVerificationViewController alloc] initWithConfiguration: self.documentVerifcationConfiguration];
        } @catch (NSException *exception) {
            NSString *msg = [NSString stringWithFormat: @"Cancelled with exception %@: %@", exception.name, exception.reason];
            [self sendErrorMessage: msg];
        }
    }
    
- (void)startDocumentVerification:(CDVInvokedUrlCommand*)command
    {
        self.callbackId = command.callbackId;
        
        if (self.documentVerificationViewController == nil) {
            [self sendErrorMessage: @"The Document-Verification SDK is not initialized yet. Call initDocumentVerification() first."];
            return;
        }
        
        [self.viewController presentViewController: self.documentVerificationViewController animated: YES completion: nil];
    }
    
    
#pragma mark - BAM Checkout Delegates
    
- (void) bamCheckoutViewController:(BAMCheckoutViewController *)controller didFinishScanWithCardInformation:(BAMCheckoutCardInformation *)cardInformation scanReference:(NSString *)scanReference {
    NSDictionary *result = [[NSMutableDictionary alloc] init];
    
    if (cardInformation.cardType == BAMCheckoutCreditCardTypeVisa) {
        [result setValue: @"VISA" forKey: @"cardType"];
    } else if (cardInformation.cardType == BAMCheckoutCreditCardTypeMasterCard) {
        [result setValue: @"MASTER_CARD" forKey: @"cardType"];
    } else if (cardInformation.cardType == BAMCheckoutCreditCardTypeAmericanExpress) {
        [result setValue: @"AMERICAN_EXPRESS" forKey: @"cardType"];
    } else if (cardInformation.cardType == BAMCheckoutCreditCardTypeChinaUnionPay) {
        [result setValue: @"CHINA_UNIONPAY" forKey: @"cardType"];
    } else if (cardInformation.cardType == BAMCheckoutCreditCardTypeDiners) {
        [result setValue: @"DINERS_CLUB" forKey: @"cardType"];
    } else if (cardInformation.cardType == BAMCheckoutCreditCardTypeDiscover) {
        [result setValue: @"DISCOVER" forKey: @"cardType"];
    } else if (cardInformation.cardType == BAMCheckoutCreditCardTypeJCB) {
        [result setValue: @"JCB" forKey: @"cardType"];
    } else if (cardInformation.cardType == BAMCheckoutCreditCardTypeStarbucks) {
        [result setValue: @"STARBUCKS" forKey: @"cardType"];
    }
    
    [result setValue: cardInformation.cardNumber forKey: @"cardNumber"];
    [result setValue: cardInformation.cardNumberGrouped forKey: @"cardNumberGrouped"];
    [result setValue: cardInformation.cardNumberMasked forKey: @"cardNumberMasked"];
    [result setValue: cardInformation.cardExpiryMonth forKey: @"cardExpiryMonth"];
    [result setValue: cardInformation.cardExpiryYear forKey: @"cardExpiryYear"];
    [result setValue: cardInformation.cardExpiryDate forKey: @"cardExpiryDate"];
    [result setValue: cardInformation.cardCVV forKey: @"cardCVV"];
    [result setValue: cardInformation.cardHolderName forKey: @"cardHolderName"];
    [result setValue: cardInformation.cardSortCode forKey: @"cardSortCode"];
    [result setValue: cardInformation.cardAccountNumber forKey: @"cardAccountNumber"];
    [result setValue: [NSNumber numberWithBool: cardInformation.cardSortCodeValid] forKey: @"cardSortCodeValid"];
    [result setValue: [NSNumber numberWithBool: cardInformation.cardAccountNumberValid] forKey: @"cardAccountNumberValid"];
	
	[result setValue: scanReference forKey: @"scanReference"];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: result];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}
    
- (void) bamCheckoutViewController:(BAMCheckoutViewController *)controller didCancelWithError:(NSError *)error scanReference:(NSString *)scanReference {
    [self sendError: error scanReference: scanReference];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}
    
#pragma mark - Netverify Delegates
    
- (void)netverifyViewController:(NetverifyViewController *)netverifyViewController didFinishWithDocumentData:(NetverifyDocumentData *)documentData scanReference:(NSString *)scanReference {
    NSDictionary *result = [[NSMutableDictionary alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    
    [result setValue: documentData.selectedCountry forKey: @"selectedCountry"];
    if (documentData.selectedDocumentType == NetverifyDocumentTypePassport) {
        [result setValue: @"PASSPORT" forKey: @"selectedDocumentType"];
    } else if (documentData.selectedDocumentType == NetverifyDocumentTypeDriverLicense) {
        [result setValue: @"DRIVER_LICENSE" forKey: @"selectedDocumentType"];
    } else if (documentData.selectedDocumentType == NetverifyDocumentTypeIdentityCard) {
        [result setValue: @"IDENTITY_CARD" forKey: @"selectedDocumentType"];
    } else if (documentData.selectedDocumentType == NetverifyDocumentTypeVisa) {
        [result setValue: @"VISA" forKey: @"selectedDocumentType"];
    }
    [result setValue: documentData.idNumber forKey: @"idNumber"];
    [result setValue: documentData.personalNumber forKey: @"personalNumber"];
    [result setValue: [formatter stringFromDate: documentData.issuingDate] forKey: @"issuingDate"];
    [result setValue: [formatter stringFromDate: documentData.expiryDate] forKey: @"expiryDate"];
    [result setValue: documentData.issuingCountry forKey: @"issuingCountry"];
    [result setValue: documentData.lastName forKey: @"lastName"];
    [result setValue: documentData.firstName forKey: @"firstName"];
    [result setValue: documentData.middleName forKey: @"middleName"];
    [result setValue: [formatter stringFromDate: documentData.dob] forKey: @"dob"];
    if (documentData.gender == NetverifyGenderM) {
        [result setValue: @"m" forKey: @"gender"];
    } else if (documentData.gender == NetverifyGenderF) {
        [result setValue: @"f" forKey: @"gender"];
    } else if (documentData.gender == NetverifyGenderX) {
        [result setValue: @"x" forKey: @"gender"];
    }
    [result setValue: documentData.originatingCountry forKey: @"originatingCountry"];
    [result setValue: documentData.addressLine forKey: @"addressLine"];
    [result setValue: documentData.city forKey: @"city"];
    [result setValue: documentData.subdivision forKey: @"subdivision"];
    [result setValue: documentData.postCode forKey: @"postCode"];
    [result setValue: documentData.optionalData1 forKey: @"optionalData1"];
    [result setValue: documentData.optionalData2 forKey: @"optionalData2"];
    if (documentData.extractionMethod == NetverifyExtractionMethodMRZ) {
        [result setValue: @"MRZ" forKey: @"extractionMethod"];
    } else if (documentData.extractionMethod == NetverifyExtractionMethodOCR) {
        [result setValue: @"OCR" forKey: @"extractionMethod"];
    } else if (documentData.extractionMethod == NetverifyExtractionMethodBarcode) {
        [result setValue: @"BARCODE" forKey: @"extractionMethod"];
    } else if (documentData.extractionMethod == NetverifyExtractionMethodBarcodeOCR) {
        [result setValue: @"BARCODE_OCR" forKey: @"extractionMethod"];
    } else if (documentData.extractionMethod == NetverifyExtractionMethodNone) {
        [result setValue: @"NONE" forKey: @"extractionMethod"];
    }
    
    // MRZ data if available
    if (documentData.mrzData != nil) {
        NSDictionary *mrzData = [[NSMutableDictionary alloc] init];
        if (documentData.mrzData.format == NetverifyMRZFormatMRP) {
            [mrzData setValue: @"MRP" forKey: @"format"];
        } else if (documentData.mrzData.format == NetverifyMRZFormatTD1) {
            [mrzData setValue: @"TD1" forKey: @"format"];
        } else if (documentData.mrzData.format == NetverifyMRZFormatTD2) {
            [mrzData setValue: @"TD2" forKey: @"format"];
        } else if (documentData.mrzData.format == NetverifyMRZFormatCNIS) {
            [mrzData setValue: @"CNIS" forKey: @"format"];
        } else if (documentData.mrzData.format == NetverifyMRZFormatMRVA) {
            [mrzData setValue: @"MRVA" forKey: @"format"];
        } else if (documentData.mrzData.format == NetverifyMRZFormatMRVB) {
            [mrzData setValue: @"MRVB" forKey: @"format"];
        } else if (documentData.mrzData.format == NetverifyMRZFormatUnknown) {
            [mrzData setValue: @"UNKNOWN" forKey: @"format"];
        }
        
        [mrzData setValue: documentData.mrzData.line1 forKey: @"line1"];
        [mrzData setValue: documentData.mrzData.line2 forKey: @"line2"];
        [mrzData setValue: documentData.mrzData.line3 forKey: @"line3"];
        [mrzData setValue: [NSNumber numberWithBool: documentData.mrzData.idNumberValid] forKey: @"idNumberValid"];
        [mrzData setValue: [NSNumber numberWithBool: documentData.mrzData.dobValid] forKey: @"dobValid"];
        [mrzData setValue: [NSNumber numberWithBool: documentData.mrzData.expiryDateValid] forKey: @"expiryDateValid"];
        [mrzData setValue: [NSNumber numberWithBool: documentData.mrzData.personalNumberValid] forKey: @"personalNumberValid"];
        [mrzData setValue: [NSNumber numberWithBool: documentData.mrzData.compositeValid] forKey: @"compositeValid"];
        [result setValue: mrzData forKey: @"mrzData"];
    }
    
	[result setValue: scanReference forKey: @"scanReference"];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: result];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}
    
- (void)netverifyViewController:(NetverifyViewController *)netverifyViewController didFinishInitializingWithError:(NetverifyError *)error {
    if (error != nil) {
        [self sendNetverifyError: error scanReference: nil];
    }
}
    
- (void)netverifyViewController:(NetverifyViewController *)netverifyViewController didCancelWithError:(NetverifyError *)error scanReference:(NSString *)scanReference {
    [self sendNetverifyError: error scanReference: scanReference];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark - Document Verification Delegates
    
- (void) documentVerificationViewController:(DocumentVerificationViewController *)documentVerificationViewController didFinishWithScanReference:(NSString *)scanReference {
    NSDictionary *result = [NSDictionary dictionaryWithObject: scanReference forKey: @"scanReference"];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsDictionary: result];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}
    
- (void) documentVerificationViewController:(DocumentVerificationViewController *)documentVerificationViewController didFinishWithError:(DocumentVerificationError *)error {
    [self sendDocumentVerificationError: error scanReference: nil];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}
    
    
#pragma mark - Helper Methods


- (void) sendErrorMessage: (NSString *)errorMessage {
    NSDictionary* result = [NSDictionary dictionaryWithObject: errorMessage forKey: @"errorMessage"];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsDictionary: result];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}

- (void)sendError:(NSError *)error scanReference:(NSString *)scanReference {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setValue: [NSNumber numberWithInteger: error.code] forKey: @"errorCode"];
    [result setValue: error.localizedDescription forKey: @"errorMessage"];
    if (scanReference) {
        [result setValue: scanReference forKey: @"scanReference"];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsDictionary: result];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}

- (void)sendNetverifyError:(NetverifyError *)error scanReference:(NSString *)scanReference {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setValue: error.code forKey: @"errorCode"];
    [result setValue: error.message forKey: @"errorMessage"];
    if (scanReference) {
        [result setValue: scanReference forKey: @"scanReference"];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsDictionary: result];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}

- (void)sendDocumentVerificationError:(DocumentVerificationError *)error scanReference:(NSString *)scanReference {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setValue: error.code forKey: @"errorCode"];
    [result setValue: error.message forKey: @"errorMessage"];
    if (scanReference) {
        [result setValue: scanReference forKey: @"scanReference"];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsDictionary: result];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}
    
- (BOOL) getBoolValue:(NSObject *)value {
    if (value && [value isKindOfClass: [NSNumber class]]) {
        return [((NSNumber *)value) boolValue];
    }
    return value;
}
    
- (UIColor *)colorWithHexString:(NSString *)str_HEX {
    int red = 0;
    int green = 0;
    int blue = 0;
    sscanf([str_HEX UTF8String], "#%02X%02X%02X", &red, &green, &blue);
    return  [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}
    
    @end
