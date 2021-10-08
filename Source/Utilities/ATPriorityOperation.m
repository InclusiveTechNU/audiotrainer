//
//  ATPriorityOperation.m
//  ATPriorityOperation
//
//  Created by Tommy McHugh on 10/7/21.
//

#import "ATPriorityOperation.h"

@implementation ATPriorityOperation

+ (instancetype)blockOperationWithPriority:(ATOperationPriority)priority WithBlock:(void (^)(void))block
{
    ATPriorityOperation *operation = [[ATPriorityOperation alloc] initWithPriority:priority];
    [operation addExecutionBlock:block];
    return operation;
}

- (instancetype)initWithPriority:(ATOperationPriority)priority
{
    self = [super init];
    if (self != nil)
    {
        _priority = priority;
    }
    return self;
}

- (void)cancel
{
    [super cancel];
    [self.delegate priorityOperationDidCancel:self];
}

@end
