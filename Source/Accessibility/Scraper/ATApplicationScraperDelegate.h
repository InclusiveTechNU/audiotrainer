//
//  ATApplicationScraperDelegate.h
//  ATApplicationScraperDelegate
//
//  Created by Tommy McHugh on 10/7/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ATApplicationScraper;

@protocol ATApplicationScraperDelegate <NSObject>

@optional

// TODO: This should have the output item from the handler
- (void)applicationScraper:(ATApplicationScraper *)scraper didCompleteInitialScrape:(NSString *)scrape;

@end

NS_ASSUME_NONNULL_END

