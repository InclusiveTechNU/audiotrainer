//
//  ATWindowElement.h
//  ATWindowElement
//
//  Created by Tommy McHugh on 10/4/21.
//

#import <AudioTrainerSupport/ATElement.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATWindowElement : ATElement

+ (NSArray *)windowArrayWithElementRefs:(NSArray *)elementRefs;
- (ATElement * _Nullable)elementAtLocation:(NSArray<NSNumber *> *)location;

@end

NS_ASSUME_NONNULL_END
