#import "Clicker.h"

@implementation Clicker

- (void) loadFromPreferences: (NSDictionary *) sourcePreferences
{
    NSArray *subPref;
    if(preferences!=nil){
        //NSLog(@"preferences retainCount before release: %d",[preferences retainCount]);
        [preferences release];
    }
    preferences = [[NSMutableDictionary alloc] initWithDictionary: sourcePreferences copyItems:YES];
    // NSLog(@"Loading Preferences: %@",preferences);
    if(preferences){
        int i;
        lastHoverCorner=-1;
        for(i=0;i<4;i++){
            NSString *corn = cornerNames[i];
            subPref = [[preferences objectForKey: corn] objectForKey:@"actionList"];
            if([[[preferences objectForKey:corn] objectForKey:@"enabled"] intValue] == 1
               && subPref!=nil &&
               [self createClickWindowAtCorner: i withActionList: subPref]){
                
            }else if(*windows[i]!=nil){
                //NSLog(@"closing corner %@: ",corn);
                [[*windows[i] contentView] removeTrackingRect: track[i]];
                [*windows[i] close];
                //NSLog(@"*windows[%d] retainCount before release: %d",i,[*windows[i] retainCount]);
                *windows[i]=nil;        
            }
        }
    }else{
        NSLog(@"Unable to copy preferences");
    }
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

- (ClickWindow **) windowForCorner: (int) corner
{
    return windows[corner];
}
- (NSRect) rectForCorner: (int) corner
{
    NSRect myRect;
    NSRect screenRect=[[NSScreen mainScreen] frame];
    switch(corner){
        case 0:
            myRect = NSMakeRect(screenRect.origin.x,screenRect.origin.y+screenRect.size.height-CWSIZE,CWSIZE,CWSIZE);
            break;
        case 1:
            myRect =  NSMakeRect(screenRect.origin.x+screenRect.size.width-CWSIZE,screenRect.origin.y+screenRect.size.height-CWSIZE,CWSIZE,CWSIZE);
            break;
        case 2:
            myRect =  NSMakeRect(screenRect.origin.x,screenRect.origin.y,CWSIZE,CWSIZE);
            break;
        case 3:
            myRect =  NSMakeRect(screenRect.origin.x+screenRect.size.width-CWSIZE,screenRect.origin.y,CWSIZE,CWSIZE);
            break;
        default:
            NSLog(@"Bad corner identifier: %d",corner);
            return;
    }
    return myRect;
}
- (NSPoint) pointForCorner: (int) corner
{
    
    NSRect screenRect=[[NSScreen mainScreen] frame];
    switch(corner){
        case 0:
            return NSMakePoint(screenRect.origin.x,screenRect.origin.y+screenRect.size.height);
            break;
        case 1:
            return NSMakePoint(screenRect.origin.x+screenRect.size.width,screenRect.origin.y+screenRect.size.height);
            break;
        case 2:
            return  NSMakePoint(screenRect.origin.x,screenRect.origin.y);
            break;
        case 3:
            return  NSMakePoint(screenRect.origin.x+screenRect.size.width,screenRect.origin.y);
            break;
        default:
            NSLog(@"Bad corner identifier: %d",corner);
            return;
    }
}
- (BOOL) createClickWindowAtCorner: (int) corner withActionList: (NSArray *) actions
{
    int a,actionType,modifiers;
    NSString *action;
    NSString *label;
    NSDictionary *subPref;
    ClickWindow **theWindow;
    NSRect myRect;
    theWindow = windows[corner];
    myRect = [self rectForCorner:corner];    
    NSMutableArray *clickActions = [NSMutableArray arrayWithCapacity:[actions count]];
    for(a=0;a<[actions count];a++){
        subPref = [actions objectAtIndex:a];
        actionType =[[subPref objectForKey:@"action"] intValue];
        action = [[subPref objectForKey:[self stringNameForActionType:actionType]] retain];
        label = [[subPref objectForKey:[self labelNameForActionType:actionType]] retain];
        modifiers = [[subPref objectForKey:@"modifiers"] intValue];
        if([self validActionType: actionType andString: action]){
            //NSLog(@"loading corner %@: %@",corn,[subPref objectForKey:corn]);
            [clickActions addObject:
                [[[ClickAction alloc] initWithType:actionType
                                      andModifiers:modifiers
                                          andString:action
                                          forCorner: corner
                                          withLabel:label]
                    autorelease]];    
        }
    }
    if([clickActions count]==0){
        return NO;
    }
    if(*theWindow !=nil){
        //NSLog(@"closing corner %d",corner);
        //[[*theWindow contentView] removeTrackingRect: track[corner]];
        //[*theWindow close];
        //*theWindow=nil;
        [[*theWindow contentView] setClickActions: clickActions];
    }else{
        *theWindow = [[ClickWindow alloc] initWithContentRect: myRect
                                                    styleMask: NSBorderlessWindowMask
                                                      backing: NSBackingStoreBuffered
                                                        defer: YES
                                                       corner: corner];
        [*theWindow setOpaque:NO];
        [*theWindow setHasShadow:NO];
        [*theWindow setLevel: NSStatusWindowLevel];
        [*theWindow setAlphaValue: 0.1];


        ClickView *tlView = [[[ClickView alloc]initWithFrame:[*theWindow frame]
                                                      actions:clickActions
                                                      corner:corner] autorelease];
        [*theWindow setContentView: tlView];
        [*theWindow setInitialFirstResponder:tlView];

        BOOL isInside=(NSPointInRect([NSEvent mouseLocation],[*theWindow frame]));
        track[corner] = [[*theWindow contentView] addTrackingRect:[[*theWindow contentView] bounds] owner:self userData:[[NSNumber numberWithInt:corner] retain] assumeInside:isInside];
        [*theWindow orderFront: self];
    }
    
    return YES;
}


- (void) awakeFromNib
{
    tlWin=nil;
    trWin=nil;
    blWin=nil;
    brWin=nil;
    windows[0]=&tlWin;
    windows[1]=&trWin;
    windows[2]=&blWin;
    windows[3]=&brWin;
    cornerNames[0]=@"tl";
    cornerNames[1]=@"tr";
    cornerNames[2]=@"bl";
    cornerNames[3]=@"br";
    lastHoverCorner=-1;
    [self loadFromPreferences:
        [[NSUserDefaults standardUserDefaults]
      persistentDomainForName:@"CornerClickPref"]];

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
    
    [self oneTimeMakeWindow];
}

- (void) pingAppNotification: (NSNotification *) notice
{
    //NSLog(@"app got ping: %@",[notice userInfo]);
    [[NSDistributedNotificationCenter defaultCenter]
postNotificationName: @"CornerClickPingBackNotification"
              object: nil
            userInfo: [NSDictionary dictionaryWithObject: [NSNumber numberWithInt: CB_APP_VERSION] forKey: @"CornerClickAppVersion"]
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

- (void)oneTimeMakeWindow
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
    [self loadFromPreferences: [notice userInfo]];
}

-(void)showHover: (int) corner withModifiers: (unsigned int) modifiers
{
    ClickAction *theAction;
    NSPoint newPoint;
    NSPoint oldPoint=[self pointForCorner: corner];
    if(delayTimer!=nil){
        [delayTimer invalidate];
        [delayTimer release];
        delayTimer=nil;
    }
    if(lastHoverCorner != corner){
        theAction = [[*windows[corner] contentView] clickActionForModifierFlags: modifiers];
        if(theAction !=nil){
            [hoverView setPointCorner: corner];
            [hoverView setDrawString: [theAction label]];
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
    if([theEvent type]==NSFlagsChanged){
        NSLog(@"modifiers changed to: shift %d, ctrl %d, option %d, command %d",[theEvent modifierFlags]&NSShiftKeyMask,
              [theEvent modifierFlags]&NSControlKeyMask,
              [theEvent modifierFlags]&NSAlternateKeyMask,
              [theEvent modifierFlags]&NSCommandKeyMask);

    }
}

- (void)recalcAndShowHoverWindow: (int) corner modifiers: (unsigned int) modifiers
{
    int corn=corner;
    ClickWindow *window;
    if( delayTimer!=nil){
        [delayTimer invalidate];
        [delayTimer release];
        delayTimer=nil;
        [hoverWin setAlphaValue:0.0];
    }
    window =  *windows[corner];
    //NSLog(@"retaincount for window: %d",[window retainCount]);
    if(window !=nil ){
        if([[preferences objectForKey:@"tooltip"] intValue]){
            if([[preferences objectForKey:@"tooltipDelayed"] intValue]){
                NSInvocation *nsinv = [NSInvocation invocationWithMethodSignature: [self methodSignatureForSelector:@selector(showHover:withModifiers:)]];
                [nsinv setSelector:@selector(showHover:withModifiers:)];
                [nsinv setTarget:self];
                [nsinv setArgument: &corn atIndex:2];
                [nsinv setArgument: &modifiers atIndex:3];
                delayTimer = [[NSTimer scheduledTimerWithTimeInterval:1 invocation:nsinv repeats:NO] retain];
            }else{
                [self showHover:corn withModifiers:modifiers];
            }
        }
        if([[window contentView] clickActionForModifierFlags: modifiers]!=nil){
            [window setAlphaValue: 1.0];
            [window orderFront:self];
            //[window makeMainWindow];
        }
    } 
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    NSEvent *newEvent;
    int corn;
    unsigned int modifiers=[theEvent modifierFlags];
    NSNumber *num = (NSNumber *)[theEvent userData];
    corn=[num intValue];
    [self recalcAndShowHoverWindow: corn modifiers: modifiers];
   // NSLog(@" can become main: %d",[*windows[corn] canBecomeKeyWindow]);
    //[*windows[corn] makeKeyAndOrderFront:nil];
    //NSLog(@" key window is %@",[[NSApp keyWindow] description]);
    //NSLog(@" key window is %@",[[NSApp mainWindow] description]);
    return;
    
    while(1){
        newEvent = [NSApp nextEventMatchingMask:
            NSAnyEventMask
            //NSFlagsChangedMask | NSMouseEnteredMask | NSMouseExitedMask | NSLeftMouseDownMask | NSKeyDownMask
                                        untilDate: nil
                                            inMode: NSEventTrackingRunLoopMode //NSDefaultRunLoopMode
                                        dequeue: NO];
        NSLog(@"got event type: %@",[newEvent description]);
        if([newEvent type]&NSFlagsChangedMask || [newEvent type] &NSKeyDownMask){
            [self recalcAndShowHoverWindow: corn modifiers: [newEvent modifierFlags]];
        }else{
            return;
        }
        
    }

    
}


- (void)mouseExited:(NSEvent *)theEvent
{
    ClickWindow *window;
    if([theEvent modifierFlags] & NSControlKeyMask){
        //NSLog(@"With Control Key");
    }
    NSNumber *num = (NSNumber *)[theEvent userData];
    window =  *windows[[num intValue]];
    if(window !=nil){
        [window setAlphaValue: 0.1];
    }else{
        //NSLog(@"no window");
    }
    if([[preferences objectForKey:@"tooltip"] intValue]){
        [self hideHoverFadeOut];
    }
    
}

/*
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"Finished Launching");
    //[[aNotification object] hide: self];
}
- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
    NSLog(@"Became Active");
    //[[aNotification object] hide: self];
}

- (void)applicationDidHide:(NSNotification *)aNotification
{
    NSLog(@"Became Hidden");
    //[[aNotification object] unhideWithoutActivation];
}
*/

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [[NSDistributedNotificationCenter defaultCenter]
    removeObserver: self
               name: @"CornerClickLoadPrefsNotification"
             object: nil];
}

@end
