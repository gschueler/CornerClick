/* Clicker */

#import <Cocoa/Cocoa.h>
#import "ClickWindow.h"
#import "ClickAction.h"

@interface Clicker : NSObject
{
    ClickWindow *tlWin;
    ClickWindow *blWin;
    ClickWindow *trWin;
    ClickWindow *brWin;
    ClickWindow **windows[4];
    NSTrackingRectTag track[4];
    NSImage *icons[4];
    NSString *hover[4];
    //NSArray *windows;
    ClickAction *tlAction;
    NSDictionary *preferences;

    NSString *cornerNames[4];

    NSTimer *delayTimer;
    
    NSWindow *hoverWin;
    GrayView *hoverView;
    int lastHoverCorner;
}
- (void) createClickWindowAtCorner: (int) corner withActionType: (int) type andString: (NSString *)filePath ;
- (void)prefPaneChangedPreferences:(NSNotification *)notice;
- (void) loadFromPreferences: (NSDictionary *) sourcePreferences;
- (BOOL) validActionType: (int) type andString: (NSString *) action;
- (void)oneTimeMakeWindow;
@end
