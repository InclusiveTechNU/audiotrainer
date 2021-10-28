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
#import "ATApplicationTimeline.h"

NS_ASSUME_NONNULL_BEGIN

extern const NSUInteger kATApplicationScraperMaxChildElements;

typedef void (^ATApplicationScrapeHandler)(NSError * _Nullable error, ATApplicationTimeline * _Nullable timeline);

@interface ATApplicationScraper : NSObject {
    NSMutableArray<ATPriorityOperationQueue *> *_windowQueues;
    NSMutableArray<ATCachedElementTree *> *_windows;
    BOOL _preferVisibleChildren;
    BOOL _hasScraped;
}

@property (nonatomic, strong, readonly) ATPriorityOperationQueue *menuBarQueue;
@property (nonatomic, strong, readonly) ATPriorityOperationQueue *applicationQueue;
@property (nonatomic, strong, readonly) ATApplicationElement *application;
@property (nonatomic, strong, readonly, nullable) ATCachedElementTree *menuBar;
@property (nonatomic, strong, readonly) NSArray<ATCachedElementTree *> *windows;
@property (nonatomic, strong, readonly, nullable) ATApplicationTimeline *timeline;
@property (nonatomic, strong) NSMutableSet<NSString *> *blockedLabels;
@property (nonatomic, strong) NSMutableSet<NSString *> *blockedClasses;
@property (nonatomic, strong) NSMutableSet<NSString *> *enabledTopLevelGroups;
@property (nonatomic, weak) id<ATApplicationScraperDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL hasScraped;
@property (nonatomic, assign) BOOL limitChildrenScraped;
@property (nonatomic, assign) NSUInteger maxScrapedChildElements;

+ (ATApplicationScraper * _Nullable)scraperForApplication:(NSString *)applicationName;

- (instancetype)init NS_UNAVAILABLE;

- (void)scrapeWithHandler:(ATApplicationScrapeHandler _Nullable)handler;
- (void)generateTimelineWithHandler;

- (void)updateWithHandler:(ATApplicationScrapeHandler _Nullable)handler;
- (void)updateMenuBarWithHandler:(ATApplicationScrapeHandler _Nullable)handler;
- (void)updateApplicationWithHandler:(ATApplicationScrapeHandler _Nullable)handler;
- (void)updateWindow:(ATCachedElementTree *)window withHandler:(ATApplicationScrapeHandler _Nullable)handler;
- (void)updateWindowsWithHandler:(ATApplicationScrapeHandler _Nullable)handler;
- (void)updateElement:(ATCachedElementTreeNode *)node withHandler:(ATApplicationScrapeHandler _Nullable)handler;

- (void)enableTopLevelGroup:(NSString *)label;
- (void)blockLabel:(NSString *)label;
- (void)blockClass:(NSString *)className;
- (void)unblockLabel:(NSString *)label;
- (void)unblockClass:(NSString *)className;

- (NSArray<ATPriorityOperationQueue *> *)windowQueues;

@end

NS_ASSUME_NONNULL_END
