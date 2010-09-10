/* Clicker */

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

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
    NSTimer *hoverTriggerTimer;
    NSNumber *lastScreen;
    NSPanel *hoverWin;
    BubbleView *hoverView;
	ProcessSerialNumber lastActiveProc;
	BOOL actionPerformed;
    BOOL isShowingHover;
	NSInteger lastHoverCorner;
    NSInteger lastCornerEntered;
    CGFloat hoverAlpha;
    CornerClickSettings *appSettings;
}

- (void) loadFromSettings;
- (ClickWindow *) windowForScreen:(NSNumber *) screenNum atCorner:(NSInteger) corner;
- (NSMutableArray *) screenEntry:(NSNumber *)screenNum;
- (void) reloadScreens;
- (void) clearScreen: (NSNumber *)screenNum;
- (void) setWindow:(ClickWindow *)window forScreen:(NSNumber *) screenNum atCorner:(NSInteger) corner;
- (BOOL) createClickWindowAtCorner: (NSInteger) corner withActionList: (NSArray *) actions onScreen:(NSNumber *) screenNum;
- (void) prefPaneChangedPreferences: (NSNotification *) notice;
- (BOOL) validActionType: (NSInteger) type andString: (NSString *) action;
- (void) makeHoverWindow;
- (NSString *) stringNameForActionType: (NSInteger) type;
- (NSString *) labelNameForActionType: (NSInteger) type;
- (void) hideHoverFadeOut;
- (void) hideHoverDoFadeout;
- (void)fadeOutCorner:(NSInteger)corn onScreen:(NSNumber *)num;
- (void)recalcAndShowHoverWindow: (NSInteger) corner onScreen:(NSNumber *)screenNum modifiers: (NSUInteger) modifiers;
- (void)recalcAndShowHoverWindow: (NSInteger) corner onScreen:(NSNumber *)screenNum modifiers: (NSUInteger) modifiers
                         doDelay: (BOOL) delay actionList: (BubbleActionsList *)actionsList;
-(void)showHover: (NSInteger) corner 
        onScreen: (NSNumber *)screenNum
   withModifiers: (NSUInteger) modifiers
		andTitle: (BOOL)showTitle
 withActionsList:  (BubbleActionsList *) actionsList;


- (void) doDelayedMouseHoverAtCorner:(NSInteger) corn onScreen: (NSNumber *) screenNum modifiers:(NSUInteger) modifiers
                      delayWasForced:(BOOL) forced;

- (BOOL) startMouseHoverAtCorner:(NSInteger) corn onScreen: (NSNumber *) screenNum modifiers:(NSUInteger) modifiers
                      forceDelay:(BOOL)forceDelay;
- (void) mouseExited: (NSEvent *) theEvent;
- (void) mouseDownTrigger: (NSEvent *) theEvent
				   onView: (ClickView *)view
					flags:(NSInteger) flags 
				  trigger:(NSInteger) trigger
				 onCorner:(NSInteger) corner;
- (NSColor *) highlightColor;
- (NSColor *) determineHighlightColor;
- (ProcessSerialNumber) lastActivePSN;
- (void) getNextPSN;
- (void)scroll: (NSInteger)direction  atCorner: (NSInteger)theCorner modifiers:(NSInteger) modifiers;
+ (void) listProcs;
- (void) doAction:(NSInteger) corner onScreen:(NSNumber *)num withFlags:(NSInteger)flags forTrigger:(NSInteger) trigger;
- (void)scrollWheel: (NSEvent *)theEvent  atCorner: (NSInteger)theCorner;
- (void)sendEvent:(NSEvent *)anEvent;
+(NSUInteger) eventFlagsForMods:(NSInteger)mods;
+(NSInteger) modsForEventFlags:(NSUInteger) evtFlags;
+ (NSInteger) add:(NSInteger)a to:(NSInteger)b mod:(NSInteger)m;
@end
