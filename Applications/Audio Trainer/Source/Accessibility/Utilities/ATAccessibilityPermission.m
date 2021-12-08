//
//  ATAccessibilityPermission.m
//  ATAccessibilityPermission
//
//  Created by Tommy McHugh on 10/18/21.
//

#import <ApplicationServices/ApplicationServices.h>
#import "ATAccessibilityPermission.h"

static const NSTimeInterval kATAccessibilityPermissionCheckerInterval = 1.0;

@implementation ATAccessibilityPermission

+ (BOOL)hasPermission
{
    return AXIsProcessTrusted();
}

+ (void)requestPermission
{
    NSDictionary *options = @{
        (__bridge NSString *) kAXTrustedCheckOptionPrompt: @YES
    };
    AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef) options);
}

+ (NSTimer *)waitForPermissionWithCompletionHandler:(void(^)(void))handler
{
    __block BOOL requested = NO;
    NSTimer *permissionTimer = [NSTimer scheduledTimerWithTimeInterval:kATAccessibilityPermissionCheckerInterval
                                                               repeats:YES
                                                                 block:^(NSTimer * _Nonnull timer) {
        if ([ATAccessibilityPermission hasPermission])
        {
            [timer invalidate];
            handler();
        }
        else if (!requested)
        {
            [ATAccessibilityPermission requestPermission];
            requested = YES;
        }
    }];
    [permissionTimer fire];
    return permissionTimer;
}

@end
