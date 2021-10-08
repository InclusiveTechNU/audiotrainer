//
//  ATElement.h
//  ATElement
//
//  Created by Tommy McHugh on 10/4/21.
//

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kATElementLabelValueKey;
extern NSString * const kATElementRoleValueKey;
extern NSString * const kATElementTitleValueKey;
extern NSString * const kATElementValueValueKey;
extern NSString * const kATElementTypeValueKey;
extern NSString * const kATElementClassValueKey;
extern NSString * const kATElementChildrenValueKey;
extern NSString * const kATElementFrameValueKey;
extern NSString * const kATElementParentValueKey;
extern NSString * const kATElementVisibleChildrenKey;

@class ATApplicationElement;

@interface ATElement : NSObject

@property(nonatomic, assign, readonly) AXUIElementRef element;

+ (ATElement * _Nullable)elementAtPoint:(CGPoint)point inApplication:(ATApplicationElement *)application;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithElement:(AXUIElementRef)element;
- (NSString * _Nullable)label;
- (NSString * _Nullable)role;
- (NSString * _Nullable)title;
- (CGRect)frame;
- (ATElement * _Nullable)parent;

- (long)childrenCount;
- (NSArray<ATElement *> *)children;
- (NSArray<ATElement *> *)childrenAtIndex:(NSUInteger)index maxValues:(NSUInteger)maxValues;

- (long)visibileChildrenCount;
- (NSArray<ATElement *> *)visibileChildren;
- (NSArray<ATElement *> *)visibileChildrenAtIndex:(NSUInteger)index maxValues:(NSUInteger)maxValues;

- (NSDictionary *)valuesForAttributes:(NSArray<NSString *> *)attributes;

@end

NS_ASSUME_NONNULL_END
