//
//  ATApplicationUtilities.m
//  ATApplicationUtilities
//
//  Created by Tommy McHugh on 10/4/21.
//

#import <AppKit/AppKit.h>
#import "ATApplicationUtilities.h"

@implementation ATApplicationUtilities

+ (pid_t)processWithName:(NSString *)name
{
    NSWorkspace *workspace = NSWorkspace.sharedWorkspace;
    for (NSRunningApplication *application in workspace.runningApplications)
    {
        if ([application.localizedName isEqualToString:name])
        {
            return application.processIdentifier;
        }
    }
    return -1;
}

+ (pid_t)processWithIdentifier:(NSString *)identifier
{
    NSWorkspace *workspace = NSWorkspace.sharedWorkspace;
    for (NSRunningApplication *application in workspace.runningApplications)
    {
        if ([application.bundleIdentifier isEqualToString:identifier])
        {
            return application.processIdentifier;
        }
    }
    return -1;
}

@end
