//
//  ATApplicationTimeline.h
//  ATApplicationTimeline
//
//  Created by Tommy McHugh on 10/9/21.
//

#import <Foundation/Foundation.h>
#import "ATApplicationEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATApplicationTimeline : NSObject {
    NSMutableArray<ATApplicationEvent *> *_events;
    CFAbsoluteTime _startTime;
}

@property (nonatomic, strong, readonly) NSArray<ATApplicationEvent *> *events;

- (void)addEvent:(ATApplicationEvent *)event;

@end

NS_ASSUME_NONNULL_END
