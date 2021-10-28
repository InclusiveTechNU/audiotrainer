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
#import "NSError+ApplicationScraper.h"

const NSUInteger kATApplicationScraperMaxChildElements = 500;
const ATOperationPriority kATApplicationScraperInitialScrapePriority = kATOperationPriorityHigh;
const ATOperationPriority kATApplicationScraperUpdatePriority = kATOperationPriorityMedium;

@implementation ATApplicationScraper

@synthesize windows = _windows;
@synthesize hasScraped = _hasScraped;

// TODO: Determine whether this should be an Application Element not a name
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
        _enabledTopLevelGroups = [[NSMutableSet alloc] init];
        _delegate = nil;
        
        // Set flags and defaults
        _preferVisibleChildren = YES;
        _limitChildrenScraped = YES;
        _maxScrapedChildElements = kATApplicationScraperMaxChildElements;
    }
    return self;
}

- (void)dealloc
{
    [_applicationQueue cancelAllOperations];
    [_menuBarQueue cancelAllOperations];
    for (ATPriorityOperationQueue * windowQueue in _windowQueues)
    {
        [windowQueue cancelAllOperations];
    }
}

- (NSArray<ATPriorityOperationQueue *> *)windowQueues
{
    return _windowQueues;
}

- (void)scrapeWithHandler:(ATApplicationScrapeHandler _Nullable)handler
{
    __weak ATApplicationScraper *weakSelf = self;
    [_applicationQueue addOperationWithPriority:kATOperationPriorityHigh withBlock:^{
        if (weakSelf.hasScraped)
        {
            if (handler != nil)
            {
                // TODO: Set error code & message
                NSError *responseError = [NSError scrapeErrorWithCode:kATApplicationScraperUnknownErrorCode
                                                              message:kATApplicationScraperUnknownErrorMessage];
                handler(responseError, weakSelf.timeline);
            }
            return;
        }
        // TODO: Scrape menubar
        ATApplicationScraper *strongSelf = weakSelf;
        for (ATWindowElement *window in weakSelf.application.windows)
        {
            ATPriorityOperationQueue *windowQueue = [[ATPriorityOperationQueue alloc] init];
            if (strongSelf != nil)
            {
                [strongSelf->_windowQueues addObject:windowQueue];
            }
            ATCachedElement *cachedWindow = [ATCachedElement cacheElement:window];
            ATCachedElementTreeNode *windowNode = [[ATCachedElementTreeNode alloc] initWithElement:cachedWindow];
            ATCachedElementTree *windowTree = [[ATCachedElementTree alloc] initWithNode:windowNode];
            [weakSelf _scrapeElementChildren:window forTree:windowTree];
            if (strongSelf != nil)
            {
                [strongSelf->_windows addObject:windowTree];
            }
        }
        if (strongSelf != nil)
        {
            strongSelf->_hasScraped = YES;
            strongSelf->_timeline = [[ATApplicationTimeline alloc] init];
        }

        if (weakSelf.timeline != nil)
        {
            [weakSelf.delegate applicationScraper:weakSelf didCompleteInitialScrape:weakSelf.timeline];
            if (handler != nil)
            {
                handler(nil, weakSelf.timeline);
            }
        }
    }];
}

- (void)generateTimelineWithHandler
{
    
}

- (void)updateWithHandler:(ATApplicationScrapeHandler _Nullable)handler;
{
    // TODO: This isn't working
    __block BOOL updatedApplication = NO;
    __block BOOL updatedWindows = NO;
    __block BOOL updatedMenuBar = NO;
    NSMutableArray<NSError *> *errors = [[NSMutableArray alloc] init];
    
    ATApplicationScrapeHandler _Nullable (^completionHandler)(NSUInteger, ...) = ^ATApplicationScrapeHandler _Nullable (NSUInteger count, ...)
    {
        NSMutableData *checkerListData = [NSMutableData dataWithLength:sizeof(BOOL *) * count];
        BOOL **checkerList = [checkerListData mutableBytes];
        va_list argumentList;
        va_start(argumentList, count);
        for (NSUInteger i = 0; i < count; i++)
        {
            BOOL *checker = va_arg(argumentList, BOOL *);
            checkerList[i] = checker;
        }
        va_end(argumentList);

        return ^(NSError * _Nullable error, ATApplicationTimeline * _Nullable timeline)
        {
            BOOL **checkerList = [checkerListData mutableBytes];
            if (error != nil)
            {
                [errors addObject:error];
            }

            BOOL allTrue = YES;
            for (NSUInteger i = 0; i < count; i++)
            {
                BOOL *checker = checkerList[i];
                if (i == 0)
                {
                    *checker = YES;
                }
                else
                {
                    if (!*checker)
                    {
                        allTrue = NO;
                        break;
                    }
                }
            }

            if (allTrue && handler != nil)
            {
                NSError *error = [NSError errorFromCombinedErrors:errors];
                handler(error, self.timeline);
            }
        };
    };
    
    [self updateApplicationWithHandler:completionHandler(3, &updatedApplication, &updatedWindows, &updatedMenuBar)];
    [self updateWindowsWithHandler:completionHandler(3, &updatedWindows, &updatedMenuBar, &updatedApplication)];
    [self updateMenuBarWithHandler:completionHandler(3, &updatedMenuBar, &updatedApplication, &updatedWindows)];
}

- (void)updateMenuBarWithHandler:(ATApplicationScrapeHandler _Nullable)handler;
{
    if (handler != nil)
    {
        handler(nil, self.timeline);
    }
}

- (void)updateApplicationWithHandler:(ATApplicationScrapeHandler _Nullable)handler;
{
    __weak ATApplicationScraper *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (!weakSelf.hasScraped)
        {
            if (handler != nil)
            {
                // TODO: Set error code & message
                NSError *responseError = [NSError scrapeErrorWithCode:kATApplicationScraperUnknownErrorCode
                                                              message:kATApplicationScraperUnknownErrorMessage];
                handler(responseError, weakSelf.timeline);
            }
            return;
        }
        [weakSelf _setupUpdateWithQueue:weakSelf.applicationQueue];
        [weakSelf.applicationQueue addOperationWithPriority:kATApplicationScraperUpdatePriority withBlock:^{
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
            ATApplicationScraper *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                strongSelf->_application = application;
            }
        }];

        if (handler != nil)
        {
            handler(nil, weakSelf.timeline);
        }
    });
}

- (void)updateWindowsWithHandler:(ATApplicationScrapeHandler _Nullable)handler;
{
    __weak ATApplicationScraper *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (!weakSelf.hasScraped)
        {
            if (handler != nil)
            {
                // TODO: Set error code & message
                NSError *responseError = [NSError scrapeErrorWithCode:kATApplicationScraperUnknownErrorCode
                                                              message:kATApplicationScraperUnknownErrorMessage];
                handler(responseError, weakSelf.timeline);
            }
            return;
        }
        
        for (NSUInteger i = 0; i < weakSelf.windows.count; i++)
        {
            __block BOOL completed = NO;
            [weakSelf _updateWindowAtIndex:i withHandler:^(NSError * _Nullable error, ATApplicationTimeline * _Nullable timeline) {
                completed = YES;
            }];
            while (!completed) {}
        }
        if (handler != nil)
        {
            handler(nil, weakSelf.timeline);
        }
    });
}

- (void)updateWindow:(ATCachedElementTree *)window withHandler:(ATApplicationScrapeHandler _Nullable)handler;
{
    __weak ATApplicationScraper *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (!weakSelf.hasScraped)
        {
            if (handler != nil)
            {
                // TODO: Set error code & message
                NSError *responseError = [NSError scrapeErrorWithCode:kATApplicationScraperUnknownErrorCode
                                                              message:kATApplicationScraperUnknownErrorMessage];
                handler(responseError, weakSelf.timeline);
            }
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
        [weakSelf _updateWindowAtIndex:windowIndex withHandler:^(NSError * _Nullable error,
                                                                 ATApplicationTimeline * _Nullable timeline) {
            if (handler != nil)
            {
                handler(error, timeline);
            }
        }];
    });
}

- (void)updateElement:(ATCachedElementTreeNode *)node withHandler:(ATApplicationScrapeHandler _Nullable)handler;
{
    if (handler != nil)
    {
        handler(nil, self.timeline);
    }
}

- (void)enableTopLevelGroup:(NSString *)label
{
    [self.enabledTopLevelGroups addObject:label];
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

- (void)_updateWindowAtIndex:(NSUInteger)windowIndex withHandler:(ATApplicationScrapeHandler _Nullable)handler;
{
    if (windowIndex < 0)
    {
        if (handler != nil)
        {
            // TODO: Set error code & message
            NSError *responseError = [NSError scrapeErrorWithCode:kATApplicationScraperUnknownErrorCode
                                                          message:kATApplicationScraperUnknownErrorMessage];
            handler(responseError, self.timeline);
        }
        return;
    }
    ATPriorityOperationQueue *queue = [_windowQueues objectAtIndex:windowIndex];
    [self _setupUpdateWithQueue:queue];
    
    __weak ATApplicationScraper *weakSelf = self;
    [queue addOperationWithPriority:kATApplicationScraperUpdatePriority withBlock:^{
        if (weakSelf.application.windows.count < windowIndex)
        {
            ATApplicationScraper *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                // Window was deleted. Remove priority queue and add removal to the timeline.
                // TODO: Add removal to the timeline
                [strongSelf->_windows removeObjectAtIndex:windowIndex];
                [strongSelf->_windowQueues removeObjectAtIndex:windowIndex];
            }
        }
        else
        {
            ATElement *windowElement = [weakSelf.application.windows objectAtIndex:windowIndex];
            ATCachedElementTree *windowTree = [[weakSelf windows] objectAtIndex:windowIndex];
            [weakSelf _updateTree:windowTree withElement:windowElement];
        }
        if (handler != nil)
        {
            handler(nil, weakSelf.timeline);
        }
    }];
}

- (void)_setupUpdateWithQueue:(ATPriorityOperationQueue *)queue
{
    if (!self.hasScraped)
    {
        return;
    }
    [queue cancelOperationsLessThanAndEqualToPriority:kATApplicationScraperUpdatePriority];
}

- (void)_scrapeElementChildren:(ATElement *)element forTree:(ATCachedElementTree *)tree
{
    if (tree.cursor == nil)
    {
        return;
    }

    NSArray<ATElement *> *children;
    NSUInteger visibileChildrenCount = element.visibileChildrenCount;
    if (_preferVisibleChildren && visibileChildrenCount > 0)
    {
        if (self.limitChildrenScraped && visibileChildrenCount > self.maxScrapedChildElements)
        {
            children = [element visibileChildrenAtIndex:0 maxValues:self.maxScrapedChildElements];
        }
        else
        {
            children = element.visibileChildren;
        }
    }
    else
    {
        if (self.limitChildrenScraped && element.childrenCount > self.maxScrapedChildElements)
        {
            children = [element childrenAtIndex:0 maxValues:self.maxScrapedChildElements];
        }
        else
        {
            children = element.children;
        }
    }
    
    BOOL isTopLevel = NO;
    ATElement *parentElement = element.parent;
    if (parentElement != nil && [parentElement.role isEqualToString:@"AXWindow"])
    {
        isTopLevel = YES;
    }
    
    for (ATElement *child in children)
    {
        /*if (isTopLevel && ![self.enabledTopLevelGroups containsObject:child.label])
        {
            continue;
        }*/
        __weak ATCachedElementTreeNode *currentCursor = tree.cursor;
        ATCachedElement *cachedElement = [ATCachedElement cacheElement:child];
        ATCachedElementTreeNode *childNode = [[ATCachedElementTreeNode alloc] initWithElement:cachedElement];
        [tree.cursor addChild:childNode];
        //if (![self.blockedLabels containsObject:cachedElement.label])
        //{
            [tree moveCursorToChildWithIndex:tree.cursor.children.count - 1];
            [self _scrapeElementChildren:child forTree:tree];
            tree.cursor = currentCursor;
        //}
    }
}

- (void)_updateTree:(ATCachedElementTree *)tree withElement:(ATElement *)element
{
    ATCachedElement *cachedElement = [ATCachedElement cacheElement:element];
    if (![tree.cursor.element isEqual:cachedElement])
    {
        ATApplicationScraper *strongSelf = self;
        if (strongSelf != nil)
        {
            ATApplicationEvent *changeEvent = [ATApplicationEvent eventWithType:kATApplicationEventChangeEvent
                                                                           node:tree.cursor
                                                                       userInfo:@{ @"element": [ATCachedElement cacheElement:element] }];
            [strongSelf->_timeline addEvent:changeEvent];
        }

        __weak ATCachedElementTreeNode *cursorNode = tree.cursor;
        NSArray *elementChildren = element.children;
        for (NSUInteger i = 0; i < tree.cursor.children.count; i++)
        {
            [tree moveCursorToChildWithIndex:i];
            [self _updateTree:tree withElement:[elementChildren objectAtIndex:i]];
            tree.cursor = cursorNode;
        }
    }
    tree.cursor.element = cachedElement;

    NSUInteger elementChildrenCount = element.childrenCount;
    if (self.limitChildrenScraped && elementChildrenCount > self.maxScrapedChildElements)
    {
        elementChildrenCount = self.maxScrapedChildElements;
    }
    
    if (elementChildrenCount == tree.cursor.children.count)
    {
        __weak ATCachedElementTreeNode *cursorNode = tree.cursor;
        NSArray *elementChildren = element.children;
        for (NSUInteger i = 0; i < tree.cursor.children.count; i++)
        {
            [tree moveCursorToChildWithIndex:i];
            [self _updateTree:tree withElement:[elementChildren objectAtIndex:i]];
            tree.cursor = cursorNode;
        }
    }
    else if (elementChildrenCount < tree.cursor.children.count)
    {
        NSArray *newChildren = element.children;
        for (NSUInteger i = 0; i < tree.cursor.children.count; i++)
        {
            if (i >= elementChildrenCount)
            {
                __weak ATCachedElementTreeNode *currentCursorNode = tree.cursor;
                [tree moveCursorToChildWithIndex:i];
                ATApplicationEvent *deleteEvent = [ATApplicationEvent eventWithType:kATApplicationEventDeletionEvent
                                                                            node:tree.cursor
                                                                        userInfo:@{}];
                tree.cursor = currentCursorNode;
                [tree.cursor.children removeObjectAtIndex:i];
                [_timeline addEvent:deleteEvent];
            }
            else
            {
                ATElement *newChild = [newChildren objectAtIndex:i];
                if (i < tree.cursor.children.count)
                {
                    ATCachedElementTreeNode *childNode = [tree.cursor.children objectAtIndex:i];
                    if ([childNode.element isEqualToElement:newChild])
                    {
                        __weak ATCachedElementTreeNode *currentCursorNode = tree.cursor;
                        [tree moveCursorToChildWithIndex:i];
                        [self _updateTree:tree withElement:newChild];
                        tree.cursor = currentCursorNode;
                        continue;
                    }
                    else
                    {
                        ATCachedElement *cachedChild = [ATCachedElement cacheElement:newChild];
                        ATCachedElementTreeNode *newChildNode = [[ATCachedElementTreeNode alloc] initWithElement:cachedChild];
                        [tree.cursor replaceChild:childNode withNode:newChildNode];
                    }
                    __weak ATCachedElementTreeNode *currentCursorNode = tree.cursor;
                    [tree moveCursorToChildWithIndex:i];
                    ATApplicationEvent *addEvent = [ATApplicationEvent eventWithType:kATApplicationEventAdditionEvent
                                                                                node:tree.cursor
                                                                            userInfo:@{ @"element" : [ATCachedElement cacheElement:newChild]}];
                    [_timeline addEvent:addEvent];
                    [self _scrapeElementChildren:newChild forTree:tree];
                    tree.cursor = currentCursorNode;
                }
            }
        }
    }
    else if (elementChildrenCount > tree.cursor.children.count)
    {
        NSArray *newChildren = element.children;
        for (NSUInteger i = 0; i < newChildren.count; i++)
        {
            ATElement *newChild = [newChildren objectAtIndex:i];
            if (i < tree.cursor.children.count)
            {
                ATCachedElementTreeNode *childNode = [tree.cursor.children objectAtIndex:i];
                if ([childNode.element isEqualToElement:newChild])
                {
                    __weak ATCachedElementTreeNode *currentCursorNode = tree.cursor;
                    [tree moveCursorToChildWithIndex:i];
                    [self _updateTree:tree withElement:newChild];
                    tree.cursor = currentCursorNode;
                    continue;
                }
                else
                {
                    ATCachedElement *cachedChild = [ATCachedElement cacheElement:newChild];
                    ATCachedElementTreeNode *newChildNode = [[ATCachedElementTreeNode alloc] initWithElement:cachedChild];
                    [tree.cursor replaceChild:childNode withNode:newChildNode];
                }
            }
            else
            {
                ATCachedElement *cachedChild = [ATCachedElement cacheElement:newChild];
                ATCachedElementTreeNode *newChildNode = [[ATCachedElementTreeNode alloc] initWithElement:cachedChild];
                [tree.cursor addChild:newChildNode];
            }
            
            __weak ATCachedElementTreeNode *currentCursorNode = tree.cursor;
            [tree moveCursorToChildWithIndex:i];
            ATApplicationEvent *addEvent = [ATApplicationEvent eventWithType:kATApplicationEventAdditionEvent
                                                                        node:tree.cursor
                                                                    userInfo:@{ @"element" : [ATCachedElement cacheElement:newChild]}];
            [_timeline addEvent:addEvent];
            [self _scrapeElementChildren:newChild forTree:tree];
            tree.cursor = currentCursorNode;
        }
    }
}

@end
