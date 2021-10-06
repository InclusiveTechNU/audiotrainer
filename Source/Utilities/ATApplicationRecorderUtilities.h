//
//  ATApplicationRecorderUtilities.h
//  ATApplicationRecorderUtilities
//
//  Created by Tommy McHugh on 9/28/21.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "ATApplicationRecorder.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATApplicationRecorderUtilities : NSObject

+ (NSArray<NSString *> *)applicationTitlesForRecorders:(NSArray<id <ATApplicationRecorder>> *)recorders;

@end

NS_ASSUME_NONNULL_END
