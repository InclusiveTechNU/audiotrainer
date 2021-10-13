//
//  ATKeyboardRecordingMarker.h
//  ATKeyboardRecordingMarker
//
//  Created by Tommy McHugh on 10/7/21.
//

#import <Foundation/Foundation.h>
#import "ATRecordingMarker.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATKeyboardRecordingMarker : NSObject <ATRecordingMarker> {
    
}

@property (nonatomic, weak, nullable) id<ATRecordingMarkerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
