//
//  ATWindowElement.m
//  ATWindowElement
//
//  Created by Tommy McHugh on 10/4/21.
//

#import "ATWindowElement.h"

@implementation ATWindowElement

// TODO: rename this
+ (ATElement * _Nullable)element:(ATElement *)element level:(NSUInteger)level location:(NSArray<NSNumber *> *)location
{
    if (level == location.count - 1)
    {
        NSArray *children = element.children;
        if (location.count > level && children.count > [location objectAtIndex:level].unsignedIntegerValue)
        {
            return [children objectAtIndex:[location objectAtIndex:level].unsignedIntegerValue];
        }
        return nil;
    }
    
    NSArray *children = element.children;
    if (location.count > level && children.count > [location objectAtIndex:level].unsignedIntegerValue)
    {
        ATElement *nextElement = [children objectAtIndex:[location objectAtIndex:level].unsignedIntegerValue];
        return [ATWindowElement element:nextElement level:level+1 location:location];
    }
    return nil;
}

// TODO: Check certain parameters
- (ATElement * _Nullable)elementAtLocation:(NSArray<NSNumber *> *)location
{
    return [ATWindowElement element:self level:1 location:location];
}

+ (NSArray *)windowArrayWithElementRefs:(NSArray *)elementRefs
{
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    if (elementRefs != nil)
    {
        for (id elementRef in elementRefs)
        {
            AXUIElementRef rawElement = (__bridge_retained AXUIElementRef) elementRef;
            ATWindowElement *element = [[ATWindowElement alloc] initWithElement:rawElement];
            [elements addObject:element];
        }
    }
    return elements;
}

@end
