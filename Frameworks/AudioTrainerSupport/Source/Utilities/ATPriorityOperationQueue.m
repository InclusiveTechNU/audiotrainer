//
//  ATPriorityOperationQueue.m
//  ATPriorityOperationQueue
//
//  Created by Tommy McHugh on 10/7/21.
//

#import "ATPriorityOperationQueue.h"

const BOOL kATPriorityOperationQueueDefaultCancelLowerPriorityOperations = NO;

@implementation ATPriorityOperationQueue

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _cancelLowerPriorityOperations = kATPriorityOperationQueueDefaultCancelLowerPriorityOperations;
        self.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)addPriorityOperation:(ATPriorityOperation *)operation
{
    if (self.cancelLowerPriorityOperations)
    {
        for (ATPriorityOperation *currentOperation in self.operations)
        {
            if (currentOperation.priority > operation.priority)
            {
                [currentOperation cancel];
            }
        }
    }
    [self addOperation:operation];
}

- (void)addOperationWithPriority:(ATOperationPriority)priority withBlock:(void (^)(void))block
{
    ATPriorityOperation *operation = [ATPriorityOperation blockOperationWithPriority:priority
                                                                           WithBlock:block];
    [self addPriorityOperation:operation];
}

- (void)cancelOperationsWithBlock:(ATPriorityOperationQueueFilter)block
{
    for (ATPriorityOperation *operation in self.operations)
    {
        if (block(operation))
        {
            [operation cancel];
        }
    }
}
- (void)cancelOperationsWithPriority:(ATOperationPriority)priority
{
    [self cancelOperationsWithBlock:^BOOL(ATPriorityOperation * _Nonnull operation) {
        return operation.priority == priority;
    }];
}

- (void)cancelOperationsGreaterThanPriority:(ATOperationPriority)priority
{
    [self cancelOperationsWithBlock:^BOOL(ATPriorityOperation * _Nonnull operation) {
        return operation.priority < priority;
    }];
}

- (void)cancelOperationsGreaterThanAndEqualToPriority:(ATOperationPriority)priority
{
    [self cancelOperationsWithBlock:^BOOL(ATPriorityOperation * _Nonnull operation) {
        return operation.priority <= priority;
    }];
}

- (void)cancelOperationsLessThanPriority:(ATOperationPriority)priority
{
    [self cancelOperationsWithBlock:^BOOL(ATPriorityOperation * _Nonnull operation) {
        return operation.priority > priority;
    }];
}

- (void)cancelOperationsLessThanAndEqualToPriority:(ATOperationPriority)priority
{
    [self cancelOperationsWithBlock:^BOOL(ATPriorityOperation * _Nonnull operation) {
        return operation.priority >= priority;
    }];
}

@end
