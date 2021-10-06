//
//  ATApplicationElement.m
//  ATApplicationElement
//
//  Created by Tommy McHugh on 10/4/21.
//

#import "ATApplicationElement.h"
#import "ATApplicationUtilities.h"
#import "ATElement_Private.h"

static NSString *kATApplicationElementWindowsValueKey = @"AXWindows";
static NSString *kATApplicationElementMainWindowValueKey = @"AXMainWindow";
static NSString *kATApplicationElementFocusedWindowValueKey = @"AXFocusedWindow";
static NSString *kATApplicationElementEnhancedInterfaceValueKey = @"AXEnhancedUserInterface";

@implementation ATApplicationElement

+ (ATApplicationElement * _Nullable)applicationWithName:(NSString *)name
{
    pid_t process = [ATApplicationUtilities processWithName:name];
    return [self applicationWithProcess:process];
}

+ (ATApplicationElement * _Nullable)applicationWithIdentifier:(NSString *)identifier
{
    pid_t process = [ATApplicationUtilities processWithIdentifier:identifier];
    return [self applicationWithProcess:process];
}

+ (ATApplicationElement * _Nullable)applicationWithProcess:(pid_t)process
{
    if (process == -1)
    {
        return nil;
    }
    AXUIElementRef application = AXUIElementCreateApplication(process);
    if (application == nil)
    {
        return nil;
    }
    return [[ATApplicationElement alloc] initWithElement:application];
}

- (NSArray<ATWindowElement *> *)windows
{
    NSArray * _Nullable windowRefs = [self _attributeValueForKey:kATApplicationElementWindowsValueKey];
    return [ATElement elementArrayWithElementRefs:windowRefs];
}

- (ATWindowElement * _Nullable)mainWindow
{
    AXUIElementRef elementRef = (__bridge_retained AXUIElementRef) [self _attributeValueForKey:kATApplicationElementMainWindowValueKey];
    if (elementRef == nil)
    {
        ATWindowElement *window = [[ATWindowElement alloc] initWithElement:elementRef];
        if (![window.role isEqualToString:(__bridge NSString *)kAXWindowRole])
        {
            return nil;
        }
        return window;
    }
    return nil;
}
- (ATWindowElement * _Nullable)focusedWindow
{
    AXUIElementRef elementRef = (__bridge_retained AXUIElementRef) [self _attributeValueForKey:kATApplicationElementEnhancedInterfaceValueKey];
    if (elementRef == nil)
    {
        ATWindowElement *window = [[ATWindowElement alloc] initWithElement:elementRef];
        if (![window.role isEqualToString:(__bridge NSString *)kAXWindowRole])
        {
            return nil;
        }
        return window;
    }
    return nil;
}

- (BOOL)accessibilityEnabled
{
    return NO;
}

@end
