//
//  ATCachedElementTree.h
//  ATCachedElementTree
//
//  Created by Tommy McHugh on 10/4/21.
//

#import <Foundation/Foundation.h>
#import "ATCachedElementTreeNode.h"
#import "ATCachedElementTreeDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATCachedElementTree : NSObject

@property (nonatomic, strong, nullable) ATCachedElementTreeNode *root;
@property (nonatomic, weak, nullable) ATCachedElementTreeNode *cursor;
@property (nonatomic, weak, nullable) id<ATCachedElementTreeDelegate> delegate;

- (instancetype)initWithNode:(ATCachedElementTreeNode *)root;
- (NSArray<ATCachedElementTreeNode *> * _Nullable)cursorChildren;
- (BOOL)moveCursorToChildWithIndex:(NSUInteger)index;
- (NSUInteger)count;

@end

NS_ASSUME_NONNULL_END
