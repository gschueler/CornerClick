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
    NSDictionary *tdict;
    //NSString *s=nil;
    //NSData *data;
    [[NSUserDefaults standardUserDefaults]
        removePersistentDomainForName:CC_PREF_BUNDLE_ID_STR];

    tdict=[[settings asDictionary] retain];

    //NSLog(@"prop list: %d %@",[data length],[data description]);
    //NSLog(@"saving settings, retaincount: %d",[tdict retainCount]);
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:tdict
                                                       forName:CC_PREF_BUNDLE_ID_STR];

    [[NSUserDefaults standardUserDefaults] synchronize];
    [tdict release];
    
}

+ (CornerClickSettings *) settingsFromUserPreferences
{
    NSDictionary *prefs;

    prefs = [[NSUserDefaults standardUserDefaults]
      persistentDomainForName:CC_PREF_BUNDLE_ID_STR];
    if(prefs==nil){
        prefs = [CornerClickSupport loadOldVersionPreferences];
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
                                                 forKey: [NSString stringWithFormat:@"%d",[[[[NSScreen mainScreen] deviceDescription] objectForKey:@"NSScreenNumber"] intValue]]];
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
                [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"CornerClickPref"];
                break;
        }
        if(loaded!=nil)
            return loaded;
    }
    return nil;
}

+ (id) deepMutableCopyOfObject: (id) obj
{
    //NSLog(@"start DeepMC: %@",[obj class]);
    if(obj==nil){
        NSLog(@"deepMCoO: nil");
        return nil;
    }
    else if([obj isKindOfClass: [NSString class]])
        return [obj copy];
    else if([obj isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary *x = [CornerClickSupport deepMutableCopyOfDictionary:obj];
        //NSLog(@"deepMCoO retd dict retain: %d",[x retainCount]);
        return x;
    }
    else if([obj isKindOfClass:[NSArray class]]){
        NSMutableArray *x = [CornerClickSupport deepMutableCopyOfArray:obj];
        //NSLog(@"deepMCoO retd array retain: %d",[x retainCount]);
        return x;
    }
    else if([obj conformsToProtocol:@protocol(NSMutableCopying)] &&
            [obj respondsToSelector:@selector(mutableCopyWithZone:)]){
        //NSLog(@"deepMC of NSMutableCopying: %@",[obj class]);
        return [obj mutableCopy];
    }
    else if([obj conformsToProtocol:@protocol(NSCopying)] &&
            [obj respondsToSelector:@selector(copyWithZone:)]){
        //NSLog(@"deepMC of NSCopying: %@",[obj class]);
        return [obj copy];
        
    }
    else{
        //NSLog(@"deepMCoO: same ref: %@",[obj class]);
        return obj;
    }
}
+ (NSMutableArray *) deepMutableCopyOfArray:(NSArray *) arr
{
    //DEBUG(@"deepMC of Arr");
    int i;
    id obj;
    NSMutableArray *md = [[NSMutableArray alloc] initWithCapacity:[arr count]];
    for(i=0;i<[arr count];i++){
        obj = [[CornerClickSupport deepMutableCopyOfObject: [arr objectAtIndex: i]] autorelease];
        //NSLog(@"deepMCoA add obj retain:%d",[obj retainCount]);
        [md addObject:obj];
    }
    //NSLog(@"deepMCoA return retain:%d",[md retainCount]);
    return md;
}

+ (NSMutableDictionary *) deepMutableCopyOfDictionary:(NSDictionary *) dict
{
    //DEBUG(@"deepMC of Dict");
    id key,obj;
    NSEnumerator *enumd=[dict keyEnumerator];
    NSMutableDictionary *md = [[NSMutableDictionary alloc] initWithCapacity:[dict count]];
    while(key = [enumd nextObject]){
        obj = [[CornerClickSupport deepMutableCopyOfObject: [dict objectForKey:key]] autorelease];
        //NSLog(@"deepMCoD add obj retain:%d",[obj retainCount]);
        [md setObject:obj
               forKey: key];
    }
    //NSLog(@"deepMCoD return retain:%d",[md retainCount]);
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
    int i,j;
    NSEnumerator *en;
    NSArray *corners;
    NSMutableArray *actions;
    ClickAction *act;
    id key;

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
            en=[theScreens keyEnumerator];
            while(key = [en nextObject]){
                corners = (NSArray *)[theScreens objectForKey:key];
                for(i=0;i<[corners count];i++){
                    actions = [[corners objectAtIndex: i] objectForKey:@"actionList"];
                    if(actions==nil || [actions count]==0)
                        continue;
                    for(j=0;j<[actions count];j++){
                        act = [CornerClickSettings actionFromDictionary:[actions objectAtIndex:j] withCorner: i];
                        [actions replaceObjectAtIndex:j withObject:act];
                    }
                }
            }
            //NSLog(@"initWithUserPreferences finished: theScreens: %@",theScreens);
           
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
    NSArray *cornerList = [self screenArray:screenNum];
    if(cornerList==nil)
        return nil;
    if(corner >= [cornerList count])
        return nil;
    actionList = [[cornerList objectAtIndex: corner] objectForKey:@"actionList"];
    if(actionList==nil)
        return nil;
    return [NSArray arrayWithArray:actionList];

    //cruft 
    ma = [CornerClickSupport deepMutableCopyOfObject: actionList];
    
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
- (ClickAction *) actionAtIndex: (int) index forScreen:(NSNumber *)screenNum andCorner:(int) corner
{
    return [[[[self screenArray:screenNum] objectAtIndex: corner] objectForKey:@"actionList"] objectAtIndex:index];
    
//    return [CornerClickSettings actionFromDictionary: [[[[self screenArray:screenNum] objectAtIndex: corner] objectForKey:@"actionList"] objectAtIndex:index] withCorner:corner];
}
- (void) addAction: (ClickAction *) action forScreen: (NSNumber *)screenNum andCorner:(int) corner
{
    [[[[self screenArray:screenNum] objectAtIndex: corner] objectForKey:@"actionList"] addObject:action];
//    [[[[self screenArray:screenNum] objectAtIndex: corner] objectForKey:@"actionList"] addObject:[CornerClickSettings dictionaryFromAction:action]];

}
- (void) removeActionAtIndex: (int) index forScreen: (NSNumber *)screenNum andCorner:(int) corner
{
    
    [[[[self screenArray:screenNum] objectAtIndex: corner] objectForKey:@"actionList"] removeObjectAtIndex:index];

}
- (void) replaceActionAtIndex: (int) index withAction: (ClickAction *) action forScreen: (NSNumber *)screenNum andCorner:(int)corner
{
    [[[[self screenArray:screenNum] objectAtIndex: corner] objectForKey:@"actionList"] replaceObjectAtIndex:index
                                                                                                 withObject:action];
//    [[[[self screenArray:screenNum] objectAtIndex: corner] objectForKey:@"actionList"] replaceObjectAtIndex:index                                                                                                        withObject:[CornerClickSettings dictionaryFromAction:action]];

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
    NSMutableArray *scr= [theScreens objectForKey:[NSString stringWithFormat:@"%d",[screenNum intValue]]];
    if(scr==nil){
        scr = [NSMutableArray arrayWithCapacity:4];
        tdict = [NSMutableDictionary dictionaryWithCapacity:4];
        [tdict setObject:[NSNumber numberWithBool:YES] forKey:@"enabled"];
        [tdict setObject:[NSMutableArray arrayWithCapacity:4] forKey:@"actionList"];
        [scr addObject:tdict];
        [scr addObject:[CornerClickSupport deepMutableCopyOfObject:tdict]];
        [scr addObject:[CornerClickSupport deepMutableCopyOfObject:tdict]];
        [scr addObject:[CornerClickSupport deepMutableCopyOfObject:tdict]];
        [theScreens setObject: scr forKey:[NSString stringWithFormat:@"%d",[screenNum intValue]]];
        //TODO add more empty dictionaries for edges
    }
    return scr;
}


+ (NSMutableDictionary *) dictionaryFromAction:(ClickAction *) action
{
    NSMutableDictionary *md;
    if(![action isValid]){
        return nil;
    }
    md  = [[NSMutableDictionary alloc] initWithCapacity:4];
    [md setObject:[NSNumber numberWithInt:[action type]] forKey:@"action"];
    if([ClickAction stringNameForActionType:[action type]] !=nil)
        [md setObject:[action string] forKey:[ClickAction stringNameForActionType:[action type]]];
    if([ClickAction labelNameForActionType:[action type]] !=nil)
        if([action labelSetting]!=nil)
            [md setObject:[action labelSetting] forKey:[ClickAction labelNameForActionType:[action type]]];
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
    }else{
        NSLog(@"invalid action from actionFromDictionary:%@",dict);
    }
    return click;
}
- (void) blahArray:(NSArray *)a level:(int) level
{
    int i;
    id obj;
    NSString *pad=[@"" stringByPaddingToLength: level withString: @" " startingAtIndex: 0];
    NSLog(@"%@<%@:%x>(retain:%d) [",pad,[a class],(unsigned)a,[a retainCount]);
    for(i=0;i<[a count];i++){
        obj = [a objectAtIndex:i];
        NSLog(@"%@%d:",pad,i);
        if([obj isKindOfClass:[NSDictionary class]]){
            [self blahDict:obj level:(level+1)];
        }else if([obj isKindOfClass:[NSArray class]]){
            [self blahArray:obj level:(level+1)];
        }else{
            NSLog(@" %@<%@:%x>(retain:%d):%@",pad,[obj class],(unsigned)obj,[obj retainCount],obj);
        }
    }
    NSLog(@"%@]",pad);
}

- (void) blahDict:(NSDictionary *)a level:(int) level
{
    NSEnumerator *en =[a keyEnumerator];
    id key,obj;
    NSString *pad=[@"" stringByPaddingToLength: level withString: @" " startingAtIndex: 0];
    NSLog(@"%@<%@:%x>(retain:%d) {",pad,[a class],(unsigned)a,[a retainCount]);
    while(key =[en nextObject]){
        obj = [a objectForKey:key];
        NSLog(@"%@%@<%@> = ",pad,key,[key class]);
        if([obj isKindOfClass:[NSDictionary class]]){
            [self blahDict:obj level:(level+1)];
        }else if([obj isKindOfClass:[NSArray class]]){
            [self blahArray:obj level:(level+1)];
        }else{
            NSLog(@" %@<%@:%x>(retain:%d):%@",pad,[obj class],(unsigned)obj,[obj retainCount],obj);
        }
    }
    NSLog(@"%@}",pad);
}
- (NSString *) description
{
    return [[self asDictionary] description];
}

- (NSDictionary *) asDictionary
{
    int i,j;
    id key;
    NSDictionary *act;
    NSEnumerator *en;
    NSMutableArray *actions,*corners,*newacts;
    NSMutableDictionary *md = [NSMutableDictionary dictionaryWithCapacity:5];
    NSMutableDictionary *sc = [CornerClickSupport deepMutableCopyOfObject:theScreens] ;
    //NSLog(@"deep mutable copy: %@",sc);
    //NSMutableDictionary *sc = [CornerClickSupport deepMutableCopyOfObject:theScreens] ;
    //NSDictionary *pk = [NSDictionary dictionaryWithObject:@"test" forKey:@"blah"] ;
    //NSArray *pk = [NSArray arrayWithObjects: @"test",@"blah",[NSDictionary dictionaryWithObject:@"ink" forKey:@"fart"],nil];
    //NSMutableDictionary *pk = [[NSMutableDictionary dictionaryWithObject:[NSArray arrayWithObjects:@"barf",@"cool",nil] forKey:[NSNumber numberWithInt:4]]retain] ;
    //NSMutableDictionary *sc = [CornerClickSupport deepMutableCopyOfObject:pk];
    en=[sc keyEnumerator];
    while(key = [en nextObject]){
        corners = (NSMutableArray *)[sc objectForKey:key];
        for(i=0;i<[corners count];i++){
            actions = [[corners objectAtIndex: i] objectForKey:@"actionList"];
            if(actions==nil || [actions count]==0)
                continue;
            newacts = [[[NSMutableArray alloc] initWithCapacity:[actions count]] autorelease];
            for(j=0;j<[actions count];j++){
                act = [CornerClickSettings dictionaryFromAction:[actions objectAtIndex:j]];
                //[[actions objectAtIndex:j] retain];
                //[actions replaceObjectAtIndex:j withObject:act];
                if(act!=nil){
                    [newacts addObject:act];
                }
            }
            [[corners objectAtIndex:i] setObject: newacts forKey:@"actionList"];
        }
    }
    
    [md setObject: sc forKey:@"screens"];
    [md setObject: [NSNumber numberWithInt: CC_APP_VERSION] forKey:@"appVersion"];
    [md setObject: [NSNumber numberWithBool: appEnabled] forKey:@"appEnabled"];
    [md setObject: [NSNumber numberWithBool: toolTipEnabled] forKey:@"tooltip"];
    [md setObject: [NSNumber numberWithBool: toolTipDelayed] forKey:@"tooltipDelayed"];
    [sc release];
    
    return md;
}
@end