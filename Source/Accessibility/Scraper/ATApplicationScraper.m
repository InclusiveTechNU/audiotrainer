//
//  ATApplicationScraper.m
//  ATApplicationScraper
//
//  Created by Tommy McHugh on 10/7/21.
//

#import "ATApplicationScraper.h"
#import "ATElement.h"
#import "ATWindowElement.h"
#import "ATCachedElementTree.h"
#import "ATCachedElement.h"

const NSUInteger kATApplicationScraperMaxChildElements = 500;
const ATOperationPriority kATApplicationScraperInitialScrapePriority = kATOperationPriorityHigh;
const ATOperationPriority kATApplicationScraperUpdatePriority = kATOperationPriorityMedium;

@implementation ATApplicationScraper

@synthesize windows = _windows;
@synthesize hasScraped = _hasScraped;

+ (ATApplicationScraper * _Nullable)scraperForApplication:(NSString *)applicationName
{
    ATApplicationElement * _Nullable application = [ATApplicationElement applicationWithName:applicationName];
    if (application == nil)
    {
        return nil;
    }
    ATApplicationScraper *scraper = [[ATApplicationScraper alloc] initWithApplication:application];
    return scraper;
}

- (instancetype)initWithApplication:(ATApplicationElement *)application
{
    self = [super init];
    if (self != nil)
    {
        _applicationQueue = [[ATPriorityOperationQueue alloc] init];
        _menuBarQueue = [[ATPriorityOperationQueue alloc] init];
        _windowQueues = [[NSMutableArray alloc] init];

        _application = application;
        _menuBar = nil;
        _windows = [[NSMutableArray alloc] init];
        _hasScraped = NO;
        _blockedLabels = [[NSMutableSet alloc] init];
        _blockedClasses = [[NSMutableSet alloc] init];
        _delegate = nil;
        
        // Set flags and defaults
        _preferVisibleChildren = YES;
        _limitChildrenScraped = YES;
        _maxScrapedChildElements = kATApplicationScraperMaxChildElements;
    }
    return self;
}

- (void)scrapeWithHandler:(ATApplicationScrapeHandler)handler
{
    __unsafe_unretained typeof(self) weakSelf = self;
    [_applicationQueue addOperationWithPriority:kATOperationPriorityHigh withBlock:^{
        if (weakSelf.hasScraped)
        {
            handler();
            return;
        }
        // TODO: Scrape menubar

        for (ATWindowElement *window in weakSelf.application.windows)
        {
            ATPriorityOperationQueue *windowQueue = [[ATPriorityOperationQueue alloc] init];
            [weakSelf->_windowQueues addObject:windowQueue];
            ATCachedElement *cachedWindow = [ATCachedElement cacheElement:window];
            ATCachedElementTreeNode *windowNode = [[ATCachedElementTreeNode alloc] initWithElement:cachedWindow];
            ATCachedElementTree *windowTree = [[ATCachedElementTree alloc] initWithNode:windowNode];
            [ATApplicationScraper _scrapeElementChildren:window forTree:windowTree onObject:weakSelf];
            [weakSelf->_windows addObject:windowTree];
        }
        weakSelf->_hasScraped = YES;
        [weakSelf.delegate applicationScraper:weakSelf didCompleteInitialScrape:@""];
        handler();
    }];
}

- (void)generateTimelineWithHandler
{
    
}

- (void)update
{
    [self updateApplication];
    [self updateWindows];
    [self updateMenuBar];
}

- (void)updateMenuBar
{
    
}

- (void)updateApplication
{
    __unsafe_unretained typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (!weakSelf.hasScraped)
        {
            return;
        }
        [ATApplicationScraper _setupUpdateWithQueue:weakSelf->_applicationQueue onObject:weakSelf];
        [weakSelf->_applicationQueue addOperationWithPriority:kATApplicationScraperUpdatePriority withBlock:^{
            NSString *applicationName = weakSelf.application.title;
            if (applicationName == nil)
            {
                return;
            }
            ATApplicationElement * _Nullable application = [ATApplicationElement applicationWithName:applicationName];
            if (application == nil)
            {
                return;
            }
            weakSelf->_application = application;
        }];
    });
}

- (void)updateWindows
{
    __unsafe_unretained typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (!weakSelf.hasScraped)
        {
            return;
        }
        for (NSUInteger i = 0; i < weakSelf.windows.count; i++)
        {
            [ATApplicationScraper _updateWindowAtIndex:i onObject:weakSelf];
        }
    });
}

- (void)updateWindow:(ATCachedElementTree *)window
{
    __unsafe_unretained typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (!weakSelf.hasScraped)
        {
            return;
        }
        NSUInteger windowIndex = -1;
        for (NSUInteger i = 0; i < weakSelf.windows.count; i++)
        {
            if (window == [weakSelf.windows objectAtIndex:i])
            {
                windowIndex = i;
                break;
            }
        }
        if (windowIndex == -1)
        {
            return;
        }
        [ATApplicationScraper _updateWindowAtIndex:windowIndex onObject:weakSelf];
    });
}

- (void)updateElement:(ATCachedElementTreeNode *)node
{
    
}

- (void)blockLabel:(NSString *)label
{
    [self.blockedLabels addObject:label];
}

- (void)blockClass:(NSString *)className
{
    [self.blockedClasses addObject:className];
}

- (void)unblockLabel:(NSString *)label
{
    [self.blockedLabels removeObject:label];
}

- (void)unblockClass:(NSString *)className
{
    [self.blockedClasses removeObject:className];
}

+ (void)_setupUpdateWithQueue:(ATPriorityOperationQueue *)queue
                   onObject:(__unsafe_unretained ATApplicationScraper *)weakSelf
{
    if (!weakSelf.hasScraped)
    {
        return;
    }
    [queue cancelOperationsLessThanAndEqualToPriority:kATApplicationScraperUpdatePriority];
}

+ (void)_scrapeElementChildren:(ATElement *)element
                       forTree:(ATCachedElementTree *)tree
                      onObject:(__unsafe_unretained ATApplicationScraper *)weakSelf
{
    if (tree.cursor == nil)
    {
        return;
    }

    NSArray<ATElement *> *children;
    NSUInteger visibileChildrenCount = element.visibileChildrenCount;
    if (weakSelf->_preferVisibleChildren && visibileChildrenCount > 0)
    {
        if (weakSelf.limitChildrenScraped && visibileChildrenCount > weakSelf.maxScrapedChildElements)
        {
            children = [element visibileChildrenAtIndex:0 maxValues:weakSelf.maxScrapedChildElements];
        }
        else
        {
            children = element.visibileChildren;
        }
    }
    else
    {
        if (weakSelf.limitChildrenScraped && element.childrenCount > weakSelf.maxScrapedChildElements)
        {
            children = [element childrenAtIndex:0 maxValues:weakSelf.maxScrapedChildElements];
        }
        else
        {
            children = element.children;
        }
    }
    
    for (ATElement *child in children)
    {
        __weak ATCachedElementTreeNode *currentCursor = tree.cursor;
        ATCachedElement *cachedElement = [ATCachedElement cacheElement:child];
        ATCachedElementTreeNode *childNode = [[ATCachedElementTreeNode alloc] initWithElement:cachedElement];
        [tree.cursor addChild:childNode];
        [tree moveCursorToChildWithIndex:tree.cursor.children.count - 1];
        [ATApplicationScraper _scrapeElementChildren:child forTree:tree onObject:weakSelf];
        tree.cursor = currentCursor;
    }
}

+ (void)_updateWindowAtIndex:(NSUInteger)windowIndex onObject:(__unsafe_unretained ATApplicationScraper *)weakSelf
{
    if (windowIndex < 0)
    {
        return;
    }
    ATPriorityOperationQueue *queue = [weakSelf->_windowQueues objectAtIndex:windowIndex];
    [ATApplicationScraper _setupUpdateWithQueue:queue onObject:weakSelf];
    [queue addOperationWithPriority:kATApplicationScraperUpdatePriority withBlock:^{
        if (weakSelf.application.windows.count < windowIndex)
        {
            // Window was deleted. Remove priority queue and add removal to the timeline.
            // TODO: Add removal to the timeline
            [weakSelf->_windows removeObjectAtIndex:windowIndex];
            [weakSelf->_windowQueues removeObjectAtIndex:windowIndex];
        }
        else
        {
            ATElement *windowElement = [weakSelf.application.windows objectAtIndex:windowIndex];
            ATCachedElementTree *windowTree = [[weakSelf windows] objectAtIndex:windowIndex];
            [ATApplicationScraper _updateTree:windowTree withElement:windowElement onObject:weakSelf];
        }
    }];
}

+ (void)_updateTree:(ATCachedElementTree *)tree
        withElement:(ATElement *)element
           onObject:(__unsafe_unretained ATApplicationScraper *)weakSelf
{
    ATCachedElement *cachedElement = [ATCachedElement cacheElement:element];
    NSUInteger elementChildrenCount = element.childrenCount;
    if (![tree.cursor.element isEqual:cachedElement])
    {
        // TODO: Add changes to timeline
        NSLog(@"Found a change: %@, %@", tree.cursor.element.role, cachedElement.role);
    }

    tree.cursor.element = cachedElement;
    if (elementChildrenCount < tree.cursor.children.count)
    {
        while (elementChildrenCount < tree.cursor.children.count)
        {
            // TODO: Add removal to the timeline
            [tree.cursor.children removeObjectAtIndex:tree.cursor.children.count - 1];
        }
    }
    else if (elementChildrenCount > tree.cursor.children.count)
    {
        __weak ATCachedElementTreeNode *currentCursorNode = tree.cursor;
        NSArray *newChildren = [element childrenAtIndex:tree.cursor.children.count
                                              maxValues:elementChildrenCount-tree.cursor.children.count];
        for (NSUInteger i = 0; i < newChildren.count; i++)
        {
            ATElement *newChild = [newChildren objectAtIndex:i];
            // TODO: Add addition of element tree to timeline
            
            ATCachedElement *cachedChild = [ATCachedElement cacheElement:newChild];
            ATCachedElementTreeNode *newChildNode = [[ATCachedElementTreeNode alloc] initWithElement:cachedChild];
            [tree.cursor addChild:newChildNode];
            tree.cursor = newChildNode;
            [ATApplicationScraper _scrapeElementChildren:newChild forTree:tree onObject:weakSelf];
        }
        tree.cursor = currentCursorNode;
    }
    __weak ATCachedElementTreeNode *cursorNode = tree.cursor;
    NSArray *elementChildren = element.children;
    for (NSUInteger i = 0; i < tree.cursor.children.count; i++)
    {
        [tree moveCursorToChildWithIndex:i];
        [ATApplicationScraper _updateTree:tree withElement:[elementChildren objectAtIndex:i] onObject:weakSelf];
        tree.cursor = cursorNode;
    }
}

@end
