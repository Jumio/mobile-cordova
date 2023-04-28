#import "AppDelegate+Deeplinking.h"

@implementation AppDelegate (Deeplinking)

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    return [[JumioMobileSDK jumioMobileSDK] handleDeepLink:url];
}

@end