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

static NSString *const kATApplicationScraperDomainError = @"edu.uci.ics.accessibility.AudioTrainer.ATApplicationScraper";

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

- (void)dealloc
{
    [_applicationQueue cancelAllOperations];
    [_menuBarQueue cancelAllOperations];
    for (ATPriorityOperationQueue * windowQueue in _windowQueues)
    {
        [windowQueue cancelAllOperations];
    }
}

- (void)scrapeWithHandler:(ATApplicationScrapeHandler _Nullable)handler
{
    __weak ATApplicationScraper *weakSelf = self;
    [_applicationQueue addOperationWithPriority:kATOperationPriorityHigh withBlock:^{
        ATApplicationScraper *strongSelf = weakSelf;
        if (strongSelf == nil)
        {
            if (handler != nil)
            {
                // TODO: Set error code & message
                NSError *responseError = [NSError scrapeErrorWithCode:kATApplicationScraperUnknownErrorCode
                                                              message:kATApplicationScraperUnknownErrorMessage];
                handler(responseError, nil);
            }
            return;
        }
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
        for (ATWindowElement *window in weakSelf.application.windows)
        {
            ATPriorityOperationQueue *windowQueue = [[ATPriorityOperationQueue alloc] init];
            [strongSelf->_windowQueues addObject:windowQueue];
            ATCachedElement *cachedWindow = [ATCachedElement cacheElement:window];
            ATCachedElementTreeNode *windowNode = [[ATCachedElementTreeNode alloc] initWithElement:cachedWindow];
            ATCachedElementTree *windowTree = [[ATCachedElementTree alloc] initWithNode:windowNode];
            [ATApplicationScraper _scrapeElementChildren:window forTree:windowTree onObject:weakSelf];
            [strongSelf->_windows addObject:windowTree];
        }
        strongSelf->_hasScraped = YES;

        strongSelf->_timeline = [[ATApplicationTimeline alloc] init];
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
    __block BOOL updatedApplication = NO;
    __block BOOL updatedWindows = NO;
    __block BOOL updatedMenuBar = NO;
    NSMutableArray<NSError *> *errors = [[NSMutableArray alloc] init];
    
    ATApplicationScrapeHandler _Nullable (^completionHandler)(NSUInteger, ...) = ^ ATApplicationScrapeHandler _Nullable (NSUInteger count, ...) {
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

        return ^(NSError * _Nullable error, ATApplicationTimeline * _Nullable __weak timeline) {
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
        ATApplicationScraper *strongSelf = weakSelf;
        if (strongSelf == nil)
        {
            if (handler != nil)
            {
                // TODO: Set error code & message
                NSError *responseError = [NSError scrapeErrorWithCode:kATApplicationScraperUnknownErrorCode
                                                              message:kATApplicationScraperUnknownErrorMessage];
                handler(responseError, nil);
            }
            return;
        }
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
        [ATApplicationScraper _setupUpdateWithQueue:strongSelf->_applicationQueue onObject:weakSelf];
        [strongSelf->_applicationQueue addOperationWithPriority:kATApplicationScraperUpdatePriority withBlock:^{
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
            strongSelf->_application = application;
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
            [ATApplicationScraper _updateWindowAtIndex:i onObject:weakSelf];
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
        [ATApplicationScraper _updateWindowAtIndex:windowIndex onObject:weakSelf];
        if (handler != nil)
        {
            handler(nil, weakSelf.timeline);
        }
    });
}

- (void)updateElement:(ATCachedElementTreeNode *)node withHandler:(ATApplicationScrapeHandler _Nullable)handler;
{
    if (handler != nil)
    {
        handler(nil, self.timeline);
    }
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
                   onObject:(__weak ATApplicationScraper *)weakSelf
{
    if (!weakSelf.hasScraped)
    {
        return;
    }
    [queue cancelOperationsLessThanAndEqualToPriority:kATApplicationScraperUpdatePriority];
}

+ (void)_scrapeElementChildren:(ATElement *)element
                       forTree:(ATCachedElementTree *)tree
                      onObject:(__weak ATApplicationScraper *)weakSelf
{
    ATApplicationScraper *strongSelf = weakSelf;
    if (strongSelf == nil)
    {
        return;
    }
    if (tree.cursor == nil)
    {
        return;
    }

    NSArray<ATElement *> *children;
    NSUInteger visibileChildrenCount = element.visibileChildrenCount;
    if (strongSelf->_preferVisibleChildren && visibileChildrenCount > 0)
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

+ (void)_updateWindowAtIndex:(NSUInteger)windowIndex onObject:(__weak ATApplicationScraper *)weakSelf
{
    ATApplicationScraper *strongSelf = weakSelf;
    if (strongSelf == nil)
    {
        return;
    }
    if (windowIndex < 0)
    {
        return;
    }
    ATPriorityOperationQueue *queue = [strongSelf->_windowQueues objectAtIndex:windowIndex];
    [ATApplicationScraper _setupUpdateWithQueue:queue onObject:weakSelf];
    [queue addOperationWithPriority:kATApplicationScraperUpdatePriority withBlock:^{
        if (weakSelf.application.windows.count < windowIndex)
        {
            // Window was deleted. Remove priority queue and add removal to the timeline.
            // TODO: Add removal to the timeline
            [strongSelf->_windows removeObjectAtIndex:windowIndex];
            [strongSelf->_windowQueues removeObjectAtIndex:windowIndex];
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
           onObject:(__weak ATApplicationScraper *)weakSelf
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
