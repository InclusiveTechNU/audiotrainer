//
//  ATCachedElementTreeNode.h
//  ATCachedElementTreeNode
//
//  Created by Tommy McHugh on 10/7/21.
//

#import <Foundation/Foundation.h>
#import "ATCachedElement.h"
#import "ATTreeNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATCachedElementTreeNode : NSObject <ATTreeNode>

@property (nonatomic, strong) ATCachedElement *element;
@property (nonatomic, strong, readonly) NSMutableArray<ATCachedElementTreeNode *> *children;
@property (nonatomic, weak, nullable) ATCachedElementTreeNode *parent;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithElement:(ATCachedElement *)element;
- (instancetype)initWithElement:(ATCachedElement *)element children:(NSArray<ATCachedElementTreeNode *> *)children;
- (instancetype)initWithElement:(ATCachedElement *)element parent:(ATCachedElementTreeNode *)parent children:(NSArray<ATCachedElementTreeNode *> *)children;
- (instancetype)initWithElement:(ATCachedElement *)element parent:(ATCachedElementTreeNode *)parent;

- (void)addChild:(ATCachedElementTreeNode *)node;
- (void)removeChild:(ATCachedElementTreeNode *)child;
- (void)replaceChild:(ATCachedElementTreeNode *)child withNode:(ATCachedElementTreeNode *)node;
- (void)insertChild:(ATCachedElementTreeNode *)node atIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
