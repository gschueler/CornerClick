//
//  CornerClickSupport.h
//  CornerClick
//
//  Created by Greg Schueler on Wed Aug 06 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClickAction.h"
#import <Carbon/Carbon.h>

@class CornerClickSettings;

@interface CornerClickSupport : NSObject {

}
+ (id) deepMutableCopyOfObject: (id) obj;
+ (NSMutableArray *) deepMutableCopyOfArray:(NSArray *) arr;
+ (NSMutableDictionary *) deepMutableCopyOfDictionary:(NSDictionary *) dict;
+ (NSDictionary *) appPrefs;
+ (void) savePreferences: (CornerClickSettings *) settings;
+ (NSDictionary *) loadOldVersionPreferences;

+ (NSString *) labelForClickAction: (ClickAction *) clickAction localBundle: (NSBundle *) bundle;
+ (NSString *) labelForModifiers:(int)modifiers andTrigger:(int) trigger localBundle:(NSBundle *) bundle;
+ (NSString *) labelForModifiers:(int)modifiers andTrigger:(int) trigger triggerDelay:(BOOL) trigDelay localBundle:(NSBundle *) bundle;
+ (NSNumber *) numberForScreen:(NSScreen *)screen;
+ (int) modifiersForExposeAction: (int) action;
+ (int) keyCodeForExposeAction: (int) action;
+ (void) generateKeystrokeForKeyCode: (int) keycode withModifiers:(int)modifiers;
+ (NSNumber *)numberFromSomething:(id)obj;
@end

@interface CornerClickSettings : NSObject {
    NSMutableDictionary *theScreens;
    NSMutableDictionary *namedKeys;
    BOOL appEnabled;
    BOOL toolTipEnabled;
    BOOL toolTipDelayed;
	int colorOption;
	Clicker *myClicker;
	NSColor *highlightColor;
	NSColor *bubbleColorA;
	NSColor *bubbleColorB;
    float iconSize;
    float textSize;
}
+ (CornerClickSettings *) sharedSettingsFromUserPreferencesWithClicker: (Clicker *) clicker;
+ (CornerClickSettings *) sharedSettingsFromUserPreferences;
+ (CornerClickSettings *) sharedSettings;
- (void) setUserPreferences: (NSDictionary *) prefs andClicker: (Clicker *) clicker;

- (id) initWithUserPreferences: (NSDictionary *) settings andClicker: (Clicker *)clicker;
- (id) initWithUserPreferences: (NSDictionary *) settings;
- (NSMutableDictionary *)namedKeys;
- (void) setNamedKeys:(NSMutableDictionary *) keys;

- (NSArray *) actionsForScreen: (NSNumber *)screenNum andCorner:(int) corner;
- (NSArray *) actionsForScreen: (NSNumber *)screenNum andCorner:(int) corner andModifiers: (int) modifiers;
- (ClickAction *) actionAtIndex: (int) index forScreen:(NSNumber *)screenNum andCorner:(int) corner;
- (void) addAction: (ClickAction *) action forScreen: (NSNumber *)screenNum andCorner:(int) corner;
- (void) removeActionAtIndex: (int) index forScreen: (NSNumber *)screenNum andCorner:(int) corner;
- (void) replaceActionAtIndex: (int) index withAction: (ClickAction *) action forScreen: (NSNumber *)screenNum andCorner: (int)corner;

- (void) setCorner:(int) corner enabled:(BOOL)enabled forScreen:(NSNumber *)screenNum;

- (BOOL) cornerEnabled:(int) corner forScreen:(NSNumber *)screenNum;
- (int) countActionsForScreen: (NSNumber *)screenNum andCorner:(int) corner;
- (BOOL) appEnabled;
- (void) setAppEnabled:(BOOL) enabled;
- (BOOL) toolTipEnabled;
- (void) setToolTipEnabled: (BOOL) enabled;
- (BOOL) toolTipDelayed;
- (void) setHighlightColor: (NSColor *)color;
- (NSColor *) highlightColor;
+ (NSColor *) defaultHighlightColor;
- (void) setBubbleColorA: (NSColor *)color;
- (NSColor *) bubbleColorA;
+ (NSColor *) defaultBubbleColorA;
- (void) setBubbleColorB: (NSColor *)color;
- (NSColor *) bubbleColorB;
+ (NSColor *) defaultBubbleColorB;
- (float) iconSize;
- (float) textSize;
- (void) setToolTipDelayed: (BOOL) delayed;
- (void) blahArray:(NSArray *)a level:(int) level;
- (void) blahDict:(NSDictionary *)a level:(int) level;
- (int) colorOption;
- (void) setColorOption: (int) option;

- (NSMutableArray *) screenArray:(NSNumber *)screenNum;

- (NSDictionary *) asDictionary;
+ (NSMutableDictionary *) dictionaryFromAction:(ClickAction *) action;
+ (ClickAction *) actionFromDictionary:(NSDictionary *) dict withCorner:(int) corner andClicker: (Clicker *)clicker;
+ (ClickAction *) actionFromDictionary:(NSDictionary *) dict withCorner:(int) corner;


@end
/*
@interface NSWindow (ExposeStickiness)

-(void)setExposeSticky:(BOOL)flag ;

@end

*/