//
//  NSError+ApplicationScraper.m
//  NSError+Scraper
//
//  Created by Tommy McHugh on 10/10/21.
//

#import "NSError+ApplicationScraper.h"

static NSErrorDomain const kATApplicationScraperErrorDomain = @"";

NSString * const kATApplicationScraperUnknownErrorMessage = @"";

@implementation NSError (ApplicationScraper)

+ (NSError *)scrapeErrorWithCode:(ATApplicationScraperErrorCode)code
                         message:(NSString *)message
{
    return [NSError scrapeErrorWithCode:code userInfo:@{NSLocalizedDescriptionKey: message}];
}

+ (NSError *)scrapeErrorWithCode:(ATApplicationScraperErrorCode)code
                         message:(NSString *)message
                        userInfo:(NSDictionary<NSErrorUserInfoKey,id> *)dict
{
    NSDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:dict];
    [userInfo setValue:message forKey:NSLocalizedDescriptionKey];
    return [NSError scrapeErrorWithCode:code userInfo:userInfo];
}

+ (NSError *)scrapeErrorWithCode:(ATApplicationScraperErrorCode)code
                        userInfo:(NSDictionary<NSErrorUserInfoKey, id> *)dict
{
    return [NSError errorWithDomain:kATApplicationScraperErrorDomain
                               code:code
                           userInfo:dict];
}

+ (NSError *)errorFromCombinedErrors:(NSArray<NSError *> *)errors
{
    NSString *errorMessage;
    if (errors.count == 0)
    {
        errorMessage = @"";
    }
    else
    {
        NSMutableArray *errorMessages = [NSMutableArray arrayWithCapacity:errors.count];
        for (NSError *error in errorMessages)
        {
            [errorMessages addObject:error.localizedDescription];
        }
        errorMessage = [errorMessages componentsJoinedByString:@", "];
    }
    return [NSError scrapeErrorWithCode:kATApplicationScraperCombinedErrorCode
                               userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
}

@end
