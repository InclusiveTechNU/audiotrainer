//
//  ATApplicationUtilities.h
//  ATApplicationUtilities
//
//  Created by Tommy McHugh on 10/4/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATApplicationUtilities : NSObject

+ (pid_t)processWithName:(NSString *)name;
+ (pid_t)processWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
