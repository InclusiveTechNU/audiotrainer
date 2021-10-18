//
//  ATApplicationEvent.m
//  ATApplicationEvent
//
//  Created by Tommy McHugh on 10/9/21.
//

#import "ATApplicationEvent.h"

const ATApplicationEventInfoKey kATApplicationAdditionsKey = @"ATApplicationAdditions";
const ATApplicationEventInfoKey kATApplicationDeletionsKey = @"ATApplicationDeletions";
const ATApplicationEventInfoKey kATApplicationChangesKey = @"ATApplicationChanges";

@implementation ATApplicationEvent

+ (instancetype)eventWithType:(ATApplicationEventType)type
                         node:(id<ATTreeNode>)node
                     userInfo:(NSDictionary<ATApplicationEventInfoKey, id> *)userInfo
{
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    NSArray<NSNumber *> *location = [ATApplicationEvent _locationForNode:node];
    return [[ATApplicationEvent alloc] initWithType:type location:location userInfo:userInfo time:time];
}

+ (instancetype)eventWithType:(ATApplicationEventType)type
                         location:(NSArray<NSNumber *> *)location
                     userInfo:(NSDictionary<ATApplicationEventInfoKey, id> *)userInfo
{
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    return [[ATApplicationEvent alloc] initWithType:type location:location userInfo:userInfo time:time];
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
    [location addObject:[NSNumber numberWithLong:nodeIndex]];
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
                        time:(CFAbsoluteTime)time
{
    self = [super init];
    if (self != nil)
    {
        _type = type;
        _userInfo = userInfo;
        _location = location;
        _level = location.count;
        _startTime = time;
    }
    return self;
}

@end
