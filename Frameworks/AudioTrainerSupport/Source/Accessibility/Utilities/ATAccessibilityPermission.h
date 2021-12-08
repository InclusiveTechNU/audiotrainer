//
//  ATAccessibilityPermission.h
//  ATAccessibilityPermission
//
//  Created by Tommy McHugh on 10/18/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATAccessibilityPermission : NSObject

+ (BOOL)hasPermission;
+ (void)requestPermission;
+ (NSTimer *)waitForPermissionWithCompletionHandler:(void(^)(void))handler;

@end

NS_ASSUME_NONNULL_END
