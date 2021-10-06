//
//  ATElement.h
//  ATElement
//
//  Created by Tommy McHugh on 10/4/21.
//

#import "ATElement.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATElement (Private)

+ (NSArray *)elementArrayWithElementRefs:(NSArray *)elementRefs;
- (id _Nullable)_attributeValueForKey:(NSString *)key;
- (NSArray * _Nullable)_attributeArrayValueSubsetForKey:(NSString *)key index:(NSUInteger)index maxValues:(NSUInteger)maxValues;
- (long)_attributeValueCountForkey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
