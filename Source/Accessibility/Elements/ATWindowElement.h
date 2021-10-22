//
//  ATWindowElement.h
//  ATWindowElement
//
//  Created by Tommy McHugh on 10/4/21.
//

#import "ATElement.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATWindowElement : ATElement

- (ATElement * _Nullable)elementAtLocation:(NSArray<NSNumber *> *)location;
+ (NSArray *)windowArrayWithElementRefs:(NSArray *)elementRefs;

@end

NS_ASSUME_NONNULL_END
