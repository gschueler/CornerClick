#import "Clicker.h"

@implementation Clicker

- (void) loadFromSettings
{
    id key;
    NSNumber *skey;
    NSArray *acts;
    NSEnumerator *en;
    int i,j;
    NSArray *screens = [NSScreen screens];
    if(allScreens!=nil){
        [allScreens release];
        allScreens=nil;
    }
    allScreens = [[NSMutableDictionary alloc] initWithCapacity:[screens count]];
    if(appSettings !=nil){
        [appSettings release];
        appSettings=nil;
    }
    appSettings = [[CornerClickSupport settingsFromUserPreferences] retain];
    //[CornerClickSupport savePreferences:appSettings];
    //NSLog(@"loaded prefs: %@",appSettings);

    for(j=0;j<[screens count];j++){
        skey =[[[screens objectAtIndex:j] deviceDescription] objectForKey:@"NSScreenNumber"] ;

        [allScreens setObject: [screens objectAtIndex:j] forKey:skey];

        for(i=0;i<MAX_CORNERS;i++){
            acts = [appSettings actionsForScreen: skey andCorner:i];
            if( [appSettings cornerEnabled:i forScreen:skey] &&
                acts!=nil &&
                [acts count]>0 &&
                [self createClickWindowAtCorner: i withActionList: acts onScreen:skey] ){
                if(DEBUG_LEVEL>0)NSLog(@"created window at corner: %d on screen: %@",i,skey);

            }else if([self windowForScreen:skey atCorner:i]!=nil){
                if(DEBUG_LEVEL>0)NSLog(@"NOT created window at corner: %d on screen: %@",i,skey);
                [self setWindow:nil forScreen:skey atCorner:i];
            }
        }
        
    }
    //close windows on any other screens
    en = [screenWindows keyEnumerator];
    while(key = [en nextObject]){
        if([allScreens objectForKey:key]!=nil){
            continue;
        }else{
            if(DEBUG_LEVEL>0)NSLog(@"clearing screen: %@",key);
            [self clearScreen:key];
        }
    }
    
}

- (void) clearScreen: (NSNumber *)screenNum
{
    int i;
    NSMutableArray *corners;
    corners = [screenWindows objectForKey:screenNum];
    if(corners!=nil){
        for(i=0;i<MAX_CORNERS;i++){
            [self setWindow:nil forScreen:screenNum atCorner:i];
        }
        [screenWindows removeObjectForKey:screenNum];
    }
    
}

- (NSMutableArray *) screenEntry:(NSNumber *)screenNum
{
    int i;
    NSMutableArray *corners;
    corners = [screenWindows objectForKey:screenNum];
    if(corners!=nil){
        return corners;
    }else{
        corners = [NSMutableArray arrayWithCapacity:MAX_CORNERS];
        for(i=0;i<MAX_CORNERS;i++){
            [corners addObject:[NSNumber numberWithInt:0]];
        }
        [screenWindows setObject:corners forKey:screenNum];
        return corners;
    }
}

- (ClickWindow *) windowForScreen:(NSNumber *) screenNum atCorner:(int) corner
{
    id obj;
    NSMutableArray *corners = [self screenEntry:screenNum];
    obj=[corners objectAtIndex:corner];
    if([obj isKindOfClass:[ClickWindow class]]){
        return obj;
    }else{
        return nil;
    }
}

- (void) setWindow:(ClickWindow *)window forScreen:(NSNumber *) screenNum atCorner:(int) corner
{
    ClickWindow *cwind;
    NSMutableArray *corners = [self screenEntry:screenNum];
    id obj = [[corners objectAtIndex:corner] retain];
    id rep = (window==nil?(id)[[[NSObject alloc] init] autorelease]:(id)window);
    [corners replaceObjectAtIndex:corner withObject:rep];
    if([obj isKindOfClass:[ClickWindow class]]){
        cwind = (ClickWindow *)obj;
        [[cwind contentView] removeTrackingRect: [[cwind contentView] trackingRectTag]];
        [cwind close];
    }else{
        [obj release];
    }
}


- (NSDictionary *) loadOldVersionPreferences
{
    NSDictionary *loaded=nil;
    //attempt to load the preferences if set from an older version of CornerClick
    int i=CC_APP_VERSION;
    for(i=(CC_APP_VERSION-1);i>=0;i--){
        switch(i){
            case 1: //v0.1
                loaded=[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"CornerClickPref"];
            break;
        }
        if(loaded!=nil)
            return loaded;
    }
        return nil;
}

- (void) changeCorner: (int) corner toAction: (ClickAction *) action
{

}

- (NSString *) stringNameForActionType: (int) type
{
    switch(type){
        case 0: return @"chosenFilePath";
        case 3: return @"chosenURL";
        default: return nil;
    }
}

- (NSString *) labelNameForActionType: (int) type
{
    switch(type){
        case 3: return @"urlDesc";
        default: return nil;
    }
}

- (BOOL) validActionType: (int) type andString: (NSString *) action
{
    switch(type){
        case 0:
            if(action !=nil)
                return YES;
            break;
        case 1: return YES;
        case 2: return YES;
        case 3:
            if(action !=nil && [action length]>0)
                return YES;
            break;
        default:
            return NO;
    }
    return NO;
}

- (NSRect) rectForCorner: (int) corner onScreen:(NSNumber *)screenNum
{
    NSRect myRect;
    NSRect r=[[allScreens objectForKey:screenNum] frame];
    switch(corner){
        case 0:
            myRect = NSMakeRect(NSMinX(r),NSMaxY(r)-CWSIZE,CWSIZE,CWSIZE);
            break;
        case 1:
            myRect =  NSMakeRect(NSMaxX(r)-CWSIZE,NSMaxY(r)-CWSIZE,CWSIZE,CWSIZE);
            break;
        case 2:
            myRect =  NSMakeRect(NSMinX(r),NSMinY(r),CWSIZE,CWSIZE);
            break;
        case 3:
            myRect =  NSMakeRect(NSMaxX(r)-CWSIZE,NSMinY(r),CWSIZE,CWSIZE);
            break;
        default:
            NSLog(@"Bad corner identifier: %d",corner);
            return NSZeroRect;
    }
    return myRect;
}

- (NSPoint) pointForCorner: (int) corner onScreen:(NSNumber *)screenNum
{

    NSRect r=[[allScreens objectForKey:screenNum] frame];
    switch(corner){
        case 0:
            return NSMakePoint(NSMinX(r),NSMaxY(r));
            break;
        case 1:
            return NSMakePoint(NSMaxX(r),NSMaxY(r));
            break;
        case 2:
            return NSMakePoint(NSMinX(r),NSMinY(r));
            break;
        case 3:
            return NSMakePoint(NSMaxX(r),NSMinY(r));
            break;
        default:
            NSLog(@"Bad corner identifier: %d",corner);
            return NSZeroPoint;
    }
}

- (BOOL) createClickWindowAtCorner: (int) corner withActionList: (NSArray *) actions onScreen:(NSNumber *) screenNum
{
    NSTrackingRectTag tag;
    NSRect myRect;
    NSArray *temparr;
    ClickWindow *window = [self windowForScreen:screenNum atCorner:corner] ;
    myRect = [self rectForCorner:corner onScreen:screenNum];
    //NSLog(@"rect for corner: %d, is %@",corner, NSStringFromRect(myRect));
    if([actions count]==0){
        return NO;
    }
    if(window !=nil){
        [[window contentView] setClickActions: actions];
        [window setFrameOrigin:myRect.origin];
    }else{
        window = [[ClickWindow alloc] initWithContentRect: myRect
                                                    styleMask: NSBorderlessWindowMask
                                                      backing: NSBackingStoreBuffered
                                                        defer: YES
                                                       corner: corner];
        [window setOpaque:NO];
        [window setHasShadow:NO];
        [window setLevel: NSScreenSaverWindowLevel];//NSStatusWindowLevel];
        [window setAlphaValue: 0.1];


        ClickView *tlView = [[[ClickView alloc]initWithFrame:[window frame]
                                                      actions:actions
                                                      corner:corner] autorelease];
        [window setContentView: tlView];
        [window setInitialFirstResponder:tlView];
        
        BOOL isInside=(NSPointInRect([NSEvent mouseLocation],[window frame]));
        temparr=[NSArray arrayWithObjects:[NSNumber numberWithInt:corner],screenNum,nil];
        [trackCache setObject:temparr forKey:[NSString stringWithFormat:@"%d:%@",corner,screenNum]];
        tag = [[window contentView] addTrackingRect:[[window contentView] bounds]
                                              owner:self
                                           userData: temparr
                                       assumeInside:isInside];
        [[window contentView] setTrackingRectTag:tag];
        [window orderFront: self];
        [self setWindow: window forScreen:screenNum atCorner:corner];
    }

    return YES;
}


- (void) awakeFromNib
{
    screenWindows = [[NSMutableDictionary dictionaryWithCapacity:2] retain];
    trackCache = [[NSMutableDictionary dictionaryWithCapacity:MAX_CORNERS*[[NSScreen screens] count]] retain];
    lastHoverCorner=-1;
/*    [self loadFromPreferences:
        [[NSUserDefaults standardUserDefaults]
      persistentDomainForName:@"CornerClickPref"]];
*/
    [self loadFromSettings];
    //[NSApp terminate:nil];
    
    NSDistributedNotificationCenter *nc;
    nc = [NSDistributedNotificationCenter defaultCenter];
    [nc addObserver: self
           selector: @selector(prefPaneChangedPreferences:)
            name: @"CornerClickLoadPrefsNotification"
            object: nil
 suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
    [nc addObserver: self
           selector: @selector(appDisabledByPreferences:)
               name:@"CornerClickDisableAppNotification"
             object:nil
 suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];

    [nc addObserver: self
           selector: @selector(pingAppNotification:)
               name: @"CornerClickPingAppNotification"
             object: nil
 suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
    [[NSNotificationCenter defaultCenter]
        addObserver: self
           selector: @selector(screenChangedNotification:)
               name: @"NSApplicationDidChangeScreenParametersNotification"
             object: nil];

    [self makeHoverWindow];
}

- (void) pingAppNotification: (NSNotification *) notice
{
    //NSLog(@"app got ping: %@",[notice userInfo]);
    [[NSDistributedNotificationCenter defaultCenter]
postNotificationName: @"CornerClickPingBackNotification"
              object: nil
            userInfo: [NSDictionary dictionaryWithObject: [NSNumber numberWithInt: CC_APP_VERSION] forKey: @"CornerClickAppVersion"]
  deliverImmediately: YES
        ];
}

- (void) appDisabledByPreferences: (NSNotification *)notice
{
    //NSLog(@"told to disable");
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName: @"CornerClickDisableAppReplyNotification"
                                                                   object: nil
                                                                 userInfo: nil
                                                       deliverImmediately: YES
        ];
    [NSApp terminate:nil];
}

- (void)screenChangedNotification:(NSNotification *)notice
{
    //move clickwindows
    //DEBUG(@"got screen changed");
    [self loadFromSettings];
}

- (void)makeHoverWindow
{
    NSRect sr = [[NSScreen mainScreen] frame];
    NSRect myr = NSMakeRect(sr.origin.x+(sr.size.width/2)-80,sr.origin.y+(sr.size.height/2)-40,
                            160,80);

    

    hoverView = [[GrayView alloc] initWithFrame:myr andString: @"Test window"] ;
    NSRect prefFrame = [hoverView preferredFrame];
    [hoverView setFrame:prefFrame];
    
    hoverWin = [[NSWindow alloc] initWithContentRect:prefFrame styleMask:NSBorderlessWindowMask backing:
                               NSBackingStoreBuffered defer:YES ];
    [hoverWin setLevel:NSStatusWindowLevel];
    [hoverWin setAlphaValue:1.0];
    [hoverWin setHasShadow: NO];
    [hoverWin setOpaque:NO];
    
    [hoverWin setContentView: hoverView];
    
    //[hoverWin orderFront: self];
}

- (void)prefPaneChangedPreferences:(NSNotification *)notice
{
    //NSLog(@"got preferences changed notification, reloading");
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self loadFromSettings];
}

-(void)showHover: (int) corner onScreen:(NSNumber *)screenNum withModifiers: (unsigned int) modifiers
{
    ClickAction *theAction;
    ClickWindow *window = [self windowForScreen:screenNum atCorner:corner];

    NSPoint newPoint;
    NSPoint oldPoint=[self pointForCorner: corner onScreen:screenNum];
    if(delayTimer!=nil){
        [delayTimer invalidate];
        [delayTimer release];
        delayTimer=nil;
    }
    if(lastHoverCorner != corner){
        theAction = [[window contentView] clickActionForModifierFlags: modifiers];
        if(theAction !=nil){
            [hoverView setPointCorner: corner];
            [hoverView setDrawString: [theAction label]];
            //DEBUG(@"right after setDrawString");
            [hoverView setIcon: [theAction icon]];
        
            switch(corner){
                case 0:
                    newPoint = NSMakePoint(oldPoint.x+HWSIZE,oldPoint.y-HWSIZE-[hoverWin frame].size.height);
                    break;
                case 1:
                    newPoint = NSMakePoint(oldPoint.x-HWSIZE-[hoverWin frame].size.width,oldPoint.y-HWSIZE-[hoverWin frame].size.height);
                    break;
                case 2:
                    newPoint = NSMakePoint(oldPoint.x+HWSIZE,oldPoint.y+HWSIZE);
                    break;
                case 3:
                    newPoint = NSMakePoint(oldPoint.x-HWSIZE-[hoverWin frame].size.width,oldPoint.y+HWSIZE);
                    break;
                default:
                    return;
        
            }
            [hoverWin setFrameOrigin: newPoint];

            lastHoverCorner=-1;
            [hoverWin setAlphaValue: 1.0];

            [hoverWin orderBack:self];
            //DEBUG(@"right after show hover");
        }else{
            lastHoverCorner=-1;
        }
    }
}

-(void) hideHoverDoFadeout
{
    [hoverWin setAlphaValue: [hoverWin alphaValue]-0.1];
    if([hoverWin alphaValue]<=0.0){
        [delayTimer invalidate];
        [delayTimer release];
        delayTimer=nil;
        //NSLog(@"Faded out");
    }
}
-(void) hideHoverFadeOut
{
    if( delayTimer!=nil){
        [delayTimer invalidate];
        [delayTimer release];
        delayTimer=nil;
    }
    NSInvocation *nsinv = [NSInvocation invocationWithMethodSignature: [self methodSignatureForSelector:@selector(hideHoverDoFadeout)]];
    [nsinv setSelector:@selector(hideHoverDoFadeout)];
    [nsinv setTarget:self];

    delayTimer = [[NSTimer scheduledTimerWithTimeInterval:0.05 invocation:nsinv repeats:YES] retain];

}


- (void) keyDown: (NSEvent *)theEvent
{
    if([theEvent type]&NSFlagsChanged){
        NSLog(@"modifiers changed to: shift %d, ctrl %d, option %d, command %d",[theEvent modifierFlags]&NSShiftKeyMask,
              [theEvent modifierFlags]&NSControlKeyMask,
              [theEvent modifierFlags]&NSAlternateKeyMask,
              [theEvent modifierFlags]&NSCommandKeyMask);

    }
}
- (void)recalcAndShowHoverWindow: (int) corner onScreen:(NSNumber *)screenNum modifiers: (unsigned int) modifiers
{
    [self recalcAndShowHoverWindow:corner onScreen:screenNum modifiers:modifiers doDelay:YES];
}
- (void)recalcAndShowHoverWindow: (int) corner onScreen:(NSNumber *)screenNum modifiers: (unsigned int) modifiers
                         doDelay: (BOOL) delay
{
    int corn=corner;
    ClickWindow *window;
    if( delayTimer!=nil){
        [delayTimer invalidate];
        [delayTimer release];
        delayTimer=nil;
        [hoverWin setAlphaValue:0.0];
    }
    if([hoverWin alphaValue] > 0.0){
        //[hoverWin setAlphaValue:0.0];
    }
    window =  [self windowForScreen:screenNum atCorner:corner];
    //NSLog(@"retaincount for window: %d",[window retainCount]);
    if(window !=nil ){
        if([[window contentView] clickActionForModifierFlags: modifiers]!=nil){
            [window setAlphaValue: 1.0];
            [window orderFront:self];
            //[window makeMainWindow];
            
            if([appSettings toolTipEnabled]){
                if([appSettings toolTipDelayed] && delay){
                    NSInvocation *nsinv = [NSInvocation invocationWithMethodSignature: [self methodSignatureForSelector:@selector(showHover:onScreen:withModifiers:)]];
                    [nsinv setSelector:@selector(showHover:onScreen:withModifiers:)];
                    [nsinv setTarget:self];
                    [nsinv setArgument: &corn atIndex:2];
                    [nsinv setArgument: &screenNum atIndex:3];
                    [nsinv setArgument: &modifiers atIndex:4];
                    delayTimer = [[NSTimer scheduledTimerWithTimeInterval:1 invocation:nsinv repeats:NO] retain];
                }else{
                    [self showHover:corn onScreen: screenNum withModifiers:modifiers];
                }
            }
        }else{
            [window setAlphaValue: 0.1];
            [hoverWin setAlphaValue: 0.0];
        }
    }
}

- (void)mouseEntered:(NSEvent *)theEvent
{

    unsigned int modifiers=[theEvent modifierFlags];
    NSArray *t = (NSArray *)[theEvent userData];
    int corn=[[t objectAtIndex:0] intValue];
    NSNumber *screenNum=[t objectAtIndex:1];

    lastCornerEntered=corn;
    [self recalcAndShowHoverWindow: corn onScreen:screenNum modifiers: modifiers];
}

- (void) flagsChanged:(NSEvent *)theEvent
{
    DEBUG(@"Clicker: flagsChanged");
//    if(lastCornerEntered!=-1)        [self recalcAndShowHoverWindow: lastCornerEntered modifiers: [theEvent modifierFlags] doDelay:NO];
}
- (void)applicationDidHide:(NSNotification *)aNotification
{
    [[aNotification object] unhideWithoutActivation];
}
- (void) mouseDown:(NSEvent *)theEvent
{
    DEBUG(@"mouseDown in clicker.m");
}

- (void)mouseExited:(NSEvent *)theEvent
{
    ClickWindow *window;
    int corn = [[(NSArray *)[theEvent userData] objectAtIndex:0] intValue];
    NSNumber *num = (NSNumber *)[(NSArray *)[theEvent userData] objectAtIndex:1];
    window =  [self windowForScreen:num atCorner:corn];
    [window setAlphaValue: 0.1];
    if([appSettings toolTipEnabled]){
        [self hideHoverFadeOut];
    }
    lastCornerEntered=-1;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [[NSDistributedNotificationCenter defaultCenter]
    removeObserver: self
               name: @"CornerClickLoadPrefsNotification"
            object: nil];
    [[NSDistributedNotificationCenter defaultCenter]
        removeObserver: self
                  name: @"CornerClickDisableAppNotification"
                object: nil];
    [[NSDistributedNotificationCenter defaultCenter]
        removeObserver: self
                  name: @"CornerClickPingAppNotification"
                object: nil];
}

@end
