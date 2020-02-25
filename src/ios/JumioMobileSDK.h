//
//  JumioMobileSDK.h
//  Jumio Software Development GmbH
//

#import "Cordova/CDVPlugin.h"
@import JumioCore;
@import Netverify;
@import NetverifyFace;
@import BAMCheckout;
@import DocumentVerification;

@interface JumioMobileSDK : CDVPlugin <NetverifyViewControllerDelegate, AuthenticationControllerDelegate, BAMCheckoutViewControllerDelegate, DocumentVerificationViewControllerDelegate>

@property (strong) NetverifyViewController* netverifyViewController;
@property (strong) NetverifyConfiguration* netverifyConfiguration;
@property (strong) AuthenticationController* authenticationController;
@property (strong) AuthenticationConfiguration* authenticationConfiguration;
@property (strong) UIViewController *authenticationScanViewController;
@property (strong) BAMCheckoutViewController* bamViewController;
@property (strong) BAMCheckoutConfiguration* bamConfiguration;
@property (strong) DocumentVerificationConfiguration* documentVerifcationConfiguration;
@property (strong) DocumentVerificationViewController* documentVerificationViewController;
@property (strong) NSString* callbackId;

@end
