/*
 Copyright 2003-2010 Greg Schueler
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
+ (NSString *) labelForModifiers:(NSInteger)modifiers andTrigger:(NSInteger) trigger localBundle:(NSBundle *) bundle;
+ (NSString *) labelForModifiers:(NSInteger)modifiers andTrigger:(NSInteger) trigger triggerDelay:(BOOL) trigDelay localBundle:(NSBundle *) bundle;
+ (NSNumber *) numberForScreen:(NSScreen *)screen;
+ (NSInteger) modifiersForExposeAction: (NSInteger) action;
+ (NSInteger) keyCodeForExposeAction: (NSInteger) action;
+ (void) generateKeystrokeForKeyCode: (NSInteger) keycode withModifiers:(NSInteger)modifiers;
+ (NSNumber *)numberFromSomething:(id)obj;
@end

@interface CornerClickSettings : NSObject {
    NSMutableDictionary *theScreens;
    NSMutableDictionary *namedKeys;
    BOOL appEnabled;
    BOOL toolTipEnabled;
    BOOL toolTipDelayed;
	NSInteger colorOption;
	Clicker *myClicker;
	NSColor *highlightColor;
	NSColor *bubbleColorA;
	NSColor *bubbleColorB;
    CGFloat iconSize;
    CGFloat textSize;
    CGFloat hoverDelayTime;
    CGFloat tooltipDelayTime;
}
+ (CornerClickSettings *) sharedSettingsFromUserPreferencesWithClicker: (Clicker *) clicker;
+ (CornerClickSettings *) sharedSettingsFromUserPreferences;
+ (CornerClickSettings *) sharedSettings;
- (void) setUserPreferences: (NSDictionary *) prefs andClicker: (Clicker *) clicker;

- (id) initWithUserPreferences: (NSDictionary *) settings andClicker: (Clicker *)clicker;
- (id) initWithUserPreferences: (NSDictionary *) settings;
- (NSMutableDictionary *)namedKeys;
- (void) setNamedKeys:(NSMutableDictionary *) keys;

- (NSArray *) actionsForScreen: (NSNumber *)screenNum andCorner:(NSInteger) corner;
- (NSArray *) actionsForScreen: (NSNumber *)screenNum andCorner:(NSInteger) corner andModifiers: (NSInteger) modifiers;
- (ClickAction *) actionAtIndex: (NSInteger) index forScreen:(NSNumber *)screenNum andCorner:(NSInteger) corner;
- (void) addAction: (ClickAction *) action forScreen: (NSNumber *)screenNum andCorner:(NSInteger) corner;
- (void) removeActionAtIndex: (NSInteger) index forScreen: (NSNumber *)screenNum andCorner:(NSInteger) corner;
- (void) replaceActionAtIndex: (NSInteger) index withAction: (ClickAction *) action forScreen: (NSNumber *)screenNum andCorner: (NSInteger)corner;

- (void) setCorner:(NSInteger) corner enabled:(BOOL)enabled forScreen:(NSNumber *)screenNum;

- (BOOL) cornerEnabled:(NSInteger) corner forScreen:(NSNumber *)screenNum;
- (NSInteger) countActionsForScreen: (NSNumber *)screenNum andCorner:(NSInteger) corner;
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
- (CGFloat) iconSize;
- (CGFloat) textSize;
- (CGFloat) hoverDelayTime;
- (void) setHoverDelayTime:(CGFloat)delay;
- (CGFloat) tooltipDelayTime;
- (void) setTooltipDelayTime:(CGFloat)delay;
- (void) setToolTipDelayed: (BOOL) delayed;
//- (void) blahArray:(NSArray *)a level:(int) level;
//- (void) blahDict:(NSDictionary *)a level:(int) level;
- (NSInteger) colorOption;
- (void) setColorOption: (NSInteger) option;

- (NSMutableArray *) screenArray:(NSNumber *)screenNum;

- (NSDictionary *) asDictionary;
+ (NSMutableDictionary *) dictionaryFromAction:(ClickAction *) action;
+ (ClickAction *) actionFromDictionary:(NSDictionary *) dict withCorner:(NSInteger) corner andClicker: (Clicker *)clicker;
+ (ClickAction *) actionFromDictionary:(NSDictionary *) dict withCorner:(NSInteger) corner;


@end
/*
@interface NSWindow (ExposeStickiness)

-(void)setExposeSticky:(BOOL)flag ;

@end

*/