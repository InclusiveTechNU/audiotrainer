//
//  ATPriorityOperationDelegate.h
//  ATPriorityOperationDelegate
//
//  Created by Tommy McHugh on 10/7/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ATPriorityOperation;

@protocol ATPriorityOperationDelegate

@optional

- (void)priorityOperationDidCancel:(ATPriorityOperation *)operation;

@end

NS_ASSUME_NONNULL_END
