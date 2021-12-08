//
//  ATPriorityOperationQueue.h
//  ATPriorityOperationQueue
//
//  Created by Tommy McHugh on 10/7/21.
//

#import <Foundation/Foundation.h>
#import "ATPriorityOperation.h"

NS_ASSUME_NONNULL_BEGIN

extern const BOOL kATPriorityOperationQueueDefaultCancelLowerPriorityOperations;

typedef BOOL (^ATPriorityOperationQueueFilter)(ATPriorityOperation *operation);

@interface ATPriorityOperationQueue : NSOperationQueue

@property (nonatomic, assign) BOOL cancelLowerPriorityOperations;

// Remove non-priority operations from callable methods
- (void)addOperation:(NSOperation *)op NS_UNAVAILABLE;
- (void)addOperations:(NSArray<NSOperation *> *)ops waitUntilFinished:(BOOL)wait NS_UNAVAILABLE;
- (void)addOperationWithBlock:(void (^)(void))block NS_UNAVAILABLE;

- (instancetype)init;
- (void)addPriorityOperation:(ATPriorityOperation *)operation;
- (void)addOperationWithPriority:(ATOperationPriority)priority withBlock:(void (^)(void))block;
- (void)cancelOperationsWithBlock:(ATPriorityOperationQueueFilter)block;
- (void)cancelOperationsWithPriority:(ATOperationPriority)priority;
- (void)cancelOperationsGreaterThanPriority:(ATOperationPriority)priority;
- (void)cancelOperationsGreaterThanAndEqualToPriority:(ATOperationPriority)priority;
- (void)cancelOperationsLessThanPriority:(ATOperationPriority)priority;
- (void)cancelOperationsLessThanAndEqualToPriority:(ATOperationPriority)priority;

@end

NS_ASSUME_NONNULL_END
