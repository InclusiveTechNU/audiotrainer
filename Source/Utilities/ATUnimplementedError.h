//
//  ATUnimplementedError.h
//  ATUnimplementedError
//
//  Created by Tommy McHugh on 9/28/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATUnimplementedError : NSObject

+ (NSString *)errorMessageWithSelector:(SEL)selector sourceClass:(Class)sourceClass;
+ (NSException *)errorWithSelector:(SEL)selector sourceClass:(Class)sourceClass;

@end

NS_ASSUME_NONNULL_END
