//
//  CornerClickSupport.h
//  CornerClick
//
//  Created by Greg Schueler on Wed Aug 06 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CornerClickSettings;
@class ClickAction;

@interface CornerClickSupport : NSObject {

}
+ (id) deepMutableCopyOfObject: (id) obj;
+ (NSMutableArray *) deepMutableCopyOfArray:(NSArray *) arr;
+ (NSMutableDictionary *) deepMutableCopyOfDictionary:(NSDictionary *) dict;

+ (void) savePreferences: (CornerClickSettings *) settings;
+ (CornerClickSettings *) settingsFromUserPreferences;
+ (NSDictionary *) loadOldVersionPreferences;

@end

@interface CornerClickSettings : NSObject {
    NSMutableDictionary *theScreens;
    BOOL appEnabled;
    BOOL toolTipEnabled;
    BOOL toolTipDelayed;
}
- (id) initWithUserPreferences: (NSDictionary *) settings;
- (NSArray *) actionsForScreen: (NSNumber *)screenNum andCorner:(int) corner;
- (NSArray *) actionsForScreen: (NSNumber *)screenNum andCorner:(int) corner andModifiers: (int) modifiers;
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
- (void) setToolTipDelayed: (BOOL) delayed;


- (NSMutableArray *) screenArray:(NSNumber *)screenNum;

- (NSDictionary *) asDictionary;
+ (NSMutableDictionary *) dictionaryFromAction:(ClickAction *) action;
+ (ClickAction *) actionFromDictionary:(NSDictionary *) dict withCorner:(int) corner;


@end