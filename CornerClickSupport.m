//
//  CornerClickSupport.m
//  CornerClick
//
//  Created by Greg Schueler on Wed Aug 06 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "CornerClickSupport.h"


@implementation CornerClickSupport

+ (void) savePreferences: (CornerClickSettings *) settings;
{
    [[NSUserDefaults standardUserDefaults]
        removePersistentDomainForName:CC_PREF_BUNDLE_ID_STR];


    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[settings asDictionary]
                                                       forName:CC_PREF_BUNDLE_ID_STR];

    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (CornerClickSettings *) settingsFromUserPreferences
{
    NSDictionary *prefs;

    prefs = [[NSUserDefaults standardUserDefaults]
      persistentDomainForName:CC_PREF_BUNDLE_ID_STR];
    if(prefs==nil){
        prefs = [CornerClickSupport loadOldVersionPreferences];
    }
    if(prefs==nil){
        return nil;
    }
    //NSLog(@"loaded prefs: %@",prefs);
    return [[[CornerClickSettings alloc] initWithUserPreferences: prefs] autorelease];
    
}

+ (NSDictionary *) loadOldVersionPreferences
{
    NSDictionary *loaded=nil;
    NSMutableDictionary *md;
    NSMutableArray *ma;
    //attempt to load the preferences if set from an older version of CornerClick
    int i=CC_APP_VERSION;
    for(i=(CC_APP_VERSION-1);i>0;i--){
        switch(i){
            case 1: //v0.1
                loaded=[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"CornerClickPref"];
                if(loaded==nil)
                    break;
                md = [[NSMutableDictionary alloc] initWithCapacity: 4];
                [md setObject: [[[NSMutableDictionary alloc] initWithCapacity:4] autorelease]
                       forKey: @"screens"];
                ma = [[[NSMutableArray alloc] initWithCapacity: 4] autorelease];
                [[md objectForKey:@"screens"] setObject: ma
                                                 forKey: [[[NSScreen mainScreen] deviceDescription] objectForKey:@"NSScreenNumber"]];
                [ma addObject:[loaded objectForKey:@"tl"]];
                [ma addObject:[loaded objectForKey:@"tr"]];
                [ma addObject:[loaded objectForKey:@"bl"]];
                [ma addObject:[loaded objectForKey:@"br"]];
                [md setObject:[loaded objectForKey:@"tooltip"] forKey:@"tooltip"];
                [md setObject:[loaded objectForKey:@"tooltipDelayed"] forKey:@"tooltipDelayed"];
                [md setObject:[loaded objectForKey:@"appEnabled"] forKey:@"appEnabled"];
                [md setObject:[NSNumber numberWithInt:CC_APP_VERSION] forKey:@"appVersion"];
                [md autorelease];
                loaded=md;
                //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"CornerClickPref"];
                break;
        }
        if(loaded!=nil)
            return loaded;
    }
    return nil;
}

+ (id) deepMutableCopyOfObject: (id) obj
{
    if(obj==nil)
        return nil;
    else if([obj isKindOfClass:[NSDictionary class]])
        return [CornerClickSupport deepMutableCopyOfDictionary:obj];
    else if([obj isKindOfClass:[NSArray class]])
        return [CornerClickSupport deepMutableCopyOfArray:obj];
    else if([obj conformsToProtocol:@protocol(NSMutableCopying)] &&
            [obj respondsToSelector:@selector(mutableCopyWithZone:)])
        return [obj mutableCopy];
    else if([obj conformsToProtocol:@protocol(NSCopying)] &&
            [obj respondsToSelector:@selector(copyWithZone:)])
        return [obj copy];
    else
        return obj;
}
+ (NSMutableArray *) deepMutableCopyOfArray:(NSArray *) arr
{
    int i;
    NSMutableArray *md = [[NSMutableArray alloc] initWithCapacity:[arr count]];
    for(i=0;i<[arr count];i++){
        [md addObject:[[CornerClickSupport deepMutableCopyOfObject: [arr objectAtIndex: i]] autorelease]];
    }
    return md;
}

+ (NSMutableDictionary *) deepMutableCopyOfDictionary:(NSDictionary *) dict
{
    id key;
    NSEnumerator *enumd=[dict keyEnumerator];
    NSMutableDictionary *md = [[NSMutableDictionary alloc] initWithCapacity:[dict count]];
    while(key = [enumd nextObject]){
        [md setObject:[[CornerClickSupport deepMutableCopyOfObject: [dict objectForKey:key]] autorelease]
               forKey: key];
    }
    return md;
}

@end

@implementation CornerClickSettings

- (id) init
{
    return [self initWithUserPreferences: nil];
}

- (id) initWithUserPreferences: (NSDictionary *) prefs
{
    int num=-1;

    if(self = [super init]){

        if(prefs!=nil) {
            num = [[prefs objectForKey:@"appVersion"] intValue];
            if(num!=CC_APP_VERSION){
                return nil;
            }
            appEnabled = [[prefs objectForKey:@"appEnabled"] boolValue];
            toolTipEnabled = [[prefs objectForKey:@"tooltip"] boolValue];
            toolTipDelayed = [[prefs objectForKey:@"tooltipDelayed"] boolValue];

            theScreens=[CornerClickSupport deepMutableCopyOfObject: [prefs objectForKey:@"screens"]];
           
        }else{
            theScreens = [[NSMutableDictionary alloc] initWithCapacity:2];
            appEnabled=YES;
            toolTipEnabled=YES;
            toolTipDelayed=YES;
        }
        
    }
    return self;
}

- (NSArray *) actionsForScreen: (NSNumber *)screenNum andCorner:(int) corner
{
    return [self actionsForScreen:screenNum andCorner:corner andModifiers:-1];
}

- (NSArray *) actionsForScreen: (NSNumber *)screenNum andCorner:(int) corner andModifiers: (int) tmodifiers
{
    int i,modifiers;
    ClickAction *click;
    NSMutableArray *ma;
    NSArray *actionList;
    NSArray *cornerList = [theScreens objectForKey:screenNum];
    if(cornerList==nil)
        return nil;
    if(corner >= [cornerList count])
        return nil;
    actionList = [[cornerList objectAtIndex: corner] objectForKey:@"actionList"];
    if(actionList==nil)
        return nil;
    ma = [[NSMutableArray alloc] initWithCapacity:[actionList count]];

    for(i=0;i<[actionList count];i++){
        click = [CornerClickSettings actionFromDictionary:[actionList objectAtIndex:i] withCorner:corner];
        modifiers = [[[actionList objectAtIndex:i] objectForKey:@"modifiers"] intValue];
        if(tmodifiers>=0 && modifiers!=tmodifiers)
            continue;
        if(click!=nil)
            [ma addObject:click];
        
    }
    [ma autorelease];
    return ma;
}
- (void) addAction: (ClickAction *) action forScreen: (NSNumber *)screenNum andCorner:(int) corner
{
    [[[[theScreens objectForKey:screenNum] objectAtIndex: corner] objectForKey:@"actionList"] addObject:[CornerClickSettings dictionaryFromAction:action]];

}
- (void) removeActionAtIndex: (int) index forScreen: (NSNumber *)screenNum andCorner:(int) corner
{
    
    [[[[self screenArray:screenNum] objectAtIndex: corner] objectForKey:@"actionList"] removeObjectAtIndex:index];

}
- (void) replaceActionAtIndex: (int) index withAction: (ClickAction *) action forScreen: (NSNumber *)screenNum andCorner:(int)corner
{
    [[[[self screenArray:screenNum] objectAtIndex: corner] objectForKey:@"actionList"] replaceObjectAtIndex:index
                                                                                                        withObject:[CornerClickSettings dictionaryFromAction:action]];

}

- (void) setCorner:(int) corner enabled:(BOOL)enabled forScreen:(NSNumber *)screenNum
{
    [[[self screenArray:screenNum] objectAtIndex: corner]  setObject:[NSNumber numberWithBool:enabled] forKey:@"enabled"];
    
}
- (BOOL) cornerEnabled:(int) corner forScreen:(NSNumber *)screenNum
{
    return [[[[self screenArray:screenNum] objectAtIndex: corner]  objectForKey:@"enabled"] boolValue];
}

- (int) countActionsForScreen: (NSNumber *)screenNum andCorner:(int) corner
{
    return [[[[self screenArray:screenNum] objectAtIndex:corner] objectForKey:@"actionList"] count];
}
- (BOOL) appEnabled
{
    return appEnabled;
}
- (void) setAppEnabled:(BOOL) enabled
{
    appEnabled=enabled;
}
- (BOOL) toolTipEnabled
{
    return toolTipEnabled;
}
- (void) setToolTipEnabled: (BOOL) enabled
{
    toolTipEnabled=enabled;
}
- (BOOL) toolTipDelayed
{
    return toolTipDelayed;
}
- (void) setToolTipDelayed: (BOOL) delayed
{
    toolTipDelayed=delayed;
}


- (NSMutableArray *) screenArray:(NSNumber *) screenNum
{
    NSMutableDictionary *tdict;
    NSMutableArray *scr= [theScreens objectForKey:screenNum];
    if(scr==nil){
        scr = [NSMutableArray arrayWithCapacity:4];
        tdict = [NSMutableDictionary dictionaryWithCapacity:4];
        [tdict setObject:[NSNumber numberWithBool:YES] forKey:@"enabled"];
        [tdict setObject:[NSMutableArray arrayWithCapacity:4] forKey:@"actionList"];
        [scr addObject:tdict];
        [scr addObject:[CornerClickSupport deepMutableCopyOfObject:tdict]];
        [scr addObject:[CornerClickSupport deepMutableCopyOfObject:tdict]];
        [scr addObject:[CornerClickSupport deepMutableCopyOfObject:tdict]];
        //TODO add more empty dictionaries for edges
    }
    return scr;
}


+ (NSMutableDictionary *) dictionaryFromAction:(ClickAction *) action
{
    NSMutableDictionary *md = [[NSMutableDictionary alloc] initWithCapacity:4];
    [md setObject:[NSNumber numberWithInt:[action type]] forKey:@"action"];
    if([ClickAction stringNameForActionType:[action type]] !=nil)
        [md setObject:[action string] forKey:[ClickAction stringNameForActionType:[action type]]];
    if([ClickAction labelNameForActionType:[action type]] !=nil)
        [md setObject:[action label] forKey:[ClickAction labelNameForActionType:[action type]]];
    [md setObject:[NSNumber numberWithInt:[action modifiers]] forKey:@"modifiers"];
    return [md autorelease];
}

+ (ClickAction *) actionFromDictionary:(NSDictionary *) dict withCorner: (int) corner
{
    int actionType,modifiers;
    NSString *action,*label;
    ClickAction *click=nil;
    actionType =[[dict objectForKey:@"action"] intValue];
    action = [dict objectForKey:[ClickAction stringNameForActionType:actionType]];
    label = [dict objectForKey:[ClickAction labelNameForActionType:actionType]];
    modifiers = [[dict objectForKey:@"modifiers"] intValue];

    if([ClickAction validActionType: actionType andString: action]){
            click = [[[ClickAction alloc] initWithType:actionType
                                  andModifiers:modifiers
                                     andString:action
                                     forCorner: corner
                                     withLabel:label
                                    andClicker:self]
                autorelease];
    }
    return click;
}

- (NSDictionary *) asDictionary
{
    NSMutableDictionary *md = [[NSMutableDictionary alloc] initWithCapacity:5];
    [md setObject: [CornerClickSupport deepMutableCopyOfObject:theScreens] forKey:@"screens"];
    [md setObject: [NSNumber numberWithInt: CC_APP_VERSION] forKey:@"appVersion"];
    [md setObject: [NSNumber numberWithBool: appEnabled] forKey:@"appEnabled"];
    [md setObject: [NSNumber numberWithBool: toolTipEnabled] forKey:@"tooltip"];
    [md setObject: [NSNumber numberWithBool: toolTipDelayed] forKey:@"tooltipDelayed"];
    return [md autorelease];
}
@end