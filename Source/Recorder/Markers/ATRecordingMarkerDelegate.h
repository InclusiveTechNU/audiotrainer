//
//  ATRecordingMarkerDelegate.h
//  ATRecordingMarkerDelegate
//
//  Created by Tommy McHugh on 10/7/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ATRecordingMarker;

typedef NSString *ATRecordingMarkerUserInfoKey;
typedef NSDictionary<ATRecordingMarkerUserInfoKey, id> *ATRecordingMarkerUserInfo;

@protocol ATRecordingMarkerDelegate <NSObject>

- (void)marker:(id<ATRecordingMarker>)marker didFireWithUserInfo:(ATRecordingMarkerUserInfo)userInfo;

@end

NS_ASSUME_NONNULL_END
