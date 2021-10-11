//
//  ATApplicationEvent.h
//  ATApplicationEvent
//
//  Created by Tommy McHugh on 10/9/21.
//

#import <Foundation/Foundation.h>
#import "ATTreeNode.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString *ATApplicationEventInfoKey;

static const ATApplicationEventInfoKey kATApplicationEventAdditionsKey;
static const ATApplicationEventInfoKey kATApplicationDeletionsKey;
static const ATApplicationEventInfoKey kATApplicationChangeKey;

typedef enum {
    kATApplicationEventAdditionEvent,
    kATApplicationEventDeletionEvent,
    kATApplicationEventChangeEvent
} ATApplicationEventType;

@interface ATApplicationEvent : NSObject

@property (nonatomic, assign, readonly) ATApplicationEventType type;
@property (nonatomic, assign, readonly) NSUInteger level;
@property (nonatomic, strong, readonly) NSDictionary<ATApplicationEventInfoKey, id> *userInfo;
@property (nonatomic, strong, readonly) NSArray<NSNumber *> *location;

+ (instancetype)eventWithType:(ATApplicationEventType)type
                         node:(id<ATTreeNode>)node
                     userInfo:(NSDictionary<ATApplicationEventInfoKey, id> *)userInfo;

+ (instancetype)eventWithType:(ATApplicationEventType)type
                         location:(NSArray<NSNumber *> *)location
                     userInfo:(NSDictionary<ATApplicationEventInfoKey, id> *)userInfo;

@end

NS_ASSUME_NONNULL_END
