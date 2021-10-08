//
//  ATPriorityOperation.h
//  ATPriorityOperation
//
//  Created by Tommy McHugh on 10/7/21.
//

#import <Foundation/Foundation.h>
#import "ATPriorityOperationDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    kATOperationPriorityHigh,
    kATOperationPriorityMedium,
    kATOperationPriorityLow
} ATOperationPriority;

@interface ATPriorityOperation : NSBlockOperation

@property (nonatomic, assign, readonly) ATOperationPriority priority;
@property (nonatomic, weak, nullable) id<ATPriorityOperationDelegate> delegate;

+ (instancetype)blockOperationWithBlock:(void (^)(void))block NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)blockOperationWithPriority:(ATOperationPriority)priority WithBlock:(void (^)(void))block;

@end

NS_ASSUME_NONNULL_END
