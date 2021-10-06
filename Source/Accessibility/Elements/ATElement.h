//
//  ATElement.h
//  ATElement
//
//  Created by Tommy McHugh on 10/4/21.
//

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

NS_ASSUME_NONNULL_BEGIN

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
- (long)childrenCount;
- (NSArray<ATElement *> *)childrenAtIndex:(NSUInteger)index maxValues:(NSUInteger)maxValues;
- (NSArray<ATElement *> *)children;
- (long)visibileChildrenCount;
- (NSArray<ATElement *> *)visibileChildren;
- (ATElement * _Nullable)parent;

@end

NS_ASSUME_NONNULL_END
