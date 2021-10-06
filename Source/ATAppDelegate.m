//
//  AppDelegate.m
//  AudioTrainer
//
//  Created by Tommy McHugh on 9/28/21.
//

#import "ATAppDelegate.h"

static CGFloat kWindowXAxisPadding = 10.0;
static CGFloat kWindowYAxisPadding = 10.0;
static CGFloat kWindowHeight = 140.0;
static CGFloat kWindowWidth = 440.0;

@interface ATAppDelegate ()


@end

@implementation ATAppDelegate

- (void)setupWindow:(NSWindow *)window
{
    NSScreen *mainScreen = NSScreen.mainScreen;
    CGFloat originX = 0.0;
    CGFloat originY = 0.0;
    if (mainScreen != NULL)
    {
        originX = (mainScreen.frame.size.width - kWindowWidth) - kWindowXAxisPadding;
        originY = (mainScreen.frame.size.height - window.menu.menuBarHeight - kWindowHeight) - kWindowYAxisPadding;
    }
    [window setFrame:NSMakeRect(originX, originY, kWindowWidth, kWindowHeight) display:YES animate:NO];
    
    window.titlebarAppearsTransparent = YES;
    window.titleVisibility = NSWindowTitleHidden;
    window.styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskFullSizeContentView;
    window.opaque = NO;
    window.backgroundColor = NSColor.clearColor;
    window.movable = NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    for (NSWindow *window in NSApp.windows)
    {
        [self setupWindow:window];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app
{
    return YES;
}


@end
