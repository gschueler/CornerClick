#import "Clicker.h"
#import <Carbon/Carbon.h>

int selectedMod=-1;

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
    appSettings = [[CornerClickSupport settingsFromUserPreferencesWithClicker: self] retain];
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
                [NSArray arrayWithObjects: [NSNumber numberWithInt: CC_APP_VERSION], [NSNumber numberWithInt: CC_PATCH_VERSION], nil]
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
    ClickAction *theAction;
	NSArray *thearr;
	BubbleActionsList *actsList;
    ClickWindow *window = [self windowForScreen:screenNum atCorner:corner];

	actsList=actionsList;
    NSPoint newPoint;
    NSPoint oldPoint=[self pointForCorner: corner onScreen:screenNum];
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
		if(actsList==nil){
			thearr = [[window contentView] clickActionsForModifierFlags: modifiers];	
			actsList = [hoverView bubbleActionsList:
				[NSArray arrayWithObject:[hoverView bubbleAction: thearr]]
											 selected:-1
								  andHighlightColor:  [self determineHighlightColor]];
		}
        if(thearr !=nil){
			if(DEBUG_ON)NSLog(@"displaying in showHover");
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
			[hoverWin setFrame: NSMakeRect(newPoint.x, newPoint.y, r.size.width, r.size.height) display: YES];

            lastHoverCorner=-1;
			if([hoverWin alphaValue] < 1.0)
				[hoverWin setAlphaValue: 1.0];
			if(![hoverWin isVisible])
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
        [fadeTimer invalidate];
        [fadeTimer release];
        fadeTimer=nil;
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
    if( fadeTimer!=nil){
        [fadeTimer invalidate];
        [fadeTimer release];
        fadeTimer=nil;
    }
    NSInvocation *nsinv = [NSInvocation invocationWithMethodSignature: [self methodSignatureForSelector:@selector(hideHoverDoFadeout)]];
    [nsinv setSelector:@selector(hideHoverDoFadeout)];
    [nsinv setTarget:self];

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
	NSPoint mouseLoc;
	NSEvent *theEvent;
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
		[window makeKeyAndOrderFront:nil];
		
        if(actionsList!=nil || [[window contentView] clickActionForModifierFlags: modifiers]!=nil){
            [window setAlphaValue: 1.0];

			
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
	lastScreen = screenNum;
	actionPerformed=NO;
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
		NSLog(@"front proc is CCBG proc.");
		GetNextProcess(&lastActiveProc);
		if( 0 != err){
			NSLog(@" error after getNextPSN: getNextProcess");
		}else{
			err = CopyProcessName(&lastActiveProc,&procName);
			NSLog(@"Next proc is: %@",procName);
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
    NSDictionary *procInfo;
	NSString *procName;
    err =GetFrontProcess(&psn);
    paramPsn.highLongOfPSN=0;
    paramPsn.lowLongOfPSN=0;
    err =GetNextProcess(&paramPsn);
	NSLog(@"listing procs");
    while(err==0 ){
		stat = CopyProcessName(&paramPsn,&procName);
		isVis= (BOOL)IsProcessVisible(&paramPsn);
		NSLog(@"proc: %@, visible? %@", procName, isVis ? @"Yes" : @"No");
        err = GetNextProcess(&paramPsn);
    }


}

- (void) flagsChanged:(NSEvent *)theEvent
{
    DEBUG(@"Clicker: flagsChanged");
        NSLog(@"modifiers changed to: shift %d, ctrl %d, option %d, command %d, fn %d",[theEvent modifierFlags]&NSShiftKeyMask,
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


- (void)scrollWheel2: (NSEvent *)theEvent  atCorner: (int)theCorner
{
	if(lastCornerEntered==-1 || nil == lastScreen)        
		return;
	NSWindow *window= [self windowForScreen:lastScreen atCorner:theCorner];
	ClickView *view = (ClickView *)[window contentView];
	NSArray *uMods = [view uniqueModifiersList];
	int mods = [Clicker modsForEventFlags:[theEvent modifierFlags]];
	int found,i,y;
	unsigned int flags;
	int c = [uMods count];
	NSLog(@"number of unique mods: %d",[uMods count]);
	if(selectedMod<0){
		found=-1;
		for(i=0;i<[uMods count];i++){
			NSNumber *num = (NSNumber *)[uMods objectAtIndex:i];
			if(mods == [num intValue]){
				found=i;
				break;
			}
		}
	}else{
		found=selectedMod;
	}
	NSLog(@"found is: %d", found);
	if(found < 0){
		found=0;
	}else{
		y = (int)ceil([theEvent deltaY]);
		NSLog(@"y is: %d, found is %d;  uMods is %d;  found+y = %d, %% count = %d", y, found, c, (found + y), ((found +y) % c));
		NSLog(@"-1 %% 7 = %d", (-1 % 7));
		found = (found + y)%c;
		if(found < 0 )
			found = c+found;
	}
	NSLog(@"scrolled to index: %d", found);
	selectedMod=found;
	NSNumber *num = (NSNumber *)[uMods objectAtIndex: found];
	flags = [Clicker eventFlagsForMods: [num intValue]];
	NSLog(@"the modifiers to use: %d", flags);
	if(lastCornerEntered!=-1 && nil != lastScreen)        
		[self recalcAndShowHoverWindow: lastCornerEntered onScreen:lastScreen modifiers: flags doDelay:NO];
	
}

- (void)scrollWheel: (NSEvent *)theEvent  atCorner: (int)theCorner
{
	int y = -1 * (int)ceil([theEvent deltaY]);
	y = (y > 0 ? 1 : (y < 0 ? -1 : 0));
	[self scroll:y atCorner:theCorner modifiers:[theEvent modifierFlags]];
}
- (void)scroll: (int)direction  atCorner: (int)theCorner modifiers:(int) modifiers
{
	int x,above,below;
	int mabove,mbelow;
	mabove=2;
	mbelow=1;
	if(lastCornerEntered==-1 || nil == lastScreen)        
		return;
	NSWindow *window= [self windowForScreen:lastScreen atCorner:theCorner];
	ClickView *view = (ClickView *)[window contentView];
	NSArray *uMods = [view actionsGroups];
	int mods = [Clicker modsForEventFlags:modifiers];
	int found,i,y;
	unsigned int flags ;
	int c = [uMods count];
	DEBUG(@"number of unique mods: %d",c);
	found=selectedMod;
	DEBUG(@"found is: %d", found);
	if(found < 0){
		found=0;
	}else{
		y = direction;
		found = [Clicker add: y
						  to: found 
						 mod: c];
	}
	DEBUG(@"scrolled to index: %d", found);
	selectedMod=found;
	NSMutableArray *bactsArr = [[[NSMutableArray alloc] init] autorelease];

	for(x = 0; x <c; x++){
		if(DEBUG_ON)NSLog(@"build action: %d",x);
		NSArray *actions = (NSArray *)[uMods objectAtIndex: x];
		[bactsArr addObject:
			[hoverView bubbleAction:actions]];
	}
	if(DEBUG_ON)NSLog(@"create actions list");
	BubbleActionsList *bactsList = [hoverView bubbleActionsList:bactsArr
													   selected: selectedMod
											  andHighlightColor: [self determineHighlightColor]];
	if(DEBUG_ON)NSLog(@"the modifiers to use: %d", flags);
	if(lastCornerEntered!=-1 && nil != lastScreen)        
		[self recalcAndShowHoverWindow: lastCornerEntered
							  onScreen:lastScreen 
							 modifiers:-1
							   doDelay:NO
							actionList:bactsList];
		//[self recalcAndShowHoverWindow: lastCornerEntered onScreen:lastScreen modifiers: flags doDelay:NO];

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
    if([appSettings toolTipEnabled]){
        [self hideHoverFadeOut];
    }
	[window resignKeyWindow];
    [window close];
	[window orderBack:self];
	
	actionPerformed=NO;
	
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
