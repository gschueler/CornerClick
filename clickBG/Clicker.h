/* Clicker */

#import <Cocoa/Cocoa.h>

@interface Clicker : NSObject
{
    ClickWindow *tlWin;
    ClickWindow *blWin;
    ClickWindow *trWin;
    ClickWindow *brWin;
    ClickWindow **windows[4];
    NSTrackingRectTag track[4];
    ClickAction *tlAction;
    NSMutableDictionary *preferences;
    NSString *cornerNames[4];

    NSTimer *delayTimer;
    
    NSWindow *hoverWin;
    GrayView *hoverView;
    int lastHoverCorner;
    int lastCornerEntered;
    float hoverAlpha;
}
- (BOOL) createClickWindowAtCorner: (int) corner withActionList: (NSArray *) actions;
- (void) prefPaneChangedPreferences: (NSNotification *) notice;
- (void) loadFromPreferences: (NSDictionary *) sourcePreferences;
- (BOOL) validActionType: (int) type andString: (NSString *) action;
- (void) makeHoverWindow;
- (NSString *) stringNameForActionType: (int) type;
- (NSString *) labelNameForActionType: (int) type;
- (void) hideHoverFadeOut;
- (void) hideHoverDoFadeout;
- (void) recalcAndShowHoverWindow: (int) corner modifiers: (unsigned int) modifiers;
- (void) recalcAndShowHoverWindow: (int) corner modifiers: (unsigned int) modifiers
                         doDelay: (BOOL) delay;
- (void) mouseExited: (NSEvent *) theEvent;

@end
