//
//  ATApplicationRecorderUtilities.m
//  ATApplicationRecorderUtilities
//
//  Created by Tommy McHugh on 9/28/21.
//

#import "ATApplicationRecorderUtilities.h"

@implementation ATApplicationRecorderUtilities

+ (NSArray<NSString *> *)applicationTitlesForRecorders:(NSArray<id <ATApplicationRecorder>> *)recorders
{
    NSMutableArray<NSString *> *titles = [[NSMutableArray alloc] init];
    for (id <ATApplicationRecorder> recorder in recorders)
    {
        [titles addObject:recorder.applicationName];
    }
    return titles;
}

@end
