//
//  ATApplicationEvent.m
//  ATApplicationEvent
//
//  Created by Tommy McHugh on 10/9/21.
//

#import "ATApplicationEvent.h"

@implementation ATApplicationEvent

+ (instancetype)eventWithType:(ATApplicationEventType)type
                         node:(id<ATTreeNode>)node
                     userInfo:(NSDictionary<ATApplicationEventInfoKey, id> *)userInfo
{
    NSArray<NSNumber *> *location = [ATApplicationEvent _locationForNode:node];
    return [[ATApplicationEvent alloc] initWithType:type location:location userInfo:userInfo];
}

+ (instancetype)eventWithType:(ATApplicationEventType)type
                         location:(NSArray<NSNumber *> *)location
                     userInfo:(NSDictionary<ATApplicationEventInfoKey, id> *)userInfo
{
    return [[ATApplicationEvent alloc] initWithType:type location:location userInfo:userInfo];
}

+ (NSArray<NSNumber *> *)_locationForNode:(id<ATTreeNode>)node
{
    NSMutableArray<NSNumber *> *location = [[NSMutableArray alloc] init];
    void (^addLocation)(id<ATTreeNode>,
                        NSMutableArray<NSNumber *> *) = ^(id<ATTreeNode> nodeRef,
                                                          NSMutableArray<NSNumber *> *locationRef)
    {
        NSUInteger nodeRefIndex = 0;
        if (nodeRef.parent != nil)
        {
            for (NSUInteger i = 0; i < nodeRef.parent.children.count; i++)
            {
                id<ATTreeNode> childRef = [nodeRef.parent.children objectAtIndex:i];
                if (childRef == nodeRef)
                {
                    nodeRefIndex = i;
                    break;
                }
            }
            
        }
        [locationRef addObject:[NSNumber numberWithLong:nodeRefIndex]];
    };
    addLocation(node, location);
    return location;
}

- (instancetype)initWithType:(ATApplicationEventType)type
                    location:(NSArray<NSNumber *> *)location
                    userInfo:(NSDictionary<ATApplicationEventInfoKey, id> *)userInfo
{
    self = [super init];
    if (self != nil)
    {
        _type = type;
        _userInfo = userInfo;
        _location = location;
        _level = location.count;
    }
    return self;
}

@end
