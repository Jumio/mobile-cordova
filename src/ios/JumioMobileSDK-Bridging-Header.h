#import "Cordova/CDV.h"
#import "Cordova/CDVPlugin.h"

@interface JumioMobileSDK : CDVPlugin

+ (JumioMobileSDK*)jumioMobileSDK;

- (BOOL)handleDeepLink:(NSURL*)url;

@end