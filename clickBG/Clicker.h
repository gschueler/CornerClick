/* Clicker */

#import <Cocoa/Cocoa.h>

@interface Clicker : NSObject
{
   // ClickWindow *tlWin;
   // ClickWindow *blWin;
   // ClickWindow *trWin;
   // ClickWindow *brWin;
   // ClickWindow **windows[4];
    NSTrackingRectTag track[4];
   // ClickAction *tlAction;
    //NSMutableDictionary *preferences;
    //NSString *cornerNames[4];
    NSMutableDictionary *allScreens;
    NSMutableDictionary *screenWindows;
    NSMutableDictionary *trackCache;

    NSTimer *delayTimer;
    
    NSWindow *hoverWin;
    GrayView *hoverView;
    int lastHoverCorner;
    int lastCornerEntered;
    float hoverAlpha;
    CornerClickSettings *appSettings;
}

- (void) loadFromSettings;
- (ClickWindow *) windowForScreen:(NSNumber *) screenNum atCorner:(int) corner;
- (NSMutableArray *) screenEntry:(NSNumber *)screenNum;
- (void) clearScreen: (NSNumber *)screenNum;
- (void) setWindow:(ClickWindow *)window forScreen:(NSNumber *) screenNum atCorner:(int) corner;
- (BOOL) createClickWindowAtCorner: (int) corner withActionList: (NSArray *) actions onScreen:(NSNumber *) screenNum;
- (void) prefPaneChangedPreferences: (NSNotification *) notice;
- (BOOL) validActionType: (int) type andString: (NSString *) action;
- (void) makeHoverWindow;
- (NSString *) stringNameForActionType: (int) type;
- (NSString *) labelNameForActionType: (int) type;
- (void) hideHoverFadeOut;
- (void) hideHoverDoFadeout;
- (void)recalcAndShowHoverWindow: (int) corner onScreen:(NSNumber *)screenNum modifiers: (unsigned int) modifiers;
- (void)recalcAndShowHoverWindow: (int) corner onScreen:(NSNumber *)screenNum modifiers: (unsigned int) modifiers
                         doDelay: (BOOL) delay;
- (void) mouseExited: (NSEvent *) theEvent;
- (void) mouseDownTrigger: (NSEvent *) theEvent;

@end
