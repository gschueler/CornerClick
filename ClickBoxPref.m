//
//  ClickBoxPref.m
//  ClickBox
//
//  Created by Greg Schueler on Wed Jul 16 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "ClickBoxPref.h"


@implementation ClickBoxPref

- (void) mainViewDidLoad
{
    NSDictionary *prefs=[[NSUserDefaults standardUserDefaults]
      persistentDomainForName:@"CornerClickPref"];
    //NSLog(@"Identifier is %@",[[NSBundle bundleForClass:[self class]] bundleIdentifier]);

    [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(saveChangesFromNotification:)
           name:NSApplicationWillTerminateNotification
         object:nil];


    [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                        selector: @selector(helperAppIsRunning:)
                                                            name: @"CornerClickPingBackNotification"
                                                          object: nil
                                              suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
    
        [cornerChoicePopupButton selectItemAtIndex: 0];
        chosenCorner=0;
        active=NO;
        [appLaunchIndicator setStyle: NSProgressIndicatorSpinningStyle];
    if(prefs) {
        tl = [[prefs objectForKey:@"tl"] mutableCopy];
        tr = [[prefs objectForKey:@"tr"] mutableCopy];
        bl = [[prefs objectForKey:@"bl"] mutableCopy];
        br = [[prefs objectForKey:@"br"] mutableCopy];
        appPrefs = [prefs mutableCopy];


        [showTooltipCheckBox setState:[[appPrefs objectForKey:@"tooltip"] intValue]];
        [delayTooltipCheckBox setState:[[appPrefs objectForKey:@"tooltipDelayed"] intValue]];
        [delayTooltipCheckBox setEnabled: ([[appPrefs objectForKey:@"tooltip"] intValue]==1)];
        [appEnabledCheckBox setState: [[appPrefs objectForKey:@"appEnabled"] intValue]];
        
    }else{
        tl = [[NSMutableDictionary dictionaryWithCapacity:4] retain];
        [tl setObject: [NSNumber numberWithInt:0] forKey:@"enabled"];
        [tl setObject: [NSNumber numberWithInt:0] forKey:@"action"];
        [tl setObject: [NSNumber numberWithInt:0] forKey:@"trigger"];
        //[tl setObject: @"" forKey:@"chosenFilePath"];
        tr = [[NSMutableDictionary alloc] initWithDictionary: tl copyItems:YES];
        bl = [[NSMutableDictionary alloc] initWithDictionary: tl copyItems:YES];
        br = [[NSMutableDictionary alloc] initWithDictionary: tl copyItems:YES];

        appPrefs = [[NSMutableDictionary dictionaryWithCapacity:3] retain];
        [appPrefs setObject: [NSNumber numberWithInt:1] forKey:@"tooltip"];
        [appPrefs setObject: [NSNumber numberWithInt:1] forKey:@"tooltipDelayed"];
        [appPrefs setObject:[NSNumber numberWithInt: 0] forKey:@"appEnabled"]; 
    }
    currentDict = tl;
    [self refreshWithSettings: currentDict];

    [self checkIfHelperAppRunning];
}


- (void) checkIfHelperAppRunning
{
    //NSLog(@"send ping to app");
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName: @"CornerClickPingAppNotification"
                                                                   object: nil
                                                                 userInfo: [NSDictionary dictionaryWithObject: [NSNumber numberWithInt: CB_APP_VERSION] forKey: @"CornerClickAppVersion"]
                                                       deliverImmediately: YES];
}

- (void) setAutoLaunch: (BOOL) launch forApp: (NSString *)path
{
    NSMutableDictionary *prefs;
    NSDictionary *item;
    NSMutableArray *mprefs;
    int i;
    prefs = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"loginwindow"] mutableCopy];
    if(prefs!=nil){
        mprefs = [[prefs objectForKey:@"AutoLaunchedApplicationDictionary"] mutableCopy];
        for(i=0;i<[mprefs count];i++){
            item = (NSDictionary *)[mprefs objectAtIndex: i];
            if([path isEqualToString: [item objectForKey:@"Path"]]){
                if(launch)
                    return;
                else{
                    [mprefs removeObjectAtIndex: i];
                    [prefs setObject: mprefs forKey:@"AutoLaunchedApplicationDictionary"];
                    [[NSUserDefaults standardUserDefaults] setPersistentDomain: prefs forName:@"loginwindow"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    return;
                }
            }
        }
        if(launch){
            [mprefs addObject: [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: path, [NSNumber numberWithBool:NO],nil]
                                                        forKeys: [NSArray arrayWithObjects: @"Path", @"Hide",nil]
                ]
                ];
            [prefs setObject: mprefs forKey:@"AutoLaunchedApplicationDictionary"];
            [[NSUserDefaults standardUserDefaults] setPersistentDomain: prefs forName:@"loginwindow"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return;
        }
    }
}

- (void) helperAppIsRunning: (NSNotification *) notice
{
    NSNumber *num = [[notice userInfo] objectForKey:@"CornerClickAppVersion"];
    int vers = [num intValue];
    int maj = (int)((vers/1000));
    int min= vers%1000;
    active=YES;
    if(vers != CB_APP_VERSION){
        [appLaunchErrorLabel setStringValue: [NSString stringWithFormat: @"A different version (v%d.%d) is running.",
            maj,min]];        
    }else{
        [appLaunchErrorLabel setStringValue: @""];

    }
    [appLaunchIndicator stopAnimation:self];
    [appEnabledCheckBox setState: 1 ];
}

- (void) helperAppDidTerminate: (NSNotification *)notice
{

    [[NSDistributedNotificationCenter defaultCenter]  removeObserver:self
                                                name:@"CornerClickDisableAppReplyNotification"
                                                object:nil];

    if(disableTimer!=nil){
        [disableTimer invalidate];
        [disableTimer release];
        disableTimer=nil;
    }
    [appLaunchErrorLabel setStringValue: @""];
    [appLaunchIndicator stopAnimation:self];
    [appEnabledCheckBox setState:0];
    active=NO;
    [appPrefs setObject:[NSNumber numberWithInt: active?1:0] forKey:@"appEnabled"];
}

- (void) helperAppTerminateTimeout
{
    [[NSDistributedNotificationCenter defaultCenter]  removeObserver:self
                                                 name:@"CornerClickDisableAppReplyNotification"
                                               object:nil];
    if(disableTimer!=nil){
        [disableTimer invalidate];
        [disableTimer release];
        disableTimer=nil;
    }
    //NSLog(@"Failed to quit bg app");
    [appLaunchErrorLabel setStringValue: @"Couldn't quit helper application"];
    [appLaunchIndicator stopAnimation:self];
    [appEnabledCheckBox setState:1];
    [appEnabledCheckBox setNeedsDisplay: YES];
    active=YES;
    [appPrefs setObject:[NSNumber numberWithInt: active?1:0] forKey:@"appEnabled"];
}

- (IBAction)appEnable:(id)sender
{
    NSBundle *bundle;
    NSString *apppath;
    BOOL success;
    bundle = [NSBundle bundleForClass:[ClickBoxPref class]];
    apppath = [bundle pathForResource:@"CornerClickBG" ofType:@"app"];
    //appLaunchIndicator
    if(active && [sender state]==0){

        if(disableTimer==nil){
            [appLaunchIndicator startAnimation:self];
            //register for app terminated messages

            [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                                selector: @selector(helperAppDidTerminate:)
                                                                    name: @"CornerClickDisableAppReplyNotification"
                                                                  object: nil
                                                      suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
            
            NSInvocation *nsinv = [NSInvocation invocationWithMethodSignature: [self methodSignatureForSelector:@selector(helperAppTerminateTimeout)]];
            [nsinv setSelector:@selector(helperAppTerminateTimeout)];
            [nsinv setTarget:self];
            disableTimer = [[NSTimer scheduledTimerWithTimeInterval:20 invocation:nsinv repeats:NO] retain];

            [self setAutoLaunch:NO forApp:apppath];
        }
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName: @"CornerClickDisableAppNotification"
                                                                       object: nil
                                                                     userInfo:nil
                                                           deliverImmediately:YES];
        
    }else if(!active && [sender state]){
        [appLaunchErrorLabel setStringValue: @""];
        [appLaunchIndicator startAnimation:self];
        [self saveChanges];
        if(apppath ==nil)
            success=NO;
        else
            success = [[NSWorkspace sharedWorkspace] launchApplication: apppath];
        if(!success){
            //NSLog(@"Failed to launch bg app");
            [appLaunchErrorLabel setStringValue: @"Couldn't launch helper application"];
            [appLaunchIndicator stopAnimation:self];
            [appEnabledCheckBox setState:0];
            active=NO;
        }else{
            [self setAutoLaunch:YES forApp:apppath];
            [appLaunchErrorLabel setStringValue: @""];
            [appLaunchIndicator stopAnimation:self];
            active=YES;
        }
    }
    [appPrefs setObject:[NSNumber numberWithInt: active?1:0] forKey:@"appEnabled"];
}
- (IBAction)tooltipEnable:(id)sender
{
    int state = [sender state]==NSOnState?1:0;
    //NSLog(@"Enabled: %d",state);
    if(appPrefs){
        //NSLog(@"CurrentDict type: %@",[currentDict class]);
        [appPrefs setObject: [NSNumber numberWithInt: state ] forKey:@"tooltip"];
    }

    [delayTooltipCheckBox setEnabled: ([sender state]==NSOnState)];
    [self notifyAppOfPreferences:[self makePrefs]];

}
- (IBAction)tooltipDelay:(id)sender
{
    int state = [sender state]==NSOnState?1:0;
    //NSLog(@"Enabled: %d",state);
    if(appPrefs){
        //NSLog(@"CurrentDict type: %@",[currentDict class]);
        [appPrefs setObject: [NSNumber numberWithInt: state ] forKey:@"tooltipDelayed"];
        [self notifyAppOfPreferences:[self makePrefs]];
    }
}

- (void) refreshWithSettings:(NSDictionary *)settings
{

    //NSLog(@"retain count of settings: %d",[settings retainCount]);
    
    [enabledCheckBox setState:[[settings objectForKey:@"enabled"] intValue]];
    [actionChoicePopupButton selectItemAtIndex: [[settings objectForKey:@"action"] intValue]];
    [triggerChoicePopupButton selectItemAtIndex: [[settings objectForKey:@"trigger"] intValue]];
    [appEnabledCheckBox setState:[[appPrefs objectForKey:@"appEnabled"] intValue]];

    NSString *url = [settings objectForKey:@"chosenURL"];
    NSString *urld = [settings objectForKey:@"urlDesc"];
    NSString *label = [settings objectForKey:@"chosenFilePath"];
    if(label){
        NSFileWrapper *temp = [[[NSFileWrapper alloc] initWithPath: [settings objectForKey:@"chosenFilePath"]] autorelease];
        if(temp){
            [chosenFileLabel setStringValue: [[settings objectForKey:@"chosenFilePath"] lastPathComponent]];
            [fileIconImageView setImage: [temp icon]];
        }else{
            [chosenFileLabel setStringValue: @"no file chosen"];
            [fileIconImageView setImage: nil];
        }
    }else{
        [chosenFileLabel setStringValue: @"no file chosen"];
        [fileIconImageView setImage: nil];
    }
    if(url!=nil){
        [urlTextField setStringValue:url];
    }else{
        [urlTextField setStringValue:@"http://"];
    }
    if(urld!=nil){
        [urlLabelField setStringValue:urld];
    }else{
        [urlLabelField setStringValue:@""];
    }
    [self setSubFrameForActionType: [[settings objectForKey:@"action"] intValue]];    
}

- (void)openSheetDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    //NSLog(@"Sheet finished");

    if(returnCode==NSOKButton){
        NSString *thefile = [[sheet filenames] objectAtIndex:0];
        [currentDict setObject:thefile forKey:@"chosenFilePath"];
        [chosenFileLabel setStringValue: [thefile lastPathComponent]];
        
        //NSFileWrapper *temp = [[[NSFileWrapper alloc] initWithPath: thefile] autorelease];
        [fileIconImageView setImage: [[NSWorkspace sharedWorkspace] iconForFile: thefile]];
        [self notifyAppOfPreferences:[self makePrefs]];
    }

}

- (void) urlEntered: (id) sender
{
    [currentDict setObject:[urlTextField stringValue] forKey:@"chosenURL"];
    if([[urlLabelField stringValue] length] > 0){
        [currentDict setObject:[urlLabelField stringValue] forKey:@"urlDesc"];
    }else{
        [currentDict removeObjectForKey:@"urlDesc"];
    }
    [self notifyAppOfPreferences:[self makePrefs]];
}

- (void) didUnselect
{
    //NSLog(@"didUnselect");
    //[self notifyAppOfPreferences:[self makePrefs]];
}

- (void) saveChangesFromNotification:(NSNotification*)aNotification
{
    [self saveChanges];
}

- (NSDictionary *)makePrefs
{
    NSDictionary *prefs;
    NSDictionary *tlcpy;
    NSDictionary *trcpy;
    NSDictionary *blcpy;
    NSDictionary *brcpy;
    //NSLog(@"Save Changes");
    tlcpy = [[[NSDictionary alloc] initWithDictionary: tl copyItems:YES] autorelease];
    trcpy = [[[NSDictionary alloc] initWithDictionary: tr copyItems:YES] autorelease];
    blcpy = [[[NSDictionary alloc] initWithDictionary: bl copyItems:YES] autorelease];
    brcpy = [[[NSDictionary alloc] initWithDictionary: br copyItems:YES] autorelease];
    prefs=[[NSDictionary alloc] initWithObjectsAndKeys:
        tlcpy,@"tl",
        trcpy,@"tr",
        blcpy,@"bl",
        brcpy,@"br",
        [appPrefs objectForKey:@"tooltip"],@"tooltip",
        [appPrefs objectForKey:@"tooltipDelayed"],@"tooltipDelayed",
        [NSNumber numberWithInt: active?1:0 ],@"appEnabled",
        nil];

    [prefs autorelease];
    return prefs;
}
- (void) saveChanges
{

    NSDictionary *prefs = [self makePrefs];

    //NSLog(@"Made Dictionary");
    
    [[NSUserDefaults standardUserDefaults]
        removePersistentDomainForName:@"CornerClickPref"];

    //NSLog(@"removedDomain");
    
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:prefs
         forName:@"CornerClickPref"];

    [[NSUserDefaults standardUserDefaults] synchronize];
    //NSLog(@"setDomain");
    [self notifyAppOfPreferences: prefs];
}

- (void) notifyAppOfPreferences: (NSDictionary *) prefs
{
    //notify the app if it's running
    [[NSDistributedNotificationCenter defaultCenter]
     postNotificationName: @"CornerClickLoadPrefsNotification" object: nil
                 userInfo:prefs
       deliverImmediately:YES];
}

- (IBAction)actionChosen:(id)sender
{

    //NSLog(@"Choose action: %d",[sender indexOfSelectedItem]);
    int oldval = [[currentDict objectForKey: @"action"] intValue];
    if(oldval==[sender indexOfSelectedItem]){
        return;
    }
    [currentDict setObject: [NSNumber numberWithInt: [sender indexOfSelectedItem] ] forKey:@"action"];
    [self setSubFrameForActionType: [sender indexOfSelectedItem]];
    [self notifyAppOfPreferences:[self makePrefs]];
}

- (void) setSubFrameForActionType: (int) type
{
    NSArray *sub = [actionView subviews];
    int i;
    for(i=0;i<[sub count];i++){
        [[sub objectAtIndex:i] retain];
        [[sub objectAtIndex:i] removeFromSuperview];
    }
    NSRect frame = [actionView frame];
    switch(type){
        case 0: //open file
            [actionView addSubview: chooseFileView];
            [actionView setFrameSize: [chooseFileView frame].size];
            break;
        case 3:
            [actionView addSubview: chooseURLView];
            [actionView setFrameSize: [chooseURLView frame].size];
            break;
        default:
            //[actionView setFrameSize: NSMakeSize(frame.size.width,0)];
            break;
    }
    [actionView setNeedsDisplay:YES];
}

- (IBAction)cornerChosen:(id)sender
{
    //NSLog(@"Choose corner: %d",[sender indexOfSelectedItem]);
    chosenCorner=[sender indexOfSelectedItem];
    switch([sender indexOfSelectedItem]){
        case 0:
            currentDict = tl;
            break;
        case 1:
            currentDict = tr;
            break;
        case 2:
            currentDict = bl;
            break;
        case 3:
            currentDict = br;
            break;
    }
    [self refreshWithSettings: currentDict];
}

- (IBAction)enableChosen:(id)sender
{
    int state = [sender state]==NSOnState?1:0;
    //NSLog(@"Enabled: %d",state);
    if(currentDict){
        //NSLog(@"CurrentDict type: %@",[currentDict class]);
        [currentDict setObject: [NSNumber numberWithInt: state ] forKey:@"enabled"];
        [self notifyAppOfPreferences:[self makePrefs]];
    }
}

- (IBAction)fileChooseClicked:(id)sender
{
    //NSLog(@"Choose file button");
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection: NO];
    [openPanel setCanChooseDirectories: YES];
    [openPanel setCanChooseFiles: YES];
//    [openPanel beginSheetForDirectory: nil file: nil fileTypes: nil modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(openSheetDidEnd:) contextInfo: nil];
    int result = [openPanel runModalForDirectory: nil file: nil types: nil];
    [self openSheetDidEnd:openPanel returnCode: result contextInfo:nil];
}

- (IBAction)triggerChosen:(id)sender
{

    //NSLog(@"Choose trigger: %d",[sender indexOfSelectedItem]);
    [currentDict setObject: [NSNumber numberWithInt: [sender indexOfSelectedItem] ] forKey:@"trigger"];
    [self notifyAppOfPreferences:[self makePrefs]];

}
@end
