//
//  ATCachedElement.m
//  ATCachedElement
//
//  Created by Tommy McHugh on 10/8/21.
//

#import "ATCachedElement.h"

@implementation ATCachedElement

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (instancetype)cacheElement:(ATElement *)element
{
    return [[ATCachedElement alloc] initWithElement:element];
}


+ (NSArray<NSString *> *)attributeNames
{
    return @[kATElementLabelValueKey,
             kATElementTitleValueKey,
             kATElementRoleValueKey,
             kATElementValueValueKey,
             kATElementTypeValueKey,
             kATElementClassValueKey,
             kATElementFrameValueKey];
}

- (instancetype)initWithElement:(ATElement *)element
{
    self = [super init];
    if (self != nil)
    {
        NSDictionary *attributeValues = [element valuesForAttributes:[ATCachedElement attributeNames]];
        
        // Label
        id valueRef = [attributeValues objectForKey:kATElementLabelValueKey];
        (valueRef == nil || [self _isErrorValue:valueRef]) ? (_label = nil) : (_label = valueRef);
        
        // Title
        valueRef = [attributeValues objectForKey:kATElementTitleValueKey];
        (valueRef == nil || [self _isErrorValue:valueRef]) ? (_title = nil) : (_title = valueRef);

        // Role
        valueRef = [attributeValues objectForKey:kATElementRoleValueKey];
        (valueRef == nil || [self _isErrorValue:valueRef]) ? (_role = nil) : (_role = valueRef);

        // Value
        valueRef = [attributeValues objectForKey:kATElementValueValueKey];
        (valueRef == nil || [self _isErrorValue:valueRef]) ? (_value = nil) : (_value = valueRef);

        // Type
        valueRef = [attributeValues objectForKey:kATElementTypeValueKey];
        (valueRef == nil || [self _isErrorValue:valueRef]) ? (_type = nil) : (_type = valueRef);

        // ClassType
        valueRef = [attributeValues objectForKey:kATElementClassValueKey];
        (valueRef == nil || [self _isErrorValue:valueRef]) ? (_classType = nil) : (_classType = valueRef);

        // Frame
        valueRef = [attributeValues objectForKey:kATElementFrameValueKey];
        if (valueRef == nil || [self _isErrorValue:valueRef])
        {
            _frame = CGRectMake(0, 0, 0, 0);
        }
        else
        {
            AXValueRef value = (__bridge_retained AXValueRef) valueRef;
            BOOL completed = AXValueGetValue(value, kAXValueCGRectType, &_frame);
            if (!completed)
            {
                _frame = CGRectMake(0, 0, 0, 0);
            }
            CFRelease(value);
        }
    }
    return self;
}

- (BOOL)_isErrorValue:(id)value
{
    CFTypeID valueID = CFGetTypeID((__bridge CFTypeRef) value);
    if (AXValueGetTypeID() == valueID)
    {
        AXValueType valueType = AXValueGetType((__bridge AXValueRef) value);
        if (valueType == kAXValueTypeAXError)
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:ATCachedElement.class])
    {
        return NO;
    }
    ATCachedElement *cachedElement = object;
    return ((self.label == nil && cachedElement.label == nil) || [self.label isEqualToString:cachedElement.label]) &&
            ((self.title == nil && cachedElement.title == nil) || [self.title isEqualToString:cachedElement.title]) &&
            ((self.role == nil && cachedElement.role == nil) || [self.role isEqualToString:cachedElement.role]) &&
            ((self.type == nil && cachedElement.type == nil) || [self.type isEqualToString:cachedElement.type]) &&
            ((self.value == nil && cachedElement.value == nil) || [self.value isEqual:cachedElement.value]) &&
            ((self.classType == nil && cachedElement.classType == nil) || [self.classType isEqualToString:cachedElement.classType]);
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.label forKey:@"label"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.role forKey:@"role"];
    [coder encodeObject:self.value forKey:@"value"];
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeObject:self.classType forKey:@"classType"];
    [coder encodeRect:self.frame forKey:@"frame"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];
    if (self != nil)
    {
        _label = [coder decodeObjectOfClass:[NSString class] forKey:@"label"];
        _title = [coder decodeObjectOfClass:[NSString class] forKey:@"title"];
        _role = [coder decodeObjectOfClass:[NSString class] forKey:@"role"];
        NSSet *valueClasses = [NSSet setWithObjects:[NSString class], [NSNumber class], nil];
        _value = [coder decodeObjectOfClasses:valueClasses forKey:@"value"];
        _type = [coder decodeObjectOfClass:[NSString class] forKey:@"type"];
        _classType = [coder decodeObjectOfClass:[NSString class] forKey:@"classType"];
        _frame = [coder decodeRectForKey:@"frame"];
    }
    return self;
}

- (BOOL)isEqualToElement:(ATElement *)element
{
    ATCachedElement *cachedElement = [ATCachedElement cacheElement:element];
    return [self isEqual:cachedElement];
}

@end
