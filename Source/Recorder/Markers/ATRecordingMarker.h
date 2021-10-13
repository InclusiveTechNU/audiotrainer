//
//  ATRecordingMarker.h
//  ATRecordingMarker
//
//  Created by Tommy McHugh on 10/7/21.
//

#import <Foundation/Foundation.h>
#import "ATRecordingMarkerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ATRecordingMarker <NSObject>

@property (nonatomic, weak, nullable) id<ATRecordingMarkerDelegate> delegate;

- (void)fire;

@end

NS_ASSUME_NONNULL_END
