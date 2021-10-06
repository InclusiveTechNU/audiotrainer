//
//  ATUnimplementedError.m
//  ATUnimplementedError
//
//  Created by Tommy McHugh on 9/28/21.
//

#import "ATUnimplementedError.h"

static NSString *kATUnimplementedErrorMessage = @"Method \"%@\" is not implemented in class \"%@\"";

@implementation ATUnimplementedError

+ (NSString *)errorMessageWithSelector:(SEL)selector sourceClass:(Class)sourceClass
{
    return [NSString stringWithFormat:kATUnimplementedErrorMessage, NSStringFromSelector(selector), NSStringFromClass(sourceClass)];
}

+ (NSException *)errorWithSelector:(SEL)selector sourceClass:(Class)sourceClass
{
    NSString *errorMessage = [self errorMessageWithSelector:selector sourceClass:sourceClass];
    return [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:errorMessage
                                 userInfo:nil];
}

@end
