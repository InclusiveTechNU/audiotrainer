//
//  ATApplicationEvent.m
//  ATApplicationEvent
//
//  Created by Tommy McHugh on 10/9/21.
//

#import "ATApplicationEvent.h"
#import "ATCachedElement.h"

const ATApplicationEventInfoKey kATApplicationAdditionsKey = @"ATApplicationAdditions";
const ATApplicationEventInfoKey kATApplicationDeletionsKey = @"ATApplicationDeletions";
const ATApplicationEventInfoKey kATApplicationChangesKey = @"ATApplicationChanges";

@implementation ATApplicationEvent

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (instancetype)eventWithType:(ATApplicationEventType)type
                         node:(id<ATTreeNode>)node
                     userInfo:(NSDictionary<ATApplicationEventInfoKey, id> *)userInfo
{
    NSArray<NSNumber *> *location = [ATApplicationEvent _locationForNode:node];
    NSLog(@"%@", location);
    return [[ATApplicationEvent alloc] initWithType:type location:location userInfo:userInfo time:0];
}

+ (instancetype)eventWithType:(ATApplicationEventType)type
                         location:(NSArray<NSNumber *> *)location
                     userInfo:(NSDictionary<ATApplicationEventInfoKey, id> *)userInfo
{
    return [[ATApplicationEvent alloc] initWithType:type location:location userInfo:userInfo time:0];
}

+ (void)_addLocationForNode:(id<ATTreeNode>)node withLocation:(NSMutableArray<NSNumber *> *)location
{
    NSUInteger nodeIndex = 0;
    if (node.parent != nil)
    {
        for (NSUInteger i = 0; i < node.parent.children.count; i++)
        {
            id<ATTreeNode> child = [node.parent.children objectAtIndex:i];
            if (child == node)
            {
                nodeIndex = i;
                break;
            }
        }
    }
    [location insertObject:[NSNumber numberWithLong:nodeIndex] atIndex:0];
    if (node.parent != nil)
    {
        [ATApplicationEvent _addLocationForNode:node.parent withLocation:location];
    }
}

+ (NSArray<NSNumber *> *)_locationForNode:(id<ATTreeNode>)node
{
    NSMutableArray<NSNumber *> *location = [[NSMutableArray alloc] init];
    [ATApplicationEvent _addLocationForNode:node withLocation:location];
    return location;
}

- (instancetype)initWithType:(ATApplicationEventType)type
                    location:(NSArray<NSNumber *> *)location
                    userInfo:(NSDictionary<ATApplicationEventInfoKey, id> *)userInfo
                        time:(NSTimeInterval)time
{
    self = [super init];
    if (self != nil)
    {
        _type = type;
        _userInfo = userInfo;
        _location = location;
        _level = location.count;
        _time = time;
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeDouble:self.time forKey:@"time"];
    [coder encodeInt:self.type forKey:@"type"];
    [coder encodeObject:[NSNumber numberWithUnsignedInteger:self.level] forKey:@"level"];
    [coder encodeObject:self.userInfo forKey:@"userInfo"];
    [coder encodeObject:self.location forKey:@"location"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];
    if (self != nil)
    {
        _time = [coder decodeDoubleForKey:@"time"];
        _type = [coder decodeIntForKey:@"type"];
        _level = ((NSNumber *)[coder decodeObjectOfClass:[NSNumber class] forKey:@"level"]).unsignedIntegerValue;
        _userInfo = [coder decodeObjectOfClasses:[NSSet setWithObjects:[NSDictionary class], [NSString class], [ATCachedElement class], nil]
                                          forKey:@"userInfo"];
        _location = [coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [NSNumber class], nil]
                                          forKey:@"location"];
    }
    return self;
}

- (BOOL)isOnlyValueChange:(ATApplicationEvent *)event
{
    return NO;
}

- (BOOL)isCompletedInWindow:(ATWindowElement *)window
{
    @autoreleasepool
    {
        ATElement *element = [window elementAtLocation:self.location];
        if (element == nil && self.type == kATApplicationEventDeletionEvent)
        {
            return YES;
        }
        ATCachedElement *cachedElement = [self.userInfo objectForKey:@"element"];
        return [cachedElement isEqualToElement:element];
    }
}

- (BOOL)isCompletedInApplication:(ATApplicationElement *)application
{
    @autoreleasepool
    {
        for (ATWindowElement *window in application.windows)
        {
            if ([self isCompletedInWindow:window])
            {
                return YES;
            }
        }
        return NO;
    }
}

+ (BOOL)areEventsCompleted:(NSArray<ATApplicationEvent *> *)events
             inApplication:(ATApplicationElement *)application
{
    @autoreleasepool
    {
        // TODO: Maybe have a better way of determining which window it is
        NSMutableSet<NSNumber *> *completedIndexes = [[NSMutableSet alloc] init];
        for (ATWindowElement *window in application.windows)
        {
            for (NSUInteger i = 0; i < events.count; i++)
            {
                NSNumber *numIndex = [NSNumber numberWithUnsignedInteger:i];
                if ([completedIndexes containsObject:numIndex])
                {
                    continue;
                }

                ATApplicationEvent *event = [events objectAtIndex:i];
                if ([event isCompletedInWindow:window])
                {
                    [completedIndexes addObject:numIndex];
                }
            }
        }
        return completedIndexes.count == events.count;
    }
}

@end
