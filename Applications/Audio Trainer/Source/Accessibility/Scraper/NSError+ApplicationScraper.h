//
//  NSError+ApplicationScraper.h
//  NSError+Scraper
//
//  Created by Tommy McHugh on 10/10/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kATApplicationScraperUnknownErrorMessage;

typedef enum {
    kATApplicationScraperUnknownErrorCode,
    kATApplicationScraperCombinedErrorCode
} ATApplicationScraperErrorCode;

@interface NSError (ApplicationScraper)

+ (NSError *)scrapeErrorWithCode:(ATApplicationScraperErrorCode)code
                         message:(NSString *)message;
+ (NSError *)scrapeErrorWithCode:(ATApplicationScraperErrorCode)code
                         message:(NSString *)message
                        userInfo:(NSDictionary<NSErrorUserInfoKey, id> *)dict;
+ (NSError *)scrapeErrorWithCode:(ATApplicationScraperErrorCode)code
                        userInfo:(NSDictionary<NSErrorUserInfoKey, id> *)dict;

+ (NSError *)errorFromCombinedErrors:(NSArray<NSError *> *)errors;

@end

NS_ASSUME_NONNULL_END
