//
//  ATCachedElementTreeNode.m
//  ATCachedElementTreeNode
//
//  Created by Tommy McHugh on 10/7/21.
//

#import "ATCachedElementTreeNode.h"

@implementation ATCachedElementTreeNode

- (instancetype)initWithElement:(ATCachedElement *)element
{
    self = [super init];
    if (self != nil)
    {
        self.element = element;
        _children = [[NSMutableArray alloc] init];
        self.parent = nil;
    }
    return self;
}

- (instancetype)initWithElement:(ATCachedElement *)element children:(NSArray<ATCachedElementTreeNode *> *)children
{
    self = [super init];
    if (self != nil)
    {
        self.element = element;
        _children = [NSMutableArray arrayWithArray:children];
        self.parent = nil;
    }
    return self;
}

- (instancetype)initWithElement:(ATCachedElement *)element parent:(ATCachedElementTreeNode *)parent children:(NSArray<ATCachedElementTreeNode *> *)children
{
    self = [self initWithElement:element children:children];
    if (self != nil)
    {
        self.parent = parent;
    }
    return self;
}

- (instancetype)initWithElement:(ATCachedElement *)element parent:(ATCachedElementTreeNode *)parent
{
    self = [self initWithElement:element];
    if (self != nil)
    {
        self.parent = parent;
    }
    return self;
}

- (void)addChild:(ATCachedElementTreeNode *)node
{
    node.parent = self;
    [_children addObject:node];
}

- (void)removeChild:(ATCachedElementTreeNode *)child
{
    [_children removeObject:child];
}

- (void)replaceChild:(ATCachedElementTreeNode *)child withNode:(ATCachedElementTreeNode *)node
{
    NSUInteger index = [_children indexOfObject:child];
    if (index != NSNotFound)
    {
        node.parent = self;
        [_children replaceObjectAtIndex:index withObject:node];
    }
}

- (void)insertChild:(ATCachedElementTreeNode *)node atIndex:(NSUInteger)index
{
    [_children insertObject:node atIndex:index];
}

@end
