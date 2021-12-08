//
//  ATCachedElement.h
//  ATCachedElement
//
//  Created by Tommy McHugh on 10/8/21.
//

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>
#import "ATElement.h"

NS_ASSUME_NONNULL_BEGIN

// TODO: Setup a better method of calculating changes and
// createing a dictionary of changes

@interface ATCachedElement : NSObject <NSSecureCoding>

@property (nonatomic, strong, readonly, nullable) NSString *label;
@property (nonatomic, strong, readonly, nullable) NSString *title;
@property (nonatomic, strong, readonly, nullable) NSString *role;
@property (nonatomic, strong, readonly, nullable) NSString *help;
@property (nonatomic, strong, readonly, nullable) id value;
@property (nonatomic, strong, readonly, nullable) NSString *type;
@property (nonatomic, strong, readonly, nullable) NSString *classType;
@property (nonatomic, assign, readonly) CGRect frame;

+ (instancetype)cacheElement:(ATElement *)element;
- (instancetype)init NS_UNAVAILABLE;
- (BOOL)isEqualToElement:(ATElement *)element;

@end

NS_ASSUME_NONNULL_END
