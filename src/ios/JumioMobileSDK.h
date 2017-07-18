//
//  JumioMobileSDK.h
//  Jumio Software Development GmbH
//

#import "Cordova/CDVPlugin.h"
@import Netverify;
@import BAMCheckout;

@interface JumioMobileSDK : CDVPlugin <NetverifyViewControllerDelegate, BAMCheckoutViewControllerDelegate, DocumentVerificationViewControllerDelegate>

@property (strong) NetverifyViewController* netverifyViewController;
@property (strong) NetverifyConfiguration* netverifyConfiguration;
@property (strong) BAMCheckoutViewController* bamViewController;
@property (strong) BAMCheckoutConfiguration* bamConfiguration;
@property (strong) DocumentVerificationConfiguration* documentVerifcationConfiguration;
@property (strong) DocumentVerificationViewController* documentVerificationViewController;
@property (strong) NSString* callbackId;

@end
