//
//  ATCachedElementTreeDelegate.h
//  ATCachedElementTreeDelegate
//
//  Created by Tommy McHugh on 10/4/21.
//

#import <Foundation/Foundation.h>
#import "ATCachedElementTreeNode.h"

NS_ASSUME_NONNULL_BEGIN

@class ATCachedElementTree;

@protocol ATCachedElementTreeDelegate <NSObject>

@optional

- (void)elementTree:(ATCachedElementTree *)tree didSetRootToElement:(ATCachedElementTreeNode *)node;
- (void)elementTree:(ATCachedElementTree *)tree didMoveCursorToElement:(ATCachedElementTreeNode *)node;
- (void)elementTree:(ATCachedElementTree *)tree didAddChildElement:(ATCachedElementTreeNode *)node toParent:(ATCachedElementTreeNode *)node;

@end

NS_ASSUME_NONNULL_END
