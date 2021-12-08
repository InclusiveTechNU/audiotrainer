//
//  ATTree.h
//  ATTree
//
//  Created by Tommy McHugh on 10/10/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ATTreeNode

- (id)element;
- (id<ATTreeNode> _Nullable)parent;
- (NSMutableArray<id<ATTreeNode>> *)children;

@end

NS_ASSUME_NONNULL_END
