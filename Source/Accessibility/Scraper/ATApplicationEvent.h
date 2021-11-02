//
//  ATApplicationEvent.h
//  ATApplicationEvent
//
//  Created by Tommy McHugh on 10/9/21.
//

#import <Foundation/Foundation.h>
#import "ATTreeNode.h"
#import "ATApplicationElement.h"
#import "ATWindowElement.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString *ATApplicationEventInfoKey;

extern const ATApplicationEventInfoKey kATApplicationAdditionsKey;
extern const ATApplicationEventInfoKey kATApplicationDeletionsKey;
extern const ATApplicationEventInfoKey kATApplicationChangesKey;

typedef enum {
    kATApplicationEventAdditionEvent,
    kATApplicationEventDeletionEvent,
    kATApplicationEventChangeEvent
} ATApplicationEventType;

@interface ATApplicationEvent : NSObject <NSSecureCoding>

@property (nonatomic, assign) double time;
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
+ (BOOL)areEventsCompleted:(NSArray<ATApplicationEvent *> *)events
             inApplication:(ATApplicationElement *)application;

- (BOOL)isOnlyValueChange:(ATApplicationEvent *)event;
- (BOOL)isCompletedInApplication:(ATApplicationElement *)application;
- (BOOL)isCompletedInWindow:(ATWindowElement *)window;

@end

NS_ASSUME_NONNULL_END
