//
//  ATCachedElementTree.m
//  ATCachedElementTree
//
//  Created by Tommy McHugh on 10/4/21.
//

#import "ATCachedElementTree.h"

@implementation ATCachedElementTree

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.root = nil;
        self.delegate = nil;
        self.cursor = self.root;
    }
    return self;
}

- (instancetype)initWithNode:(ATCachedElementTreeNode *)root
{
    self = [super init];
    if (self != nil)
    {
        self.root = root;
        self.delegate = nil;
        self.cursor = self.root;
    }
    return self;
}

- (void)setRoot:(ATCachedElementTreeNode *)root
{
    _root = root;
    if (self.cursor == nil)
    {
        self.cursor = self.root;
    }
    [self.delegate elementTree:self didSetRootToElement:root];
}

- (void)setCursor:(ATCachedElementTreeNode *)cursor
{
    _cursor = cursor;
    [self.delegate elementTree:self didMoveCursorToElement:cursor];
}

- (NSArray<ATCachedElementTreeNode *> * _Nullable)cursorChildren
{
    return self.cursor.children;
}

- (BOOL)moveCursorToChildWithIndex:(NSUInteger)index
{
    if (self.cursor.children != nil && self.cursor.children.count > index)
    {
        self.cursor = [self.cursor.children objectAtIndex:index];
        return YES;
    }
    return NO;
}

- (NSUInteger)count
{
    NSUInteger count = 0;
    if (self.root == nil)
    {
        return count;
    }
    count += [self _countTreeNode:self.root];
    return count;
}

- (NSUInteger)_countTreeNode:(ATCachedElementTreeNode *)node
{
    NSUInteger count = 1;
    for (ATCachedElementTreeNode *child in node.children)
    {
        count += [self _countTreeNode:child];
    }
    return count;
}

@end
