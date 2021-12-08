//
//  ATApplicationElement.h
//  ATApplicationElement
//
//  Created by Tommy McHugh on 10/4/21.
//

#import <AudioTrainerSupport/ATElement.h>
#import <AudioTrainerSupport/ATWindowElement.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATApplicationElement : ATElement

+ (ATApplicationElement * _Nullable)applicationWithName:(NSString *)name;
+ (ATApplicationElement * _Nullable)applicationWithIdentifier:(NSString *)identifier;
+ (ATApplicationElement * _Nullable)applicationWithProcess:(pid_t)process;

- (NSArray<ATWindowElement *> *)windows;
- (ATWindowElement * _Nullable)mainWindow;
- (ATWindowElement * _Nullable)focusedWindow;
- (BOOL)accessibilityEnabled;
- (pid_t)processIdentifier;

@end

NS_ASSUME_NONNULL_END
