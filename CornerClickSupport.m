//
//  CornerClickSupport.m
//  CornerClick
//
//  Created by Greg Schueler on Wed Aug 06 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "CornerClickSupport.h"
@implementation CornerClickSupport

+ (void) savePreferences: (CornerClickSettings *) settings
{
    NSMutableDictionary *tdict;
    //NSString *s=nil;
    //NSData *data;
    [[NSUserDefaults standardUserDefaults]
        removePersistentDomainForName:CC_PREF_BUNDLE_ID_STR];

    tdict=[[settings asDictionary] retain];

    NSEnumerator *en = [[settings namedKeys] keyEnumerator];
    id obj;
    while(obj = [en nextObject]){
        if([tdict objectForKey:obj]==nil){
            [tdict setObject:[[settings namedKeys] objectForKey:obj]
                      forKey:obj];
        }
    }
    
    //NSLog(@"prop list: %d %@",[data length],[data description]);
    //NSLog(@"saving settings, retaincount: %d",[tdict retainCount]);
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:tdict
                                                       forName:CC_PREF_BUNDLE_ID_STR];

    [[NSUserDefaults standardUserDefaults] synchronize];
    [tdict release];
    
}

+ (NSDictionary *) appPrefs
{
    
    NSDictionary *prefs;
    
    prefs = [[NSUserDefaults standardUserDefaults]
      persistentDomainForName:CC_PREF_BUNDLE_ID_STR];
    if(prefs==nil){
        prefs = [CornerClickSupport loadOldVersionPreferences];
    }
    return prefs;
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
        DEBUG(@"deepMCoO: nil");
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

+(NSString *) labelForClickAction: (ClickAction *) clickAction localBundle: (NSBundle *) bundle
{
    return [CornerClickSupport labelForModifiers: [clickAction modifiers]
                                      andTrigger:[clickAction trigger]
                                    triggerDelay:[clickAction hoverTriggerDelayed]
                                     localBundle: bundle];
        
}
+(NSString *) labelForModifiers:(int)modifiers andTrigger:(int) trigger localBundle:(NSBundle *) bundle
{
    return [CornerClickSupport labelForModifiers:modifiers 
                                      andTrigger:trigger
                                    triggerDelay:NO 
                                     localBundle:bundle];
}

+(NSString *) labelForModifiers:(int)modifiers andTrigger:(int) trigger triggerDelay:(BOOL) trigDelay localBundle:(NSBundle *) bundle
{
	NSString *theFile = @"";
	if(modifiers & SHIFT_MASK){
		theFile = [NSString stringWithFormat:@"%C",(unichar)0x21E7];
	}
	if(modifiers & OPTION_MASK){
		if([theFile length]){
			theFile = [NSString stringWithFormat:@"%@%C",theFile,(unichar)0x2325];
		}else{
			theFile = [NSString stringWithFormat:@"%C",(unichar)0x2325];
		}
	}
	
	if(modifiers & COMMAND_MASK){
		if([theFile length]){
			theFile = [NSString stringWithFormat:@"%@%C",theFile,(unichar)0x2318];
		}else{
			theFile = [NSString stringWithFormat:@"%C",(unichar)0x2318];
		}
	}
	
	if(modifiers & CONTROL_MASK){
		if([theFile length]){
			theFile = [NSString stringWithFormat:@"%@%C",theFile,(unichar)0x2303];
		}else{
			theFile = [NSString stringWithFormat:@"%C",(unichar)0x2303];
		}
	}
	if(modifiers & FN_MASK){
		if([theFile length]){
			theFile = [NSString stringWithFormat:@"%@Fn",theFile];
		}else{
			theFile = @"Fn";
		}
	}
	NSString *clickName;
	if(trigger == TRIGGER_CLICK){
		clickName=@"Click";
	}else if(trigger == TRIGGER_RCLCK){
		clickName=@"Right-Click";
    }else if(trigger == TRIGGER_HOVER){
        if(trigDelay){
            clickName=@"Hover 2 secs";
        }else{
            clickName=@"Hover";            
        }

	}else{
		clickName=@"???";
		
	}
	if([theFile length]){
		theFile = [NSString stringWithFormat:@"%@ %@",theFile,LOCALIZE(bundle,clickName)];
	}else{
		theFile = LOCALIZE(bundle,clickName);
	}
	return theFile;
}
+ (NSNumber *) numberForScreen:(NSScreen *)screen
{
	return (NSNumber *)[[screen deviceDescription] objectForKey:@"NSScreenNumber"];
}
+ (int) modifiersForExposeAction: (int) action
{
    NSDictionary *def = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.apple.symbolichotkeys"];
    NSDictionary *keys = (NSDictionary *)[def objectForKey:@"AppleSymbolicHotKeys"];
    NSString* special[4] = {
        @"32",
        @"33",
        @"36",
        @"62" //dashboard action
    };
    if(action < 0 || action > 3 ){
        NSLog(@"ERROR: not a valid expose action to look for: %d",action);
        return -1;
    }
    NSDictionary *settings = (NSDictionary *)[keys objectForKey:special[action]];
    if(nil == settings){
        DEBUG(@"ERROR: settings for special int is nil");        
        //NSLog(@"keys: %@",keys);
        return -1;
    }
    NSNumber *enable = [settings objectForKey:@"enabled"];
    if(nil == enable){
        DEBUG(@"ERROR: number for enabled is nil");
        return -1;
    }
    if([enable boolValue]){
        NSDictionary * val = (NSDictionary *)[settings objectForKey:@"value"];
        if(nil == val){
            DEBUG(@"ERROR: 'value' is nil");
            return -1;
        }
        NSArray *arr = (NSArray *)[val objectForKey:@"parameters"];
        if(nil == arr){
            DEBUG(@"ERROR: 'parameters' is nil");
            return -1;
        }
        
        NSNumber *key =  [arr objectAtIndex:2];
        return [key intValue];
    }else{
        
        return -1;
    }
    
}
+ (int) keyCodeForExposeAction: (int) action
{
    NSDictionary *def = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.apple.symbolichotkeys"];
    NSDictionary *keys = (NSDictionary *)[def objectForKey:@"AppleSymbolicHotKeys"];
    NSString* special[4] = {
        @"32",
        @"33",
        @"36",
        @"62" //dashboard action
    };
    if(action < 0 || action > 3 ){
        NSLog(@"ERROR: not a valid expose action to look for: %d",action);
        return -1;
    }
    NSDictionary *settings = (NSDictionary *)[keys objectForKey:special[action]];
    if(nil == settings){
        DEBUG(@"ERROR: settings for special int is nil");        
        //NSLog(@"keys: %@",keys);
        return -1;
    }
    NSNumber *enable = [settings objectForKey:@"enabled"];
    if(nil == enable){
        DEBUG(@"ERROR: number for enabled is nil");
        return -1;
    }
    if([enable boolValue]){
        NSDictionary * val = (NSDictionary *)[settings objectForKey:@"value"];
        if(nil == val){
            DEBUG(@"ERROR: 'value' is nil");
            return -1;
        }
        NSArray *arr = (NSArray *)[val objectForKey:@"parameters"];
        if(nil == arr){
            DEBUG(@"ERROR: 'parameters' is nil");
            return -1;
        }
        
        NSNumber *key =  [arr objectAtIndex:1];
        return [key intValue];
    }else{
        
        return -1;
    }

}

+ (void) generateKeystrokeForKeyCode: (int) keycode withModifiers: (int) modifiers
{
    CGEventErr err;
    int i;
    if(keycode < 0){
        DEBUG(@"generateKeystrokeForKeyCode < 0");
        NSBeep();
        return;
    }
    /*
     
     CG_EXTERN CGError CGEnableEventStateCombining(boolean_t doCombineState);
     
     CGPostKeyboardEvent( (CGCharCode)0, (CGKeyCode)56, true );
     
     */
    
    //ignore the actual modifiers from the user 
    
    err = CGEnableEventStateCombining(false);
    if(err != 0){
        NSLog(@"error setting CGEnableEventStateCombining(false)");
        return;
    }
    
    //flags masks
    int masks[] = {
        NSShiftKeyMask,
        NSCommandKeyMask,
        NSControlKeyMask,
        NSAlternateKeyMask,
        NSFunctionKeyMask
    };
    //keycode equivalents
    int codes[] = {
        0x38, //shift
        0x37, //command
        0x3b, //control
        0x3a, //option
        0x3f //function
    };
    
    //if the modifier is used, send a keydown for the right key

    for(i=0; i< 5;i++){
        if(modifiers & masks[i]){
  //          NSLog(@"keydown for code: %d",codes[i]);
            err = CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)codes[i],true);
            if(err != 0){
                NSLog(@"error setting CGPostKeyboardEvent");
                return;
            }   
        }
    }
    
    //send keydown for the actual key
//    NSLog(@"keydown for action code: %d",keycode);
    err = CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)keycode,true);
    if(err != 0){
        NSLog(@"error sending CGPostKeyboardEvent");
        return;
    }
    
    //send a keyup for the actual key
    //NSLog(@"keyup for action code: %d",keycode);
    err = CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)keycode,false);
    if(err != 0){
        NSLog(@"error sending CGPostKeyboardEvent");
        return;
    }
    
    //send keyups for the appropriate modifiers again
    for(i=4; i> -1;i--){
        if(modifiers & masks[i]){
            //NSLog(@"keyup for code: %d",codes[i]);
            err = CGPostKeyboardEvent((CGCharCode)0, (CGKeyCode)codes[i],false);
            if(err != 0){
                NSLog(@"error sending CGPostKeyboardEvent");
                return;
            }   
        }
    }
    
    //enable state combining
    err = CGEnableEventStateCombining(true);
    if(err != 0){
        NSLog(@"error setting CGEnableEventStateCombining(true)");
        return;
    }
    
}

+ (NSNumber *)numberFromSomething:(id)obj
{
    if([obj isKindOfClass: [NSString class]]){
        return [NSNumber numberWithInt:[obj intValue]];
    }else if([obj isKindOfClass: [NSNumber class]]){
        return obj;
    }else{
        return nil;
    }
}

@end

static CornerClickSettings* _CCsharedSettings;

@implementation CornerClickSettings

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (_CCsharedSettings == nil) {
            return [super allocWithZone:zone];   
        }   
    }
    return _CCsharedSettings;
}

+ (CornerClickSettings *) sharedSettingsFromUserPreferences
{
    [CornerClickSettings sharedSettingsFromUserPreferencesWithClicker:nil];
}
+ (CornerClickSettings *) sharedSettingsFromUserPreferencesWithClicker: (Clicker *) clicker
{
    @synchronized(self) {
        if (_CCsharedSettings == nil) {
            _CCsharedSettings = [[self alloc] initWithUserPreferences:[CornerClickSupport appPrefs]
                                                            andClicker:clicker] ;
        }else{
            [_CCsharedSettings setUserPreferences:[CornerClickSupport appPrefs]
                                       andClicker:clicker] ;
        }
    }
    return _CCsharedSettings;
}

+ (CornerClickSettings *) sharedSettings
{
    return _CCsharedSettings;
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;   
}
- (id)retain
{
    return self;   
}
- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}
- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (id) init
{
    return [self initWithUserPreferences: nil];
}

- (id) initWithUserPreferences: (NSDictionary *) prefs
{
	return [self initWithUserPreferences: prefs andClicker: nil];
}

- (id) initWithUserPreferences: (NSDictionary *) prefs andClicker: (Clicker *) clicker
{
    if(self = [super init]){
        [self setUserPreferences:prefs andClicker:clicker];
    }
    return self;
}

- (void) setUserPreferences: (NSDictionary *) prefs andClicker: (Clicker *) clicker
{
    
    int num=-1;
    int i,j;
    NSEnumerator *en;
    NSArray *corners;
    NSMutableArray *actions;
    NSDictionary *temp=prefs;
    ClickAction *act;
    id key;

    if(self){
        if(nil == namedKeys){
            namedKeys = [[NSMutableDictionary alloc] init];
        }
        if(temp!=nil) {
            num = [[temp objectForKey:@"appVersion"] intValue];
            if(num < CC_MIN_VERSION || num > CC_MAX_VERSION ){
                NSLog(@"Old version of CornerClick preferences: %d",num);
                NSLog(@"Dumping old preferences: %@",[prefs description]);
                temp= nil;
            }
        }
        if(temp!=nil){
			myClicker=clicker;
            [namedKeys addEntriesFromDictionary:prefs];
                appEnabled = [[CornerClickSupport numberFromSomething:[prefs objectForKey:@"appEnabled"]] boolValue];
            toolTipEnabled = [[CornerClickSupport numberFromSomething:[prefs objectForKey:@"tooltip"]] boolValue];
            toolTipDelayed = [[CornerClickSupport numberFromSomething:[prefs objectForKey:@"tooltipDelayed"]] boolValue];
			if(nil != [prefs objectForKey:@"colorOption"]){
				colorOption = [[CornerClickSupport numberFromSomething:[prefs objectForKey:@"colorOption"]] intValue];
			}else{
				colorOption=0;
			}
            if(nil != [prefs objectForKey:@"textSize"]){
                textSize = [[CornerClickSupport numberFromSomething:[prefs objectForKey:@"textSize"]] floatValue];   
            }else{
                textSize=16.0;
            }
            if(nil != [prefs objectForKey:@"iconSize"]){
                iconSize = [[CornerClickSupport numberFromSomething:[prefs objectForKey:@"iconSize"]] floatValue];
            }else{
                iconSize=32.0;   
            }
            if(nil != [prefs objectForKey:@"hoverDelayTime"]){
                delayTime = [[CornerClickSupport numberFromSomething:[prefs objectForKey:@"hoverDelayTime"]] floatValue];
            }else{
                delayTime=2;   
            }

			NSArray *colors = [prefs objectForKey:@"colors"];
		   if(nil!=colors && [colors count]>0 && nil!=[colors objectAtIndex:0]){
				highlightColor = [(NSColor *)[NSUnarchiver unarchiveObjectWithData:[colors objectAtIndex:0]] retain];				
			}else{
				highlightColor = [[CornerClickSettings defaultHighlightColor] retain];
			}
			/*if(nil!=colors && [colors count]>1 && nil!=[colors objectAtIndex:1]){
				bubbleColorA = [(NSColor *)[NSUnarchiver unarchiveObjectWithData:[colors objectAtIndex:1]] retain];				
			}else{
				bubbleColorA = [[self defaultBubbleColorA] retain];
			}
			if(nil!=colors && [colors count]>2 && nil!=[colors objectAtIndex:2]){
				bubbleColorB = [(NSColor *)[NSUnarchiver unarchiveObjectWithData:[colors objectAtIndex:2]] retain];				
			}else{
				bubbleColorB = [[self defaultBubbleColorB] retain];
			}*/
			theScreens=[CornerClickSupport deepMutableCopyOfObject: [prefs objectForKey:@"screens"]];
            en=[theScreens keyEnumerator];
            while(key = [en nextObject]){
                corners = (NSArray *)[theScreens objectForKey:key];
                for(i=0;i<[corners count];i++){
                    actions = [[corners objectAtIndex: i] objectForKey:@"actionList"];
                    if(actions==nil || [actions count]==0)
                        continue;
                    for(j=0;j<[actions count];j++){
                        act = [CornerClickSettings actionFromDictionary:[actions objectAtIndex:j] withCorner: i andClicker: myClicker];
                        [actions replaceObjectAtIndex:j withObject:act];
                    }
                }
            }
            //NSLog(@"initWithUserPreferences finished: theScreens: %@",theScreens);
           
        }else{
            theScreens = [[NSMutableDictionary alloc] initWithCapacity:2];
            appEnabled=NO;
            toolTipEnabled=YES;
            toolTipDelayed=YES;
			colorOption=0;
			highlightColor = [[CornerClickSettings defaultHighlightColor] retain];
			bubbleColorA = [[CornerClickSettings defaultBubbleColorA] retain];
			bubbleColorB = [[CornerClickSettings defaultBubbleColorB] retain];
            textSize=16.0;
            iconSize=32;
            delayTime=2.0;
        }
        
    }
}

- (NSMutableDictionary *) namedKeys
{
    return [[namedKeys retain] autorelease];
}
- (void) setNamedKeys: (NSMutableDictionary *) keys
{
    [keys retain];
    [namedKeys release];
    namedKeys=keys;
}

+ (NSColor *) defaultHighlightColor
{
	return [NSColor redColor];
}
+ (NSColor *) defaultBubbleColorA
{
	return [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha: 0.6];
}
+ (NSColor *) defaultBubbleColorB
{
	return [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha: 0.4];
}

- (NSArray *) actionsForScreen: (NSNumber *)screenNum andCorner:(int) corner
{
    return [self actionsForScreen:screenNum andCorner:corner andModifiers:-1];
}

- (NSArray *) actionsForScreen: (NSNumber *)screenNum andCorner:(int) corner andModifiers: (int) tmodifiers
{
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
    return [[CornerClickSupport numberFromSomething:[[[self screenArray:screenNum] objectAtIndex: corner]  objectForKey:@"enabled"]] boolValue];
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
- (BOOL) isToolTipEnabled
{
    return toolTipEnabled;
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

- (void) setHighlightColor: (NSColor *)color
{
	NSColor *c = [color copy];
	[highlightColor release];
	highlightColor = c;
}
- (NSColor *) highlightColor
{
	return [[highlightColor retain] autorelease];
}
- (void) setBubbleColorA: (NSColor *)color
{
	
	NSColor *c = [color copy];
	[bubbleColorA release];
	bubbleColorA = c;
}
- (NSColor *) bubbleColorA
{
	return [[bubbleColorA retain] autorelease];
}
- (void) setBubbleColorB: (NSColor *)color
{
	
	[color retain];
	[bubbleColorB release];
	bubbleColorB = color;
}
- (NSColor *) bubbleColorB
{
	return [[bubbleColorB retain] autorelease];
}
- (int) colorOption
{
	return colorOption;
}
- (void) setColorOption: (int) option
{
	colorOption=option;
}
- (void) setIconSize:(float)size
{
    iconSize=size;
}
- (float) iconSize
{
    return iconSize;
}
- (float) textSize
{
    return textSize;
}
- (void) setTextSize:(float)size
{
    textSize=size;
}
- (float) delayTime
{
    return delayTime;
}
- (void) setDelayTime:(float)delay
{
    delayTime=delay;
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
    md  = [[NSMutableDictionary alloc] initWithCapacity:6];
    [md setObject:[NSNumber numberWithInt:[action type]] forKey:@"action"];
    if([ClickAction stringNameForActionType:[action type]] !=nil)
        [md setObject:[action string] forKey:[ClickAction stringNameForActionType:[action type]]];
    if([ClickAction labelNameForActionType:[action type]] !=nil)
        if([action labelSetting]!=nil)
            [md setObject:[action labelSetting] forKey:[ClickAction labelNameForActionType:[action type]]];
    [md setObject:[NSNumber numberWithInt:[action modifiers]] forKey:@"modifiers"];
	[md setObject:[NSNumber numberWithInt:[action trigger]] forKey:@"trigger"];
    if([action trigger]==TRIGGER_HOVER){
        [md setObject:[NSNumber numberWithBool:[action hoverTriggerDelayed]] forKey:@"triggerDelayed"];
    }
	//DEBUG(@"dict from act, name: %@, trigger: %d", [action string], [action trigger]);

    return [md autorelease];
}

+ (ClickAction *) actionFromDictionary:(NSDictionary *) dict withCorner: (int) corner
{
	return [CornerClickSettings actionFromDictionary: dict withCorner: corner andClicker: nil];
}
+ (ClickAction *) actionFromDictionary:(NSDictionary *) dict withCorner: (int) corner andClicker: (Clicker *) clicker
{
    int actionType,modifiers,trigger;
    NSString *action,*label;
    ClickAction *click=nil;
    BOOL trigDelay=NO;
    actionType =[[CornerClickSupport numberFromSomething:[dict objectForKey:@"action"]] intValue];
    action = [dict objectForKey:[ClickAction stringNameForActionType:actionType]];
    label = [dict objectForKey:[ClickAction labelNameForActionType:actionType]];
    modifiers = [[CornerClickSupport numberFromSomething:[dict objectForKey:@"modifiers"]] intValue];
	trigger =0;
	if([dict objectForKey:@"trigger"]!=nil){
		trigger = [[CornerClickSupport numberFromSomething:[dict objectForKey:@"trigger"]] intValue];
	}
    if(trigger == TRIGGER_HOVER){
        if([dict objectForKey:@"triggerDelayed"]!=nil){
            trigDelay = [[CornerClickSupport numberFromSomething:[dict objectForKey:@"triggerDelayed"]] boolValue];            
        }
    }
	//DEBUG(@"load action from dictionary. trigger: %d, object: %@", trigger, [dict objectForKey:@"trigger"]);

    if([ClickAction validActionType: actionType andString: action]){
            click = [[[ClickAction alloc] initWithType:actionType
										  andModifiers:modifiers
											andTrigger:trigger
                                             isDelayed: trigDelay
                                     andString:action
                                     forCorner: corner
                                     withLabel:label
                                    andClicker:clicker]
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
    DEBUG(@"%@<%@:%x>(retain:%d) [",pad,[a class],(unsigned)a,[a retainCount]);
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
    [md setObject: [NSNumber numberWithInt: CC_APP_MIN_VERSION] forKey:@"appVersion"];
    [md setObject: [NSNumber numberWithInt: CC_APP_VERSION] forKey:@"appMajVersion"];
    [md setObject: [NSNumber numberWithBool: appEnabled] forKey:@"appEnabled"];
    [md setObject: [NSNumber numberWithBool: toolTipEnabled] forKey:@"tooltip"];
    [md setObject: [NSNumber numberWithBool: toolTipDelayed] forKey:@"tooltipDelayed"];
	
	[md setObject: [NSNumber numberWithInt: colorOption] forKey:@"colorOption"];
	if(highlightColor != nil){
		[md setObject: [NSArray arrayWithObjects: 
			[NSArchiver archivedDataWithRootObject:highlightColor], 
			//[NSArchiver archivedDataWithRootObject:bubbleColorA], 
			//[NSArchiver archivedDataWithRootObject:bubbleColorB],
			nil] forKey:@"colors"];
	}
    [md setObject: [NSNumber numberWithFloat:textSize] forKey:@"textSize"];
    [md setObject: [NSNumber numberWithFloat:iconSize] forKey:@"iconSize"];
	[sc release];
    
    return md;
}
@end


/*
 
 typedef int CGSConnection;
 typedef int CGSWindow;
 typedef enum {
     CGSTagExposeFade	= 0x0002,   // Fade out when Expose activates.
     CGSTagNoShadow		= 0x0008,   // No window shadow.
     CGSTagTransparent   = 0x0200,   // Transparent to mouse clicks.
     CGSTagSticky		= 0x0800,   // Appears on all workspaces.
 } CGSWindowTag;
 
 
 
@implementation NSWindow (ExposeStickiness)
-(void)setExposeSticky:(BOOL)flag {
    CGSConnection cid;
    CGSWindow wid;
    
    wid = [self windowNumber ];
    cid = _CGSDefaultConnection();
    int tags[2];
    tags[0] = tags[1] = 0;
    OSStatus retVal = CGSGetWindowTags(cid, wid, tags, 32);
    if(!retVal) {
        if (flag)
            tags[0] = tags[0] | CGSTagExposeFade;
        else
            tags[0] = tags[0] & CGSTagExposeFade;
        
        retVal = CGSSetWindowTags(cid, wid, tags, 32);
    }
}


@end
*/