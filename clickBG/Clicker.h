/* Clicker */

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "CCStickyWindow.h"

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
    NSTimer *fadeTimer;
    NSNumber *lastScreen;
    NSPanel *hoverWin;
    BubbleView *hoverView;
	ProcessSerialNumber lastActiveProc;
	BOOL actionPerformed;
    BOOL isShowingHover;
	int lastHoverCorner;
    int lastCornerEntered;
    float hoverAlpha;
    CornerClickSettings *appSettings;
}

- (void) loadFromSettings;
- (ClickWindow *) windowForScreen:(NSNumber *) screenNum atCorner:(int) corner;
- (NSMutableArray *) screenEntry:(NSNumber *)screenNum;
- (void) reloadScreens;
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
- (void)fadeOutCorner:(int)corn onScreen:(NSNumber *)num;
- (void)recalcAndShowHoverWindow: (int) corner onScreen:(NSNumber *)screenNum modifiers: (unsigned int) modifiers;
- (void)recalcAndShowHoverWindow: (int) corner onScreen:(NSNumber *)screenNum modifiers: (unsigned int) modifiers
                         doDelay: (BOOL) delay actionList: (BubbleActionsList *)actionsList;
-(void)showHover: (int) corner 
        onScreen: (NSNumber *)screenNum
   withModifiers: (unsigned int) modifiers
		andTitle: (BOOL)showTitle
 withActionsList:  (BubbleActionsList *) actionsList;

- (void) mouseExited: (NSEvent *) theEvent;
- (void) mouseDownTrigger: (NSEvent *) theEvent
				   onView: (ClickView *)view
					flags:(int) flags 
				  trigger:(int) trigger
				 onCorner:(int) corner;
- (NSColor *) highlightColor;
- (NSColor *) determineHighlightColor;
- (ProcessSerialNumber) lastActivePSN;
- (void) getNextPSN;
- (void)scroll: (int)direction  atCorner: (int)theCorner modifiers:(int) modifiers;
+ (void) listProcs;
- (void) doAction:(int) corner onScreen:(NSNumber *)num withFlags:(int)flags forTrigger:(int) trigger;
- (void)scrollWheel: (NSEvent *)theEvent  atCorner: (int)theCorner;

+(unsigned int) eventFlagsForMods:(int)mods;
+(int) modsForEventFlags:(unsigned int) evtFlags;
+ (int) add:(int)a to:(int)b mod:(int)m;
@end
