#import "Clicker.h"

extern double CornerClickBGVersionNumber;
int selectedMod=-1;
@interface Clicker (InternalMethods)
- (void) actionActivating: (ClickAction *)theAction;
- (void) doSelectedAction;

@end

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
    appSettings = [CornerClickSettings sharedSettingsFromUserPreferencesWithClicker:self];

    for(j=0;j<[screens count];j++){
        skey =[[[screens objectAtIndex:j] deviceDescription] objectForKey:@"NSScreenNumber"] ;

        [allScreens setObject: [screens objectAtIndex:j] forKey:skey];

        for(i=0;i<MAX_CORNERS;i++){
            acts = [appSettings actionsForScreen: skey andCorner:i];
            if( [appSettings cornerEnabled:i forScreen:skey] &&
                acts!=nil &&
                [acts count]>0 &&
                [self createClickWindowAtCorner: i withActionList: acts onScreen:skey] ){
                DEBUG(@"created window at corner: %d on screen: %@",i,skey);

            }else if([self windowForScreen:skey atCorner:i]!=nil){
                DEBUG(@"NOT created window at corner: %d on screen: %@",i,skey);
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
            DEBUG(@"clearing screen: %@",key);
            [self clearScreen:key];
        }
    }
    [hoverView recalcSize];
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
- (void) reloadScreens
{
    int j;
    NSNumber *skey;
    NSArray *screens =[NSScreen screens];
    for(j=0;j<[screens count];j++){
        skey =[[[screens objectAtIndex:j] deviceDescription] objectForKey:@"NSScreenNumber"] ;
        
        [allScreens setObject: [screens objectAtIndex:j] forKey:skey];
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
    int i=CornerClickBGVersionNumber;
    for(i=(CornerClickBGVersionNumber-1);i>=0;i--){
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

- (NSPoint) origPointForCorner: (int) corner onScreen:(NSNumber *)screenNum
{
    NSRect r=[[allScreens objectForKey:screenNum] frame];
    switch(corner){
        case 0:
            return NSMakePoint(NSMinX(r)-CWSIZE,NSMaxY(r)-CWSIZE);
            break;
        case 1:
            return  NSMakePoint(NSMaxX(r)-CWSIZE,NSMaxY(r)-CWSIZE);
            break;
        case 2:
            return NSMakePoint(NSMinX(r)-CWSIZE,NSMinY(r)-CWSIZE);
            break;
        case 3:
            return  NSMakePoint(NSMaxX(r)-CWSIZE,NSMinY(r)-CWSIZE);
            break;
        default:
            NSLog(@"Bad corner identifier: %d",corner);
            return NSZeroPoint;
    }
}
- (NSPoint) newPointForCorner: (int) corner onScreen:(NSNumber *)screenNum
{
    NSRect r=[[allScreens objectForKey:screenNum] frame];
    switch(corner){
        case 0:
            return NSMakePoint(NSMinX(r),NSMaxY(r)-CWSIZE*2);
            break;
        case 1:
            return  NSMakePoint(NSMaxX(r)-CWSIZE*2,NSMaxY(r)-CWSIZE*2);
            break;
        case 2:
            return NSMakePoint(NSMinX(r),NSMinY(r));
            break;
        case 3:
            return  NSMakePoint(NSMaxX(r)-CWSIZE*2,NSMinY(r));
            break;
        default:
            NSLog(@"Bad corner identifier: %d",corner);
            return NSZeroPoint;
    }
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
		//NSLog(@"createClickWindowAtCorner: not re-creating");
        [[window contentView] setClickActions: actions];
        [window setFrameOrigin:myRect.origin];
		[[window contentView] needsDisplay];
		[window display];
    }else{
		//NSLog(@"createClickWindowAtCorner: re-creating clickwindow");
        window = [[ClickWindow alloc] initWithContentRect: myRect
                                                    styleMask: NSBorderlessWindowMask|NSNonactivatingPanelMask
                                                      backing: NSBackingStoreBuffered
                                                        defer: YES
                                                       corner: corner];
        [window setOpaque:NO];
        [window setHasShadow:NO];
        [window setLevel: NSStatusWindowLevel];
        [window setAlphaValue: 0.1];


        ClickView *tlView = [[[ClickView alloc]initWithFrame:[window frame]
                                                      actions:actions
                                                      corner:corner
                                                     clicker:self] autorelease];
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
    isShowingHover=NO;
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
            userInfo: [NSDictionary dictionaryWithObjects:
                [NSArray arrayWithObjects: [NSNumber numberWithInt: CornerClickBGVersionNumber], [NSNumber numberWithInt: CC_PATCH_VERSION], nil]
                                                  forKeys:
                [NSArray arrayWithObjects: @"CornerClickAppVersion", @"CornerClickPatchVersion",nil]]
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


    hoverView = [[BubbleView alloc] initWithFrame:myr andDrawingObject:nil] ;
    NSRect prefFrame = [hoverView preferredFrame];
    [hoverView setFrame:prefFrame];
    
    hoverWin = [[NSPanel alloc] initWithContentRect:prefFrame
                                                 styleMask:NSBorderlessWindowMask|NSNonactivatingPanelMask
                                                   backing:NSBackingStoreBuffered
                                                     defer:YES ];
    [hoverWin setLevel:NSStatusWindowLevel];
    [hoverWin setAlphaValue:1.0];
    [hoverWin setHasShadow: NO];
    [hoverWin setOpaque:NO];
    //[hoverWin setSticky:YES];
    
    //[hoverWin setExposeSticky:YES];
    
    [hoverWin setContentView: hoverView];
    
    //[hoverWin orderFront: self];
}

- (void)prefPaneChangedPreferences:(NSNotification *)notice
{
    //NSLog(@"got preferences changed notification, reloading");
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self loadFromSettings];
}

- (NSColor *)highlightColor
{
	return [appSettings highlightColor];
}

- (NSColor *)determineHighlightColor
{
	switch([appSettings colorOption]){
		case 1:
			return nil;
		case 2:
			return [appSettings highlightColor];
		case 0:
		default:
			return [NSColor blackColor];
	}
}

-(void)showHover: (int) corner onScreen:(NSNumber *)screenNum withModifiers: (unsigned int) modifiers
{
	[self showHover:corner onScreen:screenNum withModifiers:modifiers andTitle:NO withActionsList:nil];
}

-(void)showHover: (int) corner onScreen:(NSNumber *)screenNum withModifiers: (unsigned int) modifiers
		andTitle:(BOOL)showTitle
 withActionsList:  (BubbleActionsList *) actionsList

{
    int i;
	NSArray *thearr;
	BubbleActionsList *actsList;
    ClickWindow *window = [self windowForScreen:screenNum atCorner:corner];
    [self reloadScreens];
	actsList=actionsList;
    NSPoint newPoint;
    NSPoint oldPoint=[self pointForCorner: corner onScreen:screenNum];
    //NSLog(@"showHover at point: %@", NSStringFromPoint(oldPoint) );
    @synchronized(hoverView){
            
        if(delayTimer!=nil){
            [delayTimer invalidate];
            [delayTimer release];
            delayTimer=nil;
            //[hoverWin setAlphaValue:0.0];
        }
        if(fadeTimer!=nil){
            [fadeTimer invalidate];
            [fadeTimer release];
            fadeTimer=nil;
            
            //[hoverWin setAlphaValue:0.0];
        }
        if(lastHoverCorner != corner){
            //theAction = [[window contentView] clickActionForModifierFlags: modifiers];
            if(actsList==nil && isShowingHover){
                return;
            }
            if(actsList==nil){
                thearr = [[window contentView] actionsGroupsForModifiers: [Clicker modsForEventFlags: modifiers]];	
                NSMutableArray *ma = [[[NSMutableArray alloc] init] autorelease];
                for(i=0;i<[thearr count];i++){
                    NSArray *acts = (NSArray *)[thearr objectAtIndex:i];
                    [ma addObject:[hoverView bubbleAction:acts]];
                }
                actsList = [hoverView bubbleActionsList: ma
                                              forCorner: corner
                                               selected:-1
                                      andHighlightColor:  [self determineHighlightColor]];
                [actsList setShowAllModifiers:YES];
                DEBUG(@"actsList retainCount after factory create: %d",[actsList retainCount]);
            }else{
                
                isShowingHover=YES;
            }
            if(actsList !=nil){
                NSRect or = [hoverView preferredFrame];
                [hoverView setPointCorner: corner];
                //[hoverView setShowModifiersTitle: showTitle];
                [hoverView setDrawingObject:actsList];
                //[hoverView setFadeFromColor:nil];
                //[hoverView setFadeToColor:nil];
                NSRect r = [hoverView preferredFrame];
                switch(corner){
                    case 0:
                        newPoint = NSMakePoint(oldPoint.x+HWSIZE,oldPoint.y-HWSIZE-r.size.height);
                        break;
                    case 1:
                        newPoint = NSMakePoint(oldPoint.x-HWSIZE-r.size.width,oldPoint.y-HWSIZE-r.size.height);
                        break;
                    case 2:
                        newPoint = NSMakePoint(oldPoint.x+HWSIZE,oldPoint.y+HWSIZE);
                        break;
                    case 3:
                        newPoint = NSMakePoint(oldPoint.x-HWSIZE-r.size.width,oldPoint.y+HWSIZE);
                        break;
                    default:
                        return;
            
                }
                if(!NSEqualRects(or,r)){
                    DEBUG(@"hoverView was resized");
                    [hoverView setFrame:r];
                    [hoverView setNeedsDisplay:YES];
                }
                    
                [hoverWin setFrame: NSMakeRect(newPoint.x, newPoint.y, r.size.width, r.size.height) display: YES];
                
                [hoverWin orderWindow:NSWindowBelow relativeTo:[window windowNumber]];
                lastHoverCorner=-1;
                if([hoverWin alphaValue] < 1.0)
                    [hoverWin setAlphaValue: 1.0];
                if(![hoverWin isVisible]){
                    //[hoverWin orderBack:self];
                    //DEBUG(@"HOVER ORDER BACK");
                }
                    

            }else{
                lastHoverCorner=-1;
            }
        }
    }
}

-(void) hideHoverDoFadeout
{
    [hoverWin setAlphaValue: [hoverWin alphaValue]-0.1];
    if([hoverWin alphaValue]<=0.0){
        [fadeTimer invalidate];
        [fadeTimer release];
        fadeTimer=nil;
        DEBUG(@"HOVER DID FADE");
    }
}
-(void) hideHoverFadeOut
{
    if( delayTimer!=nil){
        [delayTimer invalidate];
        [delayTimer release];
        delayTimer=nil;
    }
    if( fadeTimer!=nil){
        [fadeTimer invalidate];
        [fadeTimer release];
        fadeTimer=nil;
    }
    NSInvocation *nsinv = [NSInvocation invocationWithMethodSignature: [self methodSignatureForSelector:@selector(hideHoverDoFadeout)]];
    [nsinv setSelector:@selector(hideHoverDoFadeout)];
    [nsinv setTarget:self];
    
    DEBUG(@"HOVER DO FADE");
    fadeTimer = [[NSTimer scheduledTimerWithTimeInterval:0.05 invocation:nsinv repeats:YES] retain];

}


- (void) keyDown: (NSEvent *)theEvent
{
	switch([theEvent keyCode]){
		case NSUpArrowFunctionKey:
		case 126:
			[self scroll:-1 atCorner:lastCornerEntered modifiers:[theEvent modifierFlags]];
			break;
		case NSDownArrowFunctionKey:
		case 125:
			[self scroll:1 atCorner:lastCornerEntered modifiers:[theEvent modifierFlags]];
			break;
		case 48://tab
			[self scroll:([theEvent modifierFlags]&NSShiftKeyMask ?-1 : 1) atCorner:lastCornerEntered modifiers:[theEvent modifierFlags]];
			break;
		case 53://escape
			[self fadeOutCorner:lastCornerEntered onScreen:lastScreen];
			break;
		case 49://space
		case 36://return
		case 76://enter
			[self doSelectedAction];
			break;
		default:
			DEBUG(@"key code seen is %d",[theEvent keyCode]);
	}
}

- (void) doSelectedAction
{
	if(selectedMod < 0 )
		return;
	else{
		NSWindow *window = [self windowForScreen:lastScreen atCorner:lastCornerEntered];
		ClickView *view = (ClickView *)[window contentView];
		NSArray *mods = [view actionsGroups];
		NSArray *acts = (NSArray *)[mods objectAtIndex:selectedMod];
		ClickAction *act = (ClickAction *)[acts objectAtIndex:0];
		[self doAction:lastCornerEntered 
			  onScreen:lastScreen
			 withFlags: [act modifiers]
			forTrigger:[act trigger]];
		
	}
	
}

- (void)recalcAndShowHoverWindow: (int) corner onScreen:(NSNumber *)screenNum modifiers: (unsigned int) modifiers
{
    [self recalcAndShowHoverWindow:corner onScreen:screenNum modifiers:modifiers doDelay:YES actionList: nil];
}
- (void)recalcAndShowHoverWindow: (int) corner onScreen:(NSNumber *)screenNum modifiers: (unsigned int) modifiers
                         doDelay: (BOOL) delay
					  actionList: (BubbleActionsList *)actionsList
{
    int corn=corner;
    ClickWindow *window;
	BOOL isInside=NO;
	BOOL title=NO;//<-------
    if( delayTimer!=nil){
        [delayTimer invalidate];
        [delayTimer release];
        delayTimer=nil;
        //[hoverWin setAlphaValue:0.0];
    }
    if( fadeTimer!=nil){
        [fadeTimer invalidate];
        [fadeTimer release];
        fadeTimer=nil;
		if(delay)
			[hoverWin setAlphaValue:0.0];
    }
    if([hoverWin alphaValue] > 0.0){
        //[hoverWin setAlphaValue:0.0];
    }
    window =  [self windowForScreen:screenNum atCorner:corner];
	isInside=-1;
    //NSLog(@"retaincount for window: %d",[window retainCount]);
    if(window !=nil ){
		//[window makeMainWindow];
		
        if(actionsList!=nil || [[window contentView] clickActionForModifierFlags: modifiers]!=nil){
            [window setAlphaValue: 1.0];
//            NSPoint np = [self newPointForCorner:corn onScreen:screenNum];
  //          NSRect fr = [window frame];
    //        [window setFrame:NSMakeRect(np.x,np.y, fr.size.width, fr.size.height) display:YES];

			
            if([appSettings toolTipEnabled]){
                if([appSettings toolTipDelayed] && delay){
                    NSInvocation *nsinv = [NSInvocation invocationWithMethodSignature: [self methodSignatureForSelector:@selector(showHover:onScreen:withModifiers:andTitle:withActionsList:)]];
                    [nsinv setSelector:@selector(showHover:onScreen:withModifiers:andTitle:withActionsList:)];
                    [nsinv setTarget:self];
                    [nsinv setArgument: &corn atIndex:2];
                    [nsinv setArgument: &screenNum atIndex:3];
                    [nsinv setArgument: &modifiers atIndex:4];
					[nsinv setArgument: &title atIndex:5];
					[nsinv setArgument: &actionsList atIndex:6];
                    delayTimer = [[NSTimer scheduledTimerWithTimeInterval:1 invocation:nsinv repeats:NO] retain];
                }else{
					[self showHover:corn
						   onScreen: screenNum
					  withModifiers: modifiers
						   andTitle: NO
					withActionsList: actionsList];
                    //[self showHover:corn onScreen: screenNum withModifiers:modifiers];
                }
				
            }
				
            
            [window makeKeyAndOrderFront:self];
            DEBUG(@"MAKE KEY AND ORDER FRONT.  IS KEY: %@, ACTIVE: %@",[NSApp keyWindow]==window ? @"YES":@"NO",
                  [NSApp isActive]?@"YES":@"NO");
        }else{
            [window setAlphaValue: 0.2];
            [window setFrame:[self rectForCorner:corn onScreen:screenNum] display:YES];
            [hoverWin setAlphaValue: 0.0];
            isShowingHover=NO;
            [window makeKeyAndOrderFront:nil];
        }
    }
}

- (void)closeOtherWindows: (int)corner onScreen:(NSNumber *)screenNum
{
    id obj;
    int i;
    NSEnumerator *en = [screenWindows keyEnumerator];
    while((obj = [en nextObject])!=nil){
        NSNumber *key = (NSNumber *)obj;
        NSArray *ar = (NSArray *)[screenWindows objectForKey:key];
        for(i=0;i<[ar count];i++){
            if(![screenNum isEqualTo:key] || i!=corner){
                id win = [ar objectAtIndex:i];
                if([win isMemberOfClass:[ClickWindow class]])
                [(ClickWindow *)win close];
            }
            
        }
    }
}

- (void)showOtherWindows: (int)corner onScreen:(NSNumber *)screenNum
{
    id obj;
    int i;
    NSEnumerator *en = [screenWindows keyEnumerator];
    while((obj = [en nextObject])!=nil){
        NSNumber *key = (NSNumber *)obj;
        NSArray *ar = (NSArray *)[screenWindows objectForKey:key];
        for(i=0;i<[ar count];i++){
            if(![screenNum isEqualTo:key] || i!=corner){
                id win = [ar objectAtIndex:i];
                if([win isMemberOfClass:[ClickWindow class]])
                [(ClickWindow *)win orderBack:self];
            }
            
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
	lastScreen = screenNum;
	actionPerformed=NO;
    isShowingHover=NO;
    [hoverView setDrawingObject:nil];
    DEBUG(@"MOUSE ENTER");
    [self closeOtherWindows: corn onScreen:screenNum];
    [self recalcAndShowHoverWindow: corn onScreen:screenNum modifiers: modifiers];
}

- (ProcessSerialNumber) lastActivePSN
{
	return lastActiveProc;
}

- (void) getNextPSN
{
	ProcessSerialNumber mePsn;
	BOOL areSame;
	OSErr err;
	NSString *procName;
	err = GetCurrentProcess(&mePsn);
	[Clicker listProcs];
	lastActiveProc.lowLongOfPSN=0;
	lastActiveProc.highLongOfPSN=0;
	err = GetFrontProcess(&lastActiveProc);
	if( 0 != err ){
		
	}
	err = SameProcess(&mePsn,&lastActiveProc,(Boolean *) &areSame);
	if(areSame){
		DEBUG(@"front proc is CCBG proc.");
		GetNextProcess(&lastActiveProc);
		if( 0 != err){
			DEBUG(@" error after getNextPSN: getNextProcess");
		}else{
			err = CopyProcessName(&lastActiveProc,(CFStringRef *)&procName);
			DEBUG(@"Next proc is: %@",procName);
		}
	}
}

+ (void) listProcs
{
	OSErr err;
	OSStatus stat;
    ProcessSerialNumber psn;
    ProcessSerialNumber paramPsn;
	BOOL isVis;
	NSString *procName;
    err =GetFrontProcess(&psn);
    paramPsn.highLongOfPSN=0;
    paramPsn.lowLongOfPSN=0;
    err =GetNextProcess(&paramPsn);
	DEBUG(@"listing procs");
    while(err==0 ){
		stat = CopyProcessName(&paramPsn,(CFStringRef *)&procName);
		isVis= (BOOL)IsProcessVisible(&paramPsn);
		DEBUG(@"proc: %@, visible? %@", procName, isVis ? @"Yes" : @"No");
        err = GetNextProcess(&paramPsn);
    }


}

- (void) flagsChanged:(NSEvent *)theEvent
{
    DEBUG(@"Clicker: flagsChanged");
        DEBUG(@"modifiers changed to: shift %d, ctrl %d, option %d, command %d, fn %d",[theEvent modifierFlags]&NSShiftKeyMask,
              [theEvent modifierFlags]&NSControlKeyMask,
              [theEvent modifierFlags]&NSAlternateKeyMask,
              [theEvent modifierFlags]&NSCommandKeyMask,
			  [theEvent modifierFlags]&NSFunctionKeyMask
			  );
	
	if(selectedMod<0){
		if(lastCornerEntered!=-1 && nil != lastScreen)        
			[self recalcAndShowHoverWindow: lastCornerEntered
								  onScreen: lastScreen
								 modifiers: [theEvent modifierFlags]
								   doDelay: NO
								actionList: nil];
	}
}
- (void)applicationDidHide:(NSNotification *)aNotification
{
   // [[aNotification object] unhideWithoutActivation];
}

+(unsigned int) eventFlagsForMods:(int)mods
{
	unsigned int flags=0;
	if(mods & SHIFT_MASK)
		flags|=NSShiftKeyMask;
	if(mods & OPTION_MASK)
		flags|=NSAlternateKeyMask;
	if(mods & COMMAND_MASK)
		flags|=NSCommandKeyMask;
	if(mods & CONTROL_MASK)
		flags|=NSControlKeyMask;
	if(mods & FN_MASK)
		flags|=NSFunctionKeyMask;
	return flags;
}

+(int) modsForEventFlags:(unsigned int) evtFlags
{
	int flags=0;
    if(evtFlags & NSShiftKeyMask)
        flags|=SHIFT_MASK;
    if(evtFlags & NSAlternateKeyMask)
        flags|=OPTION_MASK;
    if(evtFlags & NSCommandKeyMask)
        flags|=COMMAND_MASK;
    if(evtFlags & NSControlKeyMask)
        flags|=CONTROL_MASK;
    if(evtFlags & NSFunctionKeyMask)
        flags|=FN_MASK;
	return flags;
}



- (void)scrollWheel: (NSEvent *)theEvent  atCorner: (int)theCorner
{
	int y = -1 * (int)ceil([theEvent deltaY]);
	y = (y > 0 ? 1 : (y < 0 ? -1 : 0));
	[self scroll:y atCorner:theCorner modifiers:[theEvent modifierFlags]];
}
- (void)scroll: (int)direction  atCorner: (int)theCorner modifiers:(int) modifiers
{
	int x;
	int mabove,mbelow;
	mabove=2;
	mbelow=1;
    if(delayTimer!=nil){
        [delayTimer invalidate];
        [delayTimer release];
        delayTimer=nil;
    }
	if(lastCornerEntered==-1 || nil == lastScreen)        
		return;
	NSWindow *window= [self windowForScreen:lastScreen atCorner:theCorner];
	ClickView *view = (ClickView *)[window contentView];
	NSArray *uMods = [view actionsGroups];
	int found,y;
	unsigned int flags ;
	int c = [uMods count];
	DEBUG2(@"number of unique mods: %d",c);
	found=selectedMod;
	DEBUG2(@"found is: %d", found);
	if(found < 0){
		found=0;
	}else{
		y = direction;
		found = [Clicker add: y
						  to: found 
						 mod: c];
	}
	DEBUG2(@"scrolled to index: %d", found);
	selectedMod=found;
	NSMutableArray *bactsArr = [[[NSMutableArray alloc] init] autorelease];

	for(x = 0; x <c; x++){
		DEBUG2(@"build action: %d",x);
		NSArray *actions = (NSArray *)[uMods objectAtIndex: x];
		[bactsArr addObject:
			[hoverView bubbleAction:actions]];
	}
	DEBUG2(@"create actions list");
    @synchronized(hoverView){
            
        BubbleActionsList *bactsList=[[[hoverView drawingObject] retain] autorelease];
        if(isShowingHover && bactsList != nil && [bactsList corner]==lastCornerEntered){
            DEBUG(@"isShowingHover && drawingObject != nil");
            //bactsList = [hoverView drawingObject];
            [hoverView newSelectedMod:selectedMod];
        }else{
            DEBUG(@"! (isShowingHover && drawingObject != nil)");
            
            bactsList= [hoverView bubbleActionsList: bactsArr
                                          forCorner: lastCornerEntered
                                           selected: selectedMod
                                  andHighlightColor: [self determineHighlightColor]];
        }
        DEBUG2(@"the modifiers to use: %d", flags);
        if(lastCornerEntered!=-1 && nil != lastScreen)        
            [self recalcAndShowHoverWindow: lastCornerEntered
                                  onScreen:lastScreen 
                                 modifiers:-1
                                   doDelay:NO
                                actionList:bactsList];
            //[self recalcAndShowHoverWindow: lastCornerEntered onScreen:lastScreen modifiers: flags doDelay:NO];
        
    }
}

+ (int) add:(int)a to:(int)b mod:(int)m
{
	int l = (a + b) % m;
	if(l < 0 )
		l += m;
	return l;
}

- (void) doAction:(int) corner onScreen:(NSNumber *)num withFlags:(int)flags forTrigger:(int) trigger
{
    int i;
    ClickAction *theAction;
	ClickWindow *window = [self windowForScreen:num atCorner:corner];
	NSArray *myActions = [[window contentView] clickActions];
    for(i=0;i<[myActions count]; i++){
        theAction = (ClickAction *)[myActions objectAtIndex:i];
        if([theAction modifiers]==flags && [theAction trigger]==trigger){
            //NSLog(@"do action %@",[theAction label]);
			[self actionActivating: theAction];
            [theAction doAction:nil];
            //return;
        }
    }
	[hoverWin setAlphaValue: 0];
    
    isShowingHover=NO;
}
- (void) mouseDownTrigger: (NSEvent *) theEvent onView: (ClickView *)view
				   flags:(int) flags trigger:(int) trigger
				onCorner:(int) corner
{
	
	int sel = selectedMod;
	if(sel <0){
		[self doAction:corner onScreen:[CornerClickSupport numberForScreen:[[view window] screen]]
			 withFlags:(flags < 0 ? [Clicker modsForEventFlags:[theEvent modifierFlags]] : flags)
																forTrigger:trigger];
	}else{
		NSArray *groups = [view actionsGroups];
		
		selectedMod=-1;
		NSArray *m = (NSArray *)[groups objectAtIndex:sel];
		ClickAction *act = (ClickAction *)[m objectAtIndex:0];
		
		[self doAction:corner onScreen:[CornerClickSupport numberForScreen:[[view window] screen]]
			 withFlags:[act modifiers]
			forTrigger:[act trigger]];
		
	}
}
- (NSWindow *)findWindowAtPoint:(NSPoint)point
{
	//meh, just get last window...
	NSWindow *last = [self windowForScreen:lastScreen atCorner:lastCornerEntered];
	return last;
}
- (void)sendEvent:(NSEvent *)anEvent
{
	//NSLog(@"Clicker rcvd event: %@",[anEvent description]);
	if([anEvent windowNumber]==0){
		if([anEvent type]== NSRightMouseDown){
			DEBUG(@"right mouse at point: %@",NSStringFromPoint([anEvent locationInWindow]));
			NSWindow *theWindow = [self findWindowAtPoint:[anEvent locationInWindow]];
			[[theWindow contentView] rightMouseDown:anEvent];
		}else if([anEvent type]==NSOtherMouseDown ){
			DEBUG(@"right mouse at point: %@",NSStringFromPoint([anEvent locationInWindow]));
			NSWindow *theWindow = [self findWindowAtPoint:[anEvent locationInWindow]];
			[[theWindow contentView] otherMouseDown:anEvent];
			
		}
			/*   || [anEvent type]==		   NSOtherMouseDown
			   || [anEvent type]==		   NSOtherMouseUp
			   || [anEvent type]==		   NSMouseMoved
			   || [anEvent type]==		   NSLeftMouseDragged
			   || [anEvent type]==		   NSRightMouseDragged
			   || [anEvent type]==		   NSOtherMouseDragged*/
	}
	
}
- (void) actionActivating: (ClickAction *)theAction
{
	actionPerformed=YES;
}

- (void)mouseExited:(NSEvent *)theEvent
{
    int corn = [[(NSArray *)[theEvent userData] objectAtIndex:0] intValue];
    NSNumber *num = (NSNumber *)[(NSArray *)[theEvent userData] objectAtIndex:1];
	[self fadeOutCorner:corn onScreen:num];
}
-(void)fadeOutCorner:(int)corn onScreen:(NSNumber *)num
{    
	if(lastCornerEntered < 0 || lastScreen == nil)
		return;
    ClickWindow *window;
	window =  [self windowForScreen:num atCorner:corn];
    [window setAlphaValue: 0.1];
    
    DEBUG(@"MAKE KEY AND ORDER FRONT.  IS KEY: %@, ACTIVE: %@",[NSApp keyWindow]==window ? @"YES":@"NO",
          [NSApp isActive]?@"YES":@"NO");
    if([appSettings toolTipEnabled]){
        [self hideHoverFadeOut];
    }
	[window close];
    [window orderBack:self];
	[window resignKeyWindow];
    [self showOtherWindows:corn onScreen:num];
    [NSApp deactivate];
	DEBUG(@"FADED CORNER: %d",corn);
	actionPerformed=NO;
    
    isShowingHover=NO;
	
    lastCornerEntered=-1;
	lastScreen = nil;
	selectedMod=-1;
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
