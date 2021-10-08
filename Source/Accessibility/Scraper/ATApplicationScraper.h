//
//  ATApplicationScraper.h
//  ATApplicationScraper
//
//  Created by Tommy McHugh on 10/7/21.
//

#import <Foundation/Foundation.h>
#import "ATCachedElementTree.h"
#import "ATApplicationElement.h"
#import "ATApplicationScraperDelegate.h"
#import "ATPriorityOperationQueue.h"

NS_ASSUME_NONNULL_BEGIN

extern const NSUInteger kATApplicationScraperMaxChildElements;

typedef void (^ATApplicationScrapeHandler)(void);

@interface ATApplicationScraper : NSObject {
    ATPriorityOperationQueue *_applicationQueue;
    ATPriorityOperationQueue *_menuBarQueue;
    NSMutableArray<ATPriorityOperationQueue *> *_windowQueues;
    NSMutableArray<ATCachedElementTree *> *_windows;
    BOOL _preferVisibleChildren;
    BOOL _hasScraped;
}

@property (nonatomic, strong, readonly) ATApplicationElement *application;
@property (nonatomic, strong, readonly, nullable) ATCachedElementTree *menuBar;
@property (nonatomic, strong, readonly) NSArray<ATCachedElementTree *> *windows;
@property (nonatomic, strong) NSMutableSet<NSString *> *blockedLabels;
@property (nonatomic, strong) NSMutableSet<NSString *> *blockedClasses;
@property (nonatomic, weak) id<ATApplicationScraperDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL hasScraped;
@property (nonatomic, assign) BOOL limitChildrenScraped;
@property (nonatomic, assign) NSUInteger maxScrapedChildElements;

+ (ATApplicationScraper * _Nullable)scraperForApplication:(NSString *)applicationName;

- (instancetype)init NS_UNAVAILABLE;

- (void)scrapeWithHandler:(ATApplicationScrapeHandler)handler;
- (void)generateTimelineWithHandler;

- (void)update;
- (void)updateMenuBar;
- (void)updateApplication;
- (void)updateWindow:(ATCachedElementTree *)window;
- (void)updateElement:(ATCachedElementTreeNode *)node;

- (void)blockLabel:(NSString *)label;
- (void)blockClass:(NSString *)className;
- (void)unblockLabel:(NSString *)label;
- (void)unblockClass:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
