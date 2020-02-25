//
//  JumioMobileSDK.h
//  Jumio Software Development GmbH
//

#import "JumioMobileSDK.h"

@interface JumioMobileSDK ()

@property (nonatomic, assign) BOOL initiateSuccessfulBAMCheckout;
@property (nonatomic, assign) BOOL initiateSuccessfulNetverify;
@property (nonatomic, assign) BOOL initiateSuccessfulDocumentVerification;
@property (nonatomic, assign) BOOL initiateSuccessfulAuthentication;

@end

@implementation JumioMobileSDK
    
#pragma mark - BAM Checkout
    
- (void)initBAM:(CDVInvokedUrlCommand*)command
    {
        self.initiateSuccessfulBAMCheckout = NO;
        self.callbackId = command.callbackId;
        
        NSUInteger argc = [command.arguments count];
        if (argc < 3) {
            [self sendErrorMessage: @"Missing required parameters apiToken, apiSecret or dataCenter."];
            return;
        }
        
        NSString *apiToken = [command.arguments objectAtIndex: 0];
        NSString *apiSecret = [command.arguments objectAtIndex: 1];
        NSString *dataCenterString = [command.arguments objectAtIndex: 2];
        
        JumioDataCenter jumioDataCenter = JumioDataCenterUS;
        NSString *dataCenterLowercase = [dataCenterString lowercaseString];
        
        if ([dataCenterLowercase isEqualToString: @"eu"]) {
          jumioDataCenter = JumioDataCenterEU;
        } else if ([dataCenterLowercase isEqualToString: @"sg"]) {
          jumioDataCenter = JumioDataCenterSG;
        }
        
        // Initialization
        self.bamConfiguration = [BAMCheckoutConfiguration new];
        self.bamConfiguration.delegate = self;
        self.bamConfiguration.apiToken = apiToken;
        self.bamConfiguration.apiSecret = apiSecret;
        self.bamConfiguration.dataCenter = jumioDataCenter;
        
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
                } else if ([key isEqualToString: @"reportingCriteria"]) {
                    self.bamConfiguration.reportingCriteria = [options objectForKey: key];
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
                    BOOL disableBlur = [self getBoolValue:[customization objectForKey: key]];
                    [[BAMCheckoutBaseView jumioAppearance] setDisableBlur: disableBlur ? @YES : @NO];
                } else {
                    UIColor *color = [self colorWithHexString: [customization objectForKey: key]];
                    
                    if ([key isEqualToString: @"backgroundColor"]) {
                        [[BAMCheckoutBaseView jumioAppearance] setBackgroundColor: color];
                    } else if ([key isEqualToString: @"tintColor"]) {
                        [[UINavigationBar jumioAppearance] setTintColor: color];
                    } else if ([key isEqualToString: @"barTintColor"]) {
                        [[UINavigationBar jumioAppearance] setBarTintColor: color];
                    } else if ([key isEqualToString: @"textTitleColor"]) {
                        [[UINavigationBar jumioAppearance] setTitleTextAttributes: @{NSForegroundColorAttributeName: color}];
                    } else if ([key isEqualToString: @"foregroundColor"]) {
                        [[BAMCheckoutBaseView jumioAppearance] setForegroundColor: color];
                    } else if ([key isEqualToString: @"positiveButtonBackgroundColor"]) {
                        [[BAMCheckoutPositiveButton jumioAppearance] setBackgroundColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"positiveButtonBorderColor"]) {
                        [[BAMCheckoutPositiveButton jumioAppearance] setBorderColor: color];
                    } else if ([key isEqualToString: @"positiveButtonTitleColor"]) {
                        [[BAMCheckoutPositiveButton jumioAppearance] setTitleColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"negativeButtonBackgroundColor"]) {
                        [[BAMCheckoutNegativeButton jumioAppearance] setBackgroundColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"negativeButtonBorderColor"]) {
                        [[BAMCheckoutNegativeButton jumioAppearance] setBorderColor: color];
                    } else if ([key isEqualToString: @"negativeButtonTitleColor"]) {
                        [[BAMCheckoutNegativeButton jumioAppearance] setTitleColor: color forState:UIControlStateNormal];
                    }  else if ([key isEqualToString: @"scanOverlayTextColor"]) {
                        [[BAMCheckoutScanOverlay jumioAppearance] setTextColor: color];
                    }  else if ([key isEqualToString: @"scanOverlayBorderColor"]) {
                        [[BAMCheckoutScanOverlay jumioAppearance] setBorderColor: color];
                    }
                }
            }
        }

        @try {
            self.bamViewController = [[BAMCheckoutViewController alloc] initWithConfiguration: self.bamConfiguration];
            self.initiateSuccessfulBAMCheckout = YES;
        } @catch (NSException *exception) {
            NSString *msg = [NSString stringWithFormat: @"Cancelled with exception %@: %@", exception.name, exception.reason];
            [self sendErrorMessage: msg];
        }
    }
    
- (void)startBAM:(CDVInvokedUrlCommand*)command
    {
        self.callbackId = command.callbackId;
        
        if (self.bamViewController == nil && self.initiateSuccessfulBAMCheckout == NO) {
            [self sendErrorMessage: @"The BAM SDK is not initialized yet. Call initBAM() first."];
            return;
        }
        
        [self.viewController presentViewController: self.bamViewController animated: YES completion: nil];
    }
    
#pragma mark - Netverify
    
- (void)initNetverify:(CDVInvokedUrlCommand*)command {
        self.callbackId = command.callbackId;
        self.initiateSuccessfulNetverify = NO;
        
        NSUInteger argc = [command.arguments count];
        if (argc < 3) {
            [self sendErrorMessage: @"Missing required parameters apiToken, apiSecret or dataCenter."];
            return;
        }
        
        NSString *apiToken = [command.arguments objectAtIndex: 0];
        NSString *apiSecret = [command.arguments objectAtIndex: 1];
        NSString *dataCenterString = [command.arguments objectAtIndex: 2];

        JumioDataCenter jumioDataCenter = JumioDataCenterUS;
        NSString *dataCenterLowercase = [dataCenterString lowercaseString];
        
        if ([dataCenterLowercase isEqualToString: @"eu"]) {
          jumioDataCenter = JumioDataCenterEU;
        } else if ([dataCenterLowercase isEqualToString: @"sg"]) {
          jumioDataCenter = JumioDataCenterSG;
        }
        
        // Initialization
        self.netverifyConfiguration = [NetverifyConfiguration new];
        self.netverifyConfiguration.delegate = self;
        self.netverifyConfiguration.apiToken = apiToken;
        self.netverifyConfiguration.apiSecret = apiSecret;
        self.netverifyConfiguration.dataCenter = jumioDataCenter;
        
        // Configuration
        NSDictionary *options = [command.arguments objectAtIndex: 3];
        if (![options isEqual:[NSNull null]]) {
            for (NSString *key in options) {
                if ([key isEqualToString: @"enableVerification"]) {
                    self.netverifyConfiguration.enableVerification = [self getBoolValue: [options objectForKey: key]];
                } else if ([key isEqualToString: @"callbackUrl"]) {
                    self.netverifyConfiguration.callbackUrl = [options objectForKey: key];
                } else if ([key isEqualToString: @"enableIdentityVerification"]) {
                    self.netverifyConfiguration.enableIdentityVerification = [self getBoolValue: [options objectForKey: key]];
                } else if ([key isEqualToString: @"preselectedCountry"]) {
                    self.netverifyConfiguration.preselectedCountry = [options objectForKey: key];
                } else if ([key isEqualToString: @"customerInternalReference"]) {
                    self.netverifyConfiguration.customerInternalReference = [options objectForKey: key];
                } else if ([key isEqualToString: @"enableWatchlistScreening"]) {
                    NSString* watchlistScreeningValue = [[options objectForKey: key] lowercaseString];
                    if ([watchlistScreeningValue isEqualToString:@"enabled"]) {
                        self.netverifyConfiguration.watchlistScreening = NetverifyWatchlistScreeningEnabled;
                    } else if ([watchlistScreeningValue isEqualToString:@"disabled"]) {
                        self.netverifyConfiguration.watchlistScreening = NetverifyWatchlistScreeningDisabled;
                    } else {
                        self.netverifyConfiguration.watchlistScreening = NetverifyWatchlistScreeningDefault;
                    }
                } else if ([key isEqualToString: @"watchlistSearchProfile"]) {
                    self.netverifyConfiguration.watchlistSearchProfile = [options objectForKey: key];
                } else if ([key isEqualToString: @"reportingCriteria"]) {
                    self.netverifyConfiguration.reportingCriteria = [options objectForKey: key];
                } else if ([key isEqualToString: @"userReference"]) {
                    self.netverifyConfiguration.userReference = [options objectForKey: key];
                } else if ([key isEqualToString: @"sendDebugInfoToJumio"]) {
                    self.netverifyConfiguration.sendDebugInfoToJumio = [self getBoolValue: [options objectForKey: key]];
                } else if ([key isEqualToString: @"dataExtractionOnMobileOnly"]) {
                    self.netverifyConfiguration.dataExtractionOnMobileOnly = [self getBoolValue:[options objectForKey: key]];
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
                    BOOL disableBlur = [self getBoolValue:[customization objectForKey: key]];
                    [[NetverifyBaseView jumioAppearance] setDisableBlur: disableBlur ? @YES : @NO];

                } else if ([key isEqualToString: @"enableDarkMode"]) {
                    BOOL enableDarkMode = [self getBoolValue:[customization objectForKey: key]];
                    [[NetverifyBaseView jumioAppearance] setEnableDarkMode: enableDarkMode ? @YES : @NO];
                } else {
                    UIColor *color = [self colorWithHexString: [customization objectForKey: key]];
                    
                    if ([key isEqualToString: @"backgroundColor"]) {
                        [[NetverifyBaseView jumioAppearance] setBackgroundColor: color];
                    } else if ([key isEqualToString: @"tintColor"]) {
                        [[UINavigationBar jumioAppearance] setTintColor: color];
                    } else if ([key isEqualToString: @"barTintColor"]) {
                        [[UINavigationBar jumioAppearance] setBarTintColor: color];
                    } else if ([key isEqualToString: @"textTitleColor"]) {
                        [[UINavigationBar jumioAppearance] setTitleTextAttributes: @{NSForegroundColorAttributeName: color}];
                    } else if ([key isEqualToString: @"foregroundColor"]) {
                        [[NetverifyBaseView jumioAppearance] setForegroundColor: color];
                    } else if ([key isEqualToString: @"documentSelectionHeaderBackgroundColor"]) {
                        [[NetverifyDocumentSelectionHeaderView jumioAppearance] setBackgroundColor: color];
                    } else if ([key isEqualToString: @"documentSelectionHeaderTitleColor"]) {
                        [[NetverifyDocumentSelectionHeaderView jumioAppearance] setTitleColor: color];
                    } else if ([key isEqualToString: @"documentSelectionHeaderIconColor"]) {
                        [[NetverifyDocumentSelectionHeaderView jumioAppearance] setIconColor: color];
                    } else if ([key isEqualToString: @"documentSelectionButtonBackgroundColor"]) {
                        [[NetverifyDocumentSelectionButton jumioAppearance] setBackgroundColor: color forState: UIControlStateNormal];
                    } else if ([key isEqualToString: @"documentSelectionButtonTitleColor"]) {
                        [[NetverifyDocumentSelectionButton jumioAppearance] setTitleColor: color forState: UIControlStateNormal];
                    } else if ([key isEqualToString: @"documentSelectionButtonIconColor"]) {
                        [[NetverifyDocumentSelectionButton jumioAppearance] setIconColor: color forState: UIControlStateNormal];
                    } else if ([key isEqualToString: @"fallbackButtonBackgroundColor"]) {
                        [[NetverifyFallbackButton jumioAppearance] setBackgroundColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"fallbackButtonBorderColor"]) {
                        [[NetverifyFallbackButton jumioAppearance] setBorderColor: color];
                    } else if ([key isEqualToString: @"fallbackButtonTitleColor"]) {
                        [[NetverifyFallbackButton jumioAppearance] setTitleColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"positiveButtonBackgroundColor"]) {
                        [[NetverifyPositiveButton jumioAppearance] setBackgroundColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"positiveButtonBorderColor"]) {
                        [[NetverifyPositiveButton jumioAppearance] setBorderColor: color];
                    } else if ([key isEqualToString: @"positiveButtonTitleColor"]) {
                        [[NetverifyPositiveButton jumioAppearance] setTitleColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"negativeButtonBackgroundColor"]) {
                        [[NetverifyNegativeButton jumioAppearance] setBackgroundColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"negativeButtonBorderColor"]) {
                        [[NetverifyNegativeButton jumioAppearance] setBorderColor: color];
                    } else if ([key isEqualToString: @"negativeButtonTitleColor"]) {
                        [[NetverifyNegativeButton jumioAppearance] setTitleColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"scanOverlayStandardColor"]) {
                        [[NetverifyScanOverlayView jumioAppearance] setColorOverlayStandard: color];
                    } else if ([key isEqualToString: @"scanOverlayValidColor"]) {
                        [[NetverifyScanOverlayView jumioAppearance] setColorOverlayValid: color];
                    } else if ([key isEqualToString: @"scanOverlayInvalidColor"]) {
                        [[NetverifyScanOverlayView jumioAppearance] setColorOverlayInvalid: color];
                    } else if ([key isEqualToString: @"scanBackgroundColor"]) {
                        [[NetverifyScanOverlayView jumioAppearance] setScanBackgroundColor: color];
                    } else if ([key isEqualToString: @"faceOvalColor"]) {
                        [[NetverifyScanOverlayView jumioAppearance] setFaceOvalColor: color];
                    } else if ([key isEqualToString: @"faceProgressColor"]) {
                         [[NetverifyScanOverlayView jumioAppearance] setFaceProgressColor: color];
                    } else if ([key isEqualToString: @"faceFeedbackBackgroundColor"]) {
                         [[NetverifyScanOverlayView jumioAppearance] setFaceFeedbackBackgroundColor: color];
                    } else if ([key isEqualToString: @"faceFeedbackTextColor"]) {
                         [[NetverifyScanOverlayView jumioAppearance] setFaceFeedbackTextColor: color];
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
        
        if (self.netverifyViewController == nil && self.initiateSuccessfulNetverify == NO) {
            [self sendErrorMessage: @"The Netverify SDK is not initialized yet. Call initNetverify() first."];
            return;
        }
        
        [self.viewController presentViewController: self.netverifyViewController animated: YES completion: nil];
    }

#pragma mark - Authentication

- (void)initAuthentication:(CDVInvokedUrlCommand*)command {
    self.initiateSuccessfulAuthentication = NO;
    self.authenticationController = nil;
    self.authenticationScanViewController = nil;
    self.authenticationConfiguration = nil;
    
    self.callbackId = command.callbackId;
        
    NSUInteger argc = [command.arguments count];
    if (argc < 3) {
        [self sendErrorMessage: @"Missing required parameters apiToken, apiSecret or dataCenter."];
        return;
    }
    
    NSString *apiToken = [command.arguments objectAtIndex: 0];
    NSString *apiSecret = [command.arguments objectAtIndex: 1];
    NSString *dataCenterString = [command.arguments objectAtIndex: 2];

    JumioDataCenter jumioDataCenter = JumioDataCenterUS;
    NSString *dataCenterLowercase = [dataCenterString lowercaseString];
    
    if ([dataCenterLowercase isEqualToString: @"eu"]) {
      jumioDataCenter = JumioDataCenterEU;
    } else if ([dataCenterLowercase isEqualToString: @"sg"]) {
      jumioDataCenter = JumioDataCenterSG;
    }
    
    // Initialization
    self.authenticationConfiguration = [AuthenticationConfiguration new];
    self.authenticationConfiguration.delegate = self;
    self.authenticationConfiguration.apiToken = apiToken;
    self.authenticationConfiguration.apiSecret = apiSecret;
    self.authenticationConfiguration.dataCenter = jumioDataCenter;

    // Configuration
    NSString *enrollmentTransactionReference = nil;
    NSString *authenticationTransactionReference = nil;
    
    NSDictionary *configuration = [command.arguments objectAtIndex: 3];
    if (![configuration isEqual:[NSNull null]]) {
        for (NSString *key in configuration) {
            if ([key isEqualToString: @"enrollmentTransactionReference"]) {
                enrollmentTransactionReference = [configuration objectForKey: key];
            } else if ([key isEqualToString:@"authenticationTransactionReference"]) {
                authenticationTransactionReference = [configuration objectForKey:key];
            } else if ([key isEqualToString: @"callbackUrl"]) {
                self.authenticationConfiguration.callbackUrl = [configuration objectForKey: key];
            } else if ([key isEqualToString:@"userReference"]) {
                self.authenticationConfiguration.userReference = [configuration objectForKey:key];
            }
        }
    }
    
    // Customization
    NSDictionary *customization = [command.arguments objectAtIndex: 4];
    if (![customization isEqual:[NSNull null]]) {
        for (NSString *key in customization) {
            if ([key isEqualToString: @"disableBlur"]) {
                BOOL disableBlur = [self getBoolValue:[customization objectForKey: key]];
                [[JumioBaseView jumioAppearance] setDisableBlur: disableBlur ? @YES : @NO];
            } else if ([key isEqualToString: @"enableDarkMode"]) {
                BOOL enableDarkMode = [self getBoolValue:[customization objectForKey: key]];
                [[JumioBaseView jumioAppearance] setEnableDarkMode: enableDarkMode ? @YES : @NO];
            } else {
                UIColor *color = [self colorWithHexString: [customization objectForKey: key]];
                
                if ([key isEqualToString: @"backgroundColor"]) {
                    [[JumioBaseView jumioAppearance] setBackgroundColor: color];
                } else if ([key isEqualToString: @"tintColor"]) {
                    [[UINavigationBar jumioAppearance] setTintColor: color];
                } else if ([key isEqualToString: @"barTintColor"]) {
                    [[UINavigationBar jumioAppearance] setBarTintColor: color];
                } else if ([key isEqualToString: @"textTitleColor"]) {
                    [[UINavigationBar jumioAppearance] setTitleTextAttributes: @{NSForegroundColorAttributeName: color}];
                } else if ([key isEqualToString: @"foregroundColor"]) {
                    [[JumioBaseView jumioAppearance] setForegroundColor: color];
                } else if ([key isEqualToString: @"positiveButtonBackgroundColor"]) {
                    [[JumioPositiveButton jumioAppearance] setBackgroundColor: color forState:UIControlStateNormal];
                } else if ([key isEqualToString: @"positiveButtonBorderColor"]) {
                    [[JumioPositiveButton jumioAppearance] setBorderColor: color];
                } else if ([key isEqualToString: @"positiveButtonTitleColor"]) {
                    [[JumioPositiveButton jumioAppearance] setTitleColor: color forState:UIControlStateNormal];
                } else if ([key isEqualToString: @"faceOvalColor"]) {
                    [[JumioScanOverlayView jumioAppearance] setFaceOvalColor: color];
                } else if ([key isEqualToString: @"faceProgressColor"]) {
                     [[JumioScanOverlayView jumioAppearance] setFaceProgressColor: color];
                } else if ([key isEqualToString: @"faceFeedbackBackgroundColor"]) {
                     [[JumioScanOverlayView jumioAppearance] setFaceFeedbackBackgroundColor: color];
                } else if ([key isEqualToString: @"faceFeedbackTextColor"]) {
                     [[JumioScanOverlayView jumioAppearance] setFaceFeedbackTextColor: color];
                }
            }
        }
    }

    if (enrollmentTransactionReference != nil || authenticationTransactionReference != nil){
        if (authenticationTransactionReference != nil) {
        self.authenticationConfiguration.authenticationTransactionReference = authenticationTransactionReference;
        } else {
        self.authenticationConfiguration.enrollmentTransactionReference = enrollmentTransactionReference;
        }
        
        @try {
            self.authenticationController = [[AuthenticationController alloc] initWithConfiguration:self.authenticationConfiguration];
        } @catch (NSException *exception) {
            NSString *msg = [NSString stringWithFormat: @"Cancelled with exception %@: %@", exception.name, exception.reason];
            [self sendErrorMessage: msg];
        }
    }        
}

- (void)startAuthentication:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    
    if (self.authenticationController == nil && self.initiateSuccessfulAuthentication == NO) {
        [self sendErrorMessage: @"The Authentication SDK has not been initialized yet."];
        return;
    }
    
    [self.viewController presentViewController: self.authenticationScanViewController animated: YES completion: nil];
}
    
#pragma mark - Document Verification
    
- (void)initDocumentVerification:(CDVInvokedUrlCommand*)command
    {
        self.callbackId = command.callbackId;
        self.initiateSuccessfulDocumentVerification = NO;
        
        NSUInteger argc = [command.arguments count];
        if (argc < 3) {
            [self sendErrorMessage: @"Missing required parameters apiToken, apiSecret or dataCenter."];
            return;
        }
        
        NSString *apiToken = [command.arguments objectAtIndex: 0];
        NSString *apiSecret = [command.arguments objectAtIndex: 1];
        NSString *dataCenterString = [command.arguments objectAtIndex: 2];

        JumioDataCenter jumioDataCenter = JumioDataCenterUS;
        NSString *dataCenterLowercase = [dataCenterString lowercaseString];
        
        if ([dataCenterLowercase isEqualToString: @"eu"]) {
          jumioDataCenter = JumioDataCenterEU;
        } else if ([dataCenterLowercase isEqualToString: @"sg"]) {
          jumioDataCenter = JumioDataCenterSG;
        }
        
        // Initialization
        self.documentVerifcationConfiguration = [DocumentVerificationConfiguration new];
        self.documentVerifcationConfiguration.delegate = self;
        self.documentVerifcationConfiguration.apiToken = apiToken;
        self.documentVerifcationConfiguration.apiSecret = apiSecret;
        self.documentVerifcationConfiguration.dataCenter = jumioDataCenter;
        
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
                } else if ([key isEqualToString: @"reportingCriteria"]) {
                    self.documentVerifcationConfiguration.reportingCriteria = [options objectForKey: key];
                } else if ([key isEqualToString: @"callbackUrl"]) {
                    self.documentVerifcationConfiguration.callbackUrl = [options objectForKey: key];
                } else if ([key isEqualToString: @"customerInternalReference"]) {
                    self.documentVerifcationConfiguration.customerInternalReference = [options objectForKey: key];
                } else if ([key isEqualToString: @"userReference"]) {
                    self.documentVerifcationConfiguration.userReference = [options objectForKey: key];
                } else if ([key isEqualToString: @"documentName"]) {
                    self.documentVerifcationConfiguration.documentName = [options objectForKey: key];
                } else if ([key isEqualToString: @"enableExtraction"]) {
                    self.documentVerifcationConfiguration.enableExtraction = [self getBoolValue:[options objectForKey: key]];
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
                    BOOL disableBlur = [self getBoolValue:[customization objectForKey: key]];
                    [[DocumentVerificationBaseView jumioAppearance] setDisableBlur: disableBlur ? @YES : @NO];
                } else if ([key isEqualToString: @"enableDarkMode"]) {
                    BOOL enableDarkMode = [self getBoolValue:[customization objectForKey: key]];
                    [[DocumentVerificationBaseView jumioAppearance] setEnableDarkMode: enableDarkMode ? @YES : @NO];
                } else {
                    UIColor *color = [self colorWithHexString: [customization objectForKey: key]];
                    
                    if ([key isEqualToString: @"backgroundColor"]) {
                        [[DocumentVerificationBaseView jumioAppearance] setBackgroundColor: color];
                    } else if ([key isEqualToString: @"tintColor"]) {
                        [[UINavigationBar jumioAppearance] setTintColor: color];
                    } else if ([key isEqualToString: @"barTintColor"]) {
                        [[UINavigationBar jumioAppearance] setBarTintColor: color];
                    } else if ([key isEqualToString: @"textTitleColor"]) {
                        [[UINavigationBar jumioAppearance] setTitleTextAttributes: @{NSForegroundColorAttributeName: color}];
                    } else if ([key isEqualToString: @"foregroundColor"]) {
                        [[DocumentVerificationBaseView jumioAppearance] setForegroundColor: color];
                    } else if ([key isEqualToString: @"positiveButtonBackgroundColor"]) {
                        [[DocumentVerificationPositiveButton jumioAppearance] setBackgroundColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"positiveButtonBorderColor"]) {
                        [[DocumentVerificationPositiveButton jumioAppearance] setBorderColor: color];
                    } else if ([key isEqualToString: @"positiveButtonTitleColor"]) {
                        [[DocumentVerificationPositiveButton jumioAppearance] setTitleColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"negativeButtonBackgroundColor"]) {
                        [[DocumentVerificationNegativeButton jumioAppearance] setBackgroundColor: color forState:UIControlStateNormal];
                    } else if ([key isEqualToString: @"negativeButtonBorderColor"]) {
                        [[DocumentVerificationNegativeButton jumioAppearance] setBorderColor: color];
                    } else if ([key isEqualToString: @"negativeButtonTitleColor"]) {
                        [[DocumentVerificationNegativeButton jumioAppearance] setTitleColor: color forState:UIControlStateNormal];
                    }
                }
            }
        }
        
        @try {
            self.documentVerificationViewController = [[DocumentVerificationViewController alloc] initWithConfiguration: self.documentVerifcationConfiguration];
            self.initiateSuccessfulDocumentVerification = YES;
        } @catch (NSException *exception) {
            NSString *msg = [NSString stringWithFormat: @"Cancelled with exception %@: %@", exception.name, exception.reason];
            [self sendErrorMessage: msg];
        }
    }
    
- (void)startDocumentVerification:(CDVInvokedUrlCommand*)command
    {
        self.callbackId = command.callbackId;
        
        if (self.documentVerificationViewController == nil && self.initiateSuccessfulDocumentVerification == NO) {
            [self sendErrorMessage: @"The Document-Verification SDK is not initialized yet. Call initDocumentVerification() first."];
            return;
        }
        
        [self.viewController presentViewController: self.documentVerificationViewController animated: YES completion: nil];
    }
    
    
#pragma mark - BAM Checkout Delegates
    
- (void) bamCheckoutViewController:(BAMCheckoutViewController *)controller didFinishScanWithCardInformation:(BAMCheckoutCardInformation *)cardInformation scanReference:(NSString *)scanReference {
    self.initiateSuccessfulBAMCheckout = NO;
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
    self.initiateSuccessfulBAMCheckout = NO;
    [self sendError: error scanReference: scanReference];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}
    
#pragma mark - Netverify Delegates
    
- (void)netverifyViewController:(NetverifyViewController *)netverifyViewController didFinishWithDocumentData:(NetverifyDocumentData *)documentData scanReference:(NSString *)scanReference {
    self.initiateSuccessfulNetverify = NO;

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
    [self.viewController dismissViewControllerAnimated: YES completion: ^{
        [self.netverifyViewController destroy];
        self.netverifyViewController = nil;
    }];
}
    
- (void)netverifyViewController:(NetverifyViewController *)netverifyViewController didFinishInitializingWithError:(NetverifyError *)error {
    if (error != nil) {
        [self sendNetverifyError: error scanReference: nil];
        return;
    }

    self.initiateSuccessfulNetverify = YES;
}
    
- (void)netverifyViewController:(NetverifyViewController *)netverifyViewController didCancelWithError:(NetverifyError *)error scanReference:(NSString *)scanReference {
    self.initiateSuccessfulNetverify = NO;
    [self sendNetverifyError: error scanReference: scanReference];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark - Authentication Delegates

- (void)authenticationController:(nonnull AuthenticationController *)authenticationController didFinishInitializingScanViewController:(nonnull UIViewController *)scanViewController {
    self.authenticationScanViewController = scanViewController;
    self.initiateSuccessfulAuthentication = YES;
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: result];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
}

- (void)authenticationController:(nonnull AuthenticationController *)authenticationController didFinishWithAuthenticationResult:(AuthenticationResult)authenticationResult transactionReference:(nonnull NSString *)transactionReference {
    self.initiateSuccessfulAuthentication = NO;

    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    if (authenticationResult == AuthenticationResultSuccess) {
        [result setValue: @"SUCCESS" forKey: @"authenticationResult"];
    } else {
        [result setValue: @"FAILED" forKey: @"authenticationResult"];
    }
    
    [result setValue: transactionReference forKey: @"transactionReference"];
    
    [self.authenticationScanViewController dismissViewControllerAnimated: YES completion: ^{

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: result];
        [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
        
        [self.authenticationController destroy];
        self.authenticationController = nil;
    }];
}

- (void)authenticationController:(nonnull AuthenticationController *)authenticationController didFinishWithError:(nonnull AuthenticationError *)error transactionReference:(NSString * _Nullable)transactionReference {
    self.initiateSuccessfulAuthentication = NO;
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setValue: error.code forKey: @"errorCode"];
    [result setValue: error.message forKey: @"errorMessage"];
    if (transactionReference) {
        [result setValue: transactionReference forKey: @"transactionReference"];
    }
    
    //Dismiss the SDK
    void (^errorCompletion)(void) = ^{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsDictionary: result];
        [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
        
        //Destroy the instance to properly clean up the SDK
        [self.authenticationController destroy];
        self.authenticationController = nil;
    };
    
    if (self.authenticationScanViewController) {
        [self.authenticationScanViewController dismissViewControllerAnimated:YES completion:errorCompletion];
    } else {
        errorCompletion();
    }
}

#pragma mark - Document Verification Delegates
    
- (void) documentVerificationViewController:(DocumentVerificationViewController *)documentVerificationViewController didFinishWithScanReference:(NSString *)scanReference {
    self.initiateSuccessfulDocumentVerification = NO;
    NSDictionary *result = [NSDictionary dictionaryWithObject: scanReference forKey: @"scanReference"];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsDictionary: result];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}
    
- (void) documentVerificationViewController:(DocumentVerificationViewController *)documentVerificationViewController didFinishWithError:(DocumentVerificationError *)error {
    self.initiateSuccessfulDocumentVerification = NO;
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
    [self.viewController dismissViewControllerAnimated: YES completion: ^{
        if (self.netverifyViewController) {
            [self.netverifyViewController destroy];
            self.netverifyViewController = nil;
        }
    }];
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
