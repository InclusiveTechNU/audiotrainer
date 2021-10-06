//
//  ATElement.m
//  ATElement
//
//  Created by Tommy McHugh on 10/4/21.
//

#import "ATElement.h"
#import "ATElement_Private.h"
#import "ATApplicationElement.h"

static NSString *kATElementLabelValueKey = @"AXDescription";
static NSString *kATElementRoleValueKey = @"AXRole";
static NSString *kATElementTitleValueKey = @"AXTitle";
static NSString *kATElementChildrenValueKey = @"AXChildren";
static NSString *kATElementFrameValueKey = @"AXFrame";
static NSString *kATElementVisibleChildrenKey = @"AXVisibleChildren";

@implementation ATElement

+ (NSArray *)elementArrayWithElementRefs:(NSArray *)elementRefs
{
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    if (elementRefs != nil)
    {
        for (id elementRef in elementRefs)
        {
            AXUIElementRef rawElement = (__bridge_retained AXUIElementRef) elementRef;
            ATElement *element = [[ATElement alloc] initWithElement:rawElement];
            [elements addObject:element];
        }
    }
    return elements;
}

+ (ATElement * _Nullable)elementAtPoint:(CGPoint)point inApplication:(ATApplicationElement *)application
{
    AXUIElementRef element = nil;
    AXError error = AXUIElementCopyElementAtPosition(application.element, point.x, point.y, &element);
    if (error != kAXErrorSuccess || element == nil)
    {
        return nil;
    }
    return [[ATElement alloc] initWithElement:element];
}

- (instancetype)initWithElement:(AXUIElementRef)element
{
    self = [super init];
    if (self != nil)
    {
        _element = element;
    }
    return self;
}

- (void)dealloc
{
    CFRelease(_element);
}

- (id _Nullable)_attributeValueForKey:(NSString *)key
{
    CFTypeRef valueRef = nil;
    AXError error = AXUIElementCopyAttributeValue(self.element, (__bridge CFStringRef) key, &valueRef);
    if (error != kAXErrorSuccess)
    {
        return nil;
    }
    return (__bridge_transfer id) valueRef;
}

- (long)_attributeValueCountForkey:(NSString *)key
{
    long count = -1;
    AXUIElementGetAttributeValueCount(self.element, (__bridge CFStringRef) key, &count);
    return count;
}

- (NSArray * _Nullable)_attributeArrayValueSubsetForKey:(NSString *)key index:(NSUInteger)index maxValues:(NSUInteger)maxValues
{
    CFArrayRef valuesRef = nil;
    AXError error = AXUIElementCopyAttributeValues(self.element, (__bridge CFStringRef) key, index, maxValues, &valuesRef);
    if (error != kAXErrorSuccess)
    {
        return nil;
    }
    return (__bridge_transfer id) valuesRef;
}

- (NSString * _Nullable)label
{
    return [self _attributeValueForKey:kATElementLabelValueKey];
}

- (NSString * _Nullable)role
{
    return [self _attributeValueForKey:kATElementRoleValueKey];
}

- (NSString * _Nullable)title
{
    return [self _attributeValueForKey:kATElementTitleValueKey];
}

- (CGRect)frame
{
    CGRect frame;
    AXValueGetValue((__bridge_retained AXValueRef) [self _attributeValueForKey:kATElementFrameValueKey], kAXValueCGRectType, &frame);
    return frame;
}

- (long)childrenCount
{
    return [self _attributeValueCountForkey:kATElementChildrenValueKey];
}

- (NSArray<ATElement *> *)childrenAtIndex:(NSUInteger)index maxValues:(NSUInteger)maxValues
{
    NSArray * _Nullable childrenRefs = [self _attributeArrayValueSubsetForKey:kATElementChildrenValueKey index:index maxValues:maxValues];
    return [ATElement elementArrayWithElementRefs:childrenRefs];
}

- (NSArray<ATElement *> *)children
{
    NSArray * _Nullable childrenRefs = [self _attributeValueForKey:kATElementChildrenValueKey];
    return [ATElement elementArrayWithElementRefs:childrenRefs];
}

- (long)visibileChildrenCount
{
    return [self _attributeValueCountForkey:kATElementVisibleChildrenKey];
}

- (NSArray<ATElement *> *)visibileChildren
{
    NSArray * _Nullable childrenRefs = [self _attributeValueForKey:kATElementVisibleChildrenKey];
    return [ATElement elementArrayWithElementRefs:childrenRefs];
}

- (ATElement * _Nullable)parent
{
    AXUIElementRef rawElement = (__bridge_retained AXUIElementRef) [self _attributeValueForKey:@"AXParent"];
    if (rawElement == nil)
    {
        return nil;
    }
    return [[ATElement alloc] initWithElement:rawElement];
}

@end
