#import "Clicker.h"

@implementation Clicker

- (void) loadFromPreferences: (NSDictionary *) sourcePreferences
{
    NSString *label,*action;
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
            //NSLog(@"hover[%d] retainCount before release: %d",i,[hover[i] retainCount]);
            [hover[i] release];
            hover[i]=nil;

            //NSLog(@"icons[%d] retainCount before release: %d",i,[icons[i] retainCount]);
            [icons[i] release];
            icons[i]=nil;
            if([[[preferences objectForKey:corn] objectForKey:@"enabled"] intValue] == 1){

                int actionType =[[[preferences objectForKey: corn] objectForKey:@"action"] intValue];
                action = [[[preferences objectForKey:corn] objectForKey:[self stringNameForActionType:actionType]] retain];
                label = [[[preferences objectForKey:corn] objectForKey:[self labelNameForActionType:actionType]] retain];
                if([self validActionType: actionType andString: action]){
                    //NSLog(@"loading corner %@: %@",corn,[preferences objectForKey:corn]);
                    [self createClickWindowAtCorner: i withActionType:actionType andString: action
                                          withLabel: label];

                }else if(*windows[i]!=nil){
                    //NSLog(@"closing corner %@: ",corn);
                    [[*windows[i] contentView] removeTrackingRect: track[i]];
                    [*windows[i] close];

                    //NSLog(@"*windows[%d] retainCount before release: %d",i,[*windows[i] retainCount]);

                    *windows[i]=nil;
                }
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

- (void) createClickWindowAtCorner: (int) corner withActionType: (int) type andString: (NSString *)filePath withLabel:(NSString *) label
{
    ClickAction *act;
    ClickWindow **theWindow;
    NSRect myRect;
    theWindow = windows[corner];
    myRect = [self rectForCorner:corner];

    act = [[[ClickAction alloc] initWithType:type andString:filePath forCorner: corner withLabel:label] autorelease];
    if(*theWindow !=nil){
        //NSLog(@"closing corner %d",corner);
        //[[*theWindow contentView] removeTrackingRect: track[corner]];
        //[*theWindow close];
        //*theWindow=nil;
        [[*theWindow contentView] setClickAction: act];
    }else{
        *theWindow = [[ClickWindow alloc] initWithContentRect: myRect
                                                    styleMask: NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES corner:corner];
        [*theWindow setOpaque:NO];
        [*theWindow setHasShadow:NO];
        [*theWindow setLevel: NSStatusWindowLevel];
        [*theWindow setAlphaValue: 0.1];
    
    
        ClickView *tlView = [[[ClickView alloc] initWithFrame:[*theWindow frame] action:act  corner:corner] autorelease];
        [*theWindow setContentView: tlView];
    
        BOOL isInside=(NSPointInRect([NSEvent mouseLocation],[*theWindow frame]));
        track[corner] = [[*theWindow contentView] addTrackingRect:[[*theWindow contentView] bounds] owner:self userData:[[NSNumber numberWithInt:corner] retain] assumeInside:isInside];
        [*theWindow orderFront: self];
    }
    
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
    NSLog(@"got preferences changed notification, reloading");
    [self loadFromPreferences: [notice userInfo]];
}

-(void)showHover: (int) corner
{
    NSPoint newPoint;
    NSPoint oldPoint=[self pointForCorner: corner];
    if(delayTimer!=nil){
        [delayTimer invalidate];
        delayTimer=nil;
    }
    if(lastHoverCorner != corner){
        [hoverView setPointCorner: corner];
        [hoverView setDrawString: [[[*windows[corner] contentView] clickAction] label]];
        [hoverView setIcon: [[[*windows[corner] contentView] clickAction] icon]];
    
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

        lastHoverCorner=corner;
    }
    [hoverWin setAlphaValue: 1.0];
    [hoverWin orderBack:self];
}



- (void)mouseEntered:(NSEvent *)theEvent
{
    ClickWindow *window;
    int corn;
    if([theEvent modifierFlags] & NSControlKeyMask){
        NSLog(@"With Control Key");
    }
    NSNumber *num = (NSNumber *)[theEvent userData];
    corn=[num intValue];
    window =  *windows[[num intValue]];
    //NSLog(@"retaincount for window: %d",[window retainCount]);
    if(window !=nil ){
        if([[preferences objectForKey:@"tooltip"] intValue]){
            if([[preferences objectForKey:@"tooltipDelayed"] intValue]){
                NSInvocation *nsinv = [NSInvocation invocationWithMethodSignature: [self methodSignatureForSelector:@selector(showHover:)]];
                [nsinv setSelector:@selector(showHover:)];
                [nsinv setTarget:self];
                [nsinv setArgument: &corn atIndex:2];
                delayTimer = [[NSTimer scheduledTimerWithTimeInterval:1 invocation:nsinv repeats:NO] retain];
            }else{
                [self showHover:corn];
            }
        }

        [window setAlphaValue: 1.0];
        [window orderFront:self];
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
        NSLog(@"no window");
    }
    if([[preferences objectForKey:@"tooltip"] intValue]){
        if([[preferences objectForKey:@"tooltipDelayed"] intValue] && delayTimer!=nil){
            [delayTimer invalidate];
            delayTimer=nil;
        }
        [hoverWin setAlphaValue: 0.0];
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
