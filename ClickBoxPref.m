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
    NSMutableArray *tempArray;
    NSMutableDictionary *tempDict;
    NSArray *columns;
    NSImageCell *imgcell;
    int i;
    
    NSDictionary *prefs=[[NSUserDefaults standardUserDefaults]
      persistentDomainForName:@"CornerClickPref"];
    //NSLog(@"Identifier is %@",[[NSBundle bundleForClass:[self class]] bundleIdentifier]);

    [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(saveChangesFromNotification:)
           name:NSApplicationWillTerminateNotification
         object:nil];

    [[NSNotificationCenter defaultCenter]
        addObserver: self
           selector:@selector(tableSelectionChanged:)
               name:NSTableViewSelectionDidChangeNotification
             object:actionTable];


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


        tempArray = [[tl objectForKey:@"actionList"] mutableCopy];
        for(i=0;i<[tempArray count];i++){
            tempDict = [[tempArray objectAtIndex:i] mutableCopy];
            [tempArray replaceObjectAtIndex:i withObject:tempDict];
        }
        [tl setObject:tempArray forKey:@"actionList"];
    

        tempArray = [[tr objectForKey:@"actionList"] mutableCopy];
        for(i=0;i<[tempArray count];i++){
            tempDict = [[tempArray objectAtIndex:i] mutableCopy];
            [tempArray replaceObjectAtIndex:i withObject:tempDict];
        }
        [tr setObject:tempArray forKey:@"actionList"];
    

        tempArray = [[bl objectForKey:@"actionList"] mutableCopy];
        for(i=0;i<[tempArray count];i++){
            tempDict = [[tempArray objectAtIndex:i] mutableCopy];
            [tempArray replaceObjectAtIndex:i withObject:tempDict];
        }

        [bl setObject:tempArray forKey:@"actionList"];
    

        tempArray = [[br objectForKey:@"actionList"] mutableCopy];
        for(i=0;i<[tempArray count];i++){
            tempDict = [[tempArray objectAtIndex:i] mutableCopy];
            [tempArray replaceObjectAtIndex:i withObject:tempDict];
        }

        [br setObject:tempArray forKey:@"actionList"];
        

    }else{
        tempArray = [NSMutableArray arrayWithCapacity:4];
        tl = [[NSMutableDictionary dictionaryWithCapacity:4] retain];
        [tl setObject: [NSNumber numberWithInt:1] forKey:@"enabled"];

        [tl setObject:  tempArray forKey:@"actionList"];
        tr = [[NSMutableDictionary alloc] initWithDictionary: tl copyItems:YES];
        [tr setObject:  [tempArray mutableCopy] forKey:@"actionList"];
        bl = [[NSMutableDictionary alloc] initWithDictionary: tl copyItems:YES];
        [bl setObject:  [tempArray mutableCopy] forKey:@"actionList"];
        br = [[NSMutableDictionary alloc] initWithDictionary: tl copyItems:YES];
        [br setObject:  [tempArray mutableCopy] forKey:@"actionList"];
        
        appPrefs = [[NSMutableDictionary dictionaryWithCapacity:3] retain];
        [appPrefs setObject: [NSNumber numberWithInt:1] forKey:@"tooltip"];
        [appPrefs setObject: [NSNumber numberWithInt:1] forKey:@"tooltipDelayed"];
        [appPrefs setObject:[NSNumber numberWithInt: 0] forKey:@"appEnabled"];


        
    }
    [showTooltipCheckBox setState:[[appPrefs objectForKey:@"tooltip"] intValue]];
    [delayTooltipCheckBox setState:[[appPrefs objectForKey:@"tooltipDelayed"] intValue]];
    [delayTooltipCheckBox setEnabled: ([[appPrefs objectForKey:@"tooltip"] intValue]==1)];
    [appEnabledCheckBox setState: [[appPrefs objectForKey:@"appEnabled"] intValue]];
    
    currentDict = tl;
    currentActions = [tl objectForKey:@"actionList"];
    [self refreshWithCornerSettings: currentDict];
    [self refreshWithSettings:nil];
    currentActionDict=nil;

    columns = [actionTable tableColumns];
    imgcell = [[[NSImageCell alloc] initImageCell:nil] autorelease];
    [[columns objectAtIndex:0] setIdentifier: @"icon"];
    [[columns objectAtIndex:0] setDataCell: imgcell];
//    [[columns objectAtIndex:0] setMinWidth: 20];
  //  [[columns objectAtIndex:0] setMaxWidth: 20];
    [[columns objectAtIndex:1] setIdentifier: @"desc"];
    [[columns objectAtIndex:2] setIdentifier: @"modifiers"];

    /*txtcell = [[[NSTextFieldCell alloc] initTextCell:@""] autorelease];
    [txtcell setTextColor:[NSColor grayColor]];
    [txtcell setFont: [NSFont fontWithName:@"Lucida Grande" size:10]];
    [txtcell setAlignment: NSRightTextAlignment];
    

    [[columns objectAtIndex:2] setDataCell: txtcell];
*/
    [[[columns objectAtIndex:2] dataCell] setFont: [NSFont systemFontOfSize:10]];
    [actionTable setDataSource:self];
    [readmeTextView readRTFDFromFile:[[NSBundle bundleForClass: [ClickBoxPref class]] pathForResource:@"Readme" ofType:@"rtf"]];
    [readmeTextView setContinuousSpellCheckingEnabled: NO];
    /*
    [readmeTextView setEditable:YES];
    [readmeTextView setSelectedRange: NSMakeRange([[readmeTextView string] length],0)];

    [readmeTextView insertText:@"\n"];
    [readmeTextView insertText: [self makeAttributedLink:@"mailto:greg-cc@vario.us" forString:@"greg-cc@vario.us"]];
    [readmeTextView insertText:@"\n"];
    [readmeTextView insertText: [self makeAttributedLink:@"http://greg.vario.us" forString:@"http://greg.vario.us"]];

    [readmeTextView setEditable:NO];
    [readmeTextView scrollRangeToVisible: NSMakeRange(0,0)];
     */
    [self checkIfHelperAppRunning];
}

- (NSAttributedString *)makeAttributedLink:(NSString *) link forString:(NSString *) string
{
    return
        [[[NSAttributedString alloc] initWithString:string
                                         attributes:
            [NSDictionary dictionaryWithObjects:
                [NSArray arrayWithObjects:[NSURL URLWithString:link],[NSColor blueColor],[NSNumber numberWithInt:1],nil]
                                        forKeys:
                [NSArray arrayWithObjects:NSLinkAttributeName,NSForegroundColorAttributeName,NSUnderlineStyleAttributeName,nil]
                ]] autorelease];
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

- (void) refreshWithCornerSettings: (NSDictionary *) settings
{
    int enabled=[[settings objectForKey:@"enabled"] intValue];
    [enabledCheckBox setState:enabled];
    //[appEnabledCheckBox setState:[[appPrefs objectForKey:@"appEnabled"] intValue]];
}

- (void) refreshWithSettings:(NSDictionary *)settings
{
    int flags=0;
    NSString *theString;
    //NSLog(@"retain count of settings: %d",[settings retainCount]);
    if(settings!=nil){
        flags = [[settings objectForKey:@"modifiers"] intValue];
        
        [removeActionButton setEnabled:YES];
        [optionKeyCheckBox setEnabled:YES];
        [shiftKeyCheckBox setEnabled:YES];
        [controlKeyCheckBox setEnabled:YES];
        [commandKeyCheckBox setEnabled:YES];
        //NSLog(@"flags (%d) & OPTION_MASK (%d) : %d",flags,OPTION_MASK,(flags & OPTION_MASK));
        [optionKeyCheckBox setState: ((flags & OPTION_MASK) > 0 ? NSOnState: NSOffState)];
        [shiftKeyCheckBox setState: ((flags & SHIFT_MASK) > 0 ? NSOnState: NSOffState)];
        [controlKeyCheckBox setState: ((flags & CONTROL_MASK) > 0 ? NSOnState: NSOffState)];
        [commandKeyCheckBox setState: ((flags & COMMAND_MASK) > 0 ? NSOnState: NSOffState)];
        
        [actionChoicePopupButton setEnabled:YES];
        [triggerChoicePopupButton setEnabled:YES];
        [actionChoicePopupButton selectItemAtIndex: [[settings objectForKey:@"action"] intValue]];
        [triggerChoicePopupButton selectItemAtIndex: [[settings objectForKey:@"trigger"] intValue]];
    
        NSString *url = [settings objectForKey:@"chosenURL"];
        NSString *urld = [settings objectForKey:@"urlDesc"];
        NSString *label = [settings objectForKey:@"chosenFilePath"];
        if(label){
            theString=[settings objectForKey:@"chosenFilePath"];
            if(theString!=nil){
                if([theString hasSuffix:@".app"]){
                    [chosenFileLabel setStringValue: [[theString lastPathComponent] stringByDeletingPathExtension]];
                }else{
                    [chosenFileLabel setStringValue: [theString lastPathComponent]];
                }
                [fileIconImageView setImage: [[NSWorkspace sharedWorkspace] iconForFile: theString]];
            }else{
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
    }else{
        [removeActionButton setEnabled:NO];
        [optionKeyCheckBox setEnabled:NO];
        [shiftKeyCheckBox setEnabled:NO];
        [controlKeyCheckBox setEnabled:NO];
        [commandKeyCheckBox setEnabled:NO];
        [optionKeyCheckBox setState:NSOffState];
        [shiftKeyCheckBox setState:NSOffState];
        [controlKeyCheckBox setState:NSOffState];
        [commandKeyCheckBox setState:NSOffState];
        [actionChoicePopupButton setEnabled:NO];
        [triggerChoicePopupButton setEnabled:NO];
        [self setSubFrameForActionType: -1];
    }
}

- (void)openSheetDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    //NSLog(@"Sheet finished");

    [sheet orderOut: self];
    if(returnCode==NSOKButton){
        NSString *thefile = [[sheet filenames] objectAtIndex:0];
        [currentActionDict setObject:thefile forKey:@"chosenFilePath"];
        if([thefile hasSuffix:@".app"]){
            [chosenFileLabel setStringValue: [[thefile lastPathComponent] stringByDeletingPathExtension]];
        }else{
            [chosenFileLabel setStringValue: [thefile lastPathComponent]];
        }
        
        //NSFileWrapper *temp = [[[NSFileWrapper alloc] initWithPath: thefile] autorelease];
        [fileIconImageView setImage: [[NSWorkspace sharedWorkspace] iconForFile: thefile]];
        [self notifyAppOfPreferences:[self makePrefs]];
        [actionTable reloadData];
    }
}

- (void) urlEntered: (id) sender
{
    [currentActionDict setObject:[urlTextField stringValue] forKey:@"chosenURL"];
    if([[urlLabelField stringValue] length] > 0){
        [currentActionDict setObject:[urlLabelField stringValue] forKey:@"urlDesc"];
    }else{
        [currentActionDict removeObjectForKey:@"urlDesc"];
    }
    [self notifyAppOfPreferences:[self makePrefs]];
    [actionTable reloadData];
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
    int oldval = [[currentActionDict objectForKey: @"action"] intValue];
    if(oldval==[sender indexOfSelectedItem]){
        return;
    }
    [currentActionDict setObject: [NSNumber numberWithInt: [sender indexOfSelectedItem] ] forKey:@"action"];
    [self setSubFrameForActionType: [sender indexOfSelectedItem]];
    [self notifyAppOfPreferences:[self makePrefs]];
    [actionTable reloadData];
}

- (void) setSubFrameForActionType: (int) type
{
    NSArray *sub = [actionView subviews];
    int i;
    for(i=0;i<[sub count];i++){
        [[sub objectAtIndex:i] retain];
        [[sub objectAtIndex:i] removeFromSuperview];
    }
    //NSRect frame = [actionView frame];
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
        default: currentDict=nil;
            break;
    }

    currentActions = [currentDict objectForKey:@"actionList"];
    [self refreshWithCornerSettings: currentDict];
    [self refreshWithSettings:nil];
    currentActionDict=nil;
    [actionTable deselectRow:[actionTable selectedRow]];
    [actionTable setNeedsDisplay:YES];
}

- (IBAction)enableChosen:(id)sender
{
    int state = [sender state]==NSOnState?1:0;
    //NSLog(@"Enabled: %d",state);
    if(currentDict){
        //NSLog(@"CurrentDict type: %@",[currentDict class]);
        [currentDict setObject: [NSNumber numberWithInt: state ] forKey:@"enabled"];
        [self refreshWithCornerSettings: currentDict];
        [self refreshWithSettings:nil];
        currentActionDict=nil;
        [actionTable deselectRow:[actionTable selectedRow]];
        [actionTable setNeedsDisplay:YES];
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
    [openPanel beginSheetForDirectory: nil file: nil types: nil modalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:@selector(openSheetDidEnd:returnCode:contextInfo:) contextInfo: nil];
    //int result = [openPanel runModalForDirectory: nil file: nil types: nil];
    //[self openSheetDidEnd:openPanel returnCode: result contextInfo:nil];
}

- (IBAction)triggerChosen:(id)sender
{

    //NSLog(@"Choose trigger: %d",[sender indexOfSelectedItem]);
    [currentActionDict setObject: [NSNumber numberWithInt: [sender indexOfSelectedItem] ] forKey:@"trigger"];
    [self notifyAppOfPreferences:[self makePrefs]];
    [actionTable reloadData];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [currentActions count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    int type,modifiers;
    NSString *theFile;
    NSDictionary *obj = [currentActions objectAtIndex:rowIndex];
    type = [[obj objectForKey:@"action"] intValue];
    modifiers = [[obj objectForKey:@"modifiers"] intValue];
    //NSLog(@"objectValueForTableColumn called: currentAcctions : %@",currentActions);
    if([[aTableColumn identifier] isEqualToString: @"icon"]){
        switch(type){
            case 0:
                if([obj objectForKey:@"chosenFilePath"]!=nil)
                    return [[NSWorkspace sharedWorkspace] iconForFile:[obj objectForKey:@"chosenFilePath"]];
                else
                    return nil;
                break;
            case 3: return [[[NSImage alloc] initWithContentsOfFile: [[NSBundle bundleForClass:[ClickBoxPref class]] pathForResource:@"BookmarkPreferences" ofType:@"tiff"]] autorelease];
            default: return nil;
        }
    }
    else if([[aTableColumn identifier] isEqualToString: @"desc"]){
        switch(type){
            case 0:
                theFile=[obj objectForKey:@"chosenFilePath"];
                if([theFile hasSuffix:@".app"]){
                    return [[theFile lastPathComponent] stringByDeletingPathExtension];
                }else{
                    return [theFile lastPathComponent];
                }
                return theFile;
            case 1: return @"Hide Current Application";
            case 2: return @"Hide Other Applications";
            case 3:
                if([obj objectForKey:@"urlDesc"] !=nil){
                    theFile= [obj objectForKey:@"urlDesc"];
                }else if([obj objectForKey:@"chosenURL"] !=nil){
                    theFile= [obj objectForKey:@"chosenURL"];
                }else{
                    theFile=@"";
                }
                return [NSString stringWithFormat:@"Open URL %@",theFile];
            default: return @"???";
        }
    }else if([[aTableColumn identifier] isEqualToString: @"modifiers"]){
        theFile = @"";
        if(modifiers & SHIFT_MASK){
            theFile = [NSString stringWithFormat:@"%C",(unichar)0x21E7];
        }
        if(modifiers & OPTION_MASK){
            if([theFile length]){
                theFile = [NSString stringWithFormat:@"%@ + %C",theFile,(unichar)0x2325];
            }else{
                theFile = [NSString stringWithFormat:@"%C",(unichar)0x2325];
            }
        }

        if(modifiers & COMMAND_MASK){
            if([theFile length]){
                theFile = [NSString stringWithFormat:@"%@ + %C",theFile,(unichar)0x2318];
            }else{
                theFile = [NSString stringWithFormat:@"%C",(unichar)0x2318];
            }
        }

        if(modifiers & CONTROL_MASK){
            if([theFile length]){
                theFile = [NSString stringWithFormat:@"%@ + %C",theFile,(unichar)0x2303];
            }else{
                theFile = [NSString stringWithFormat:@"%C",(unichar)0x2303];
            }
        }

        if([theFile length]){
            theFile = [NSString stringWithFormat:@"%@ Click",theFile];
        }else{
            theFile = @"Click";
        }
        return theFile;
        
    }
    return nil;
}


- (void)tableSelectionChanged:(NSNotification *) notice
{
    if([notice object]==actionTable){
        //NSLog(@"selection changed to: %d",[actionTable selectedRow]);
        if([actionTable selectedRow]>=0){
            currentActionDict=[currentActions objectAtIndex:[actionTable selectedRow]];
            [self refreshWithSettings:currentActionDict];
        }else{
            [self refreshWithSettings:nil];
        }
    }
}

- (void)toggleModifier: (int)modifier toState:(BOOL) used
{
    int flags=0;
    if([currentActionDict objectForKey:@"modifiers"] !=nil){
        flags = [[currentActionDict objectForKey:@"modifiers"] intValue];
    }else{
        flags=0;
    }
    if(used){
        flags = flags|modifier;
    }else{
        flags = flags & (~modifier);
    }
    [currentActionDict setObject:[NSNumber numberWithInt: flags] forKey:@"modifiers"];
}

- (IBAction)removeActionButtonClicked:(id)sender
{
    int sel=[actionTable selectedRow];
    //NSLog(@"selection changed to: %d",[actionTable selectedRow]);
    if(sel>=0){

        currentActionDict=nil;
        [currentActions removeObjectAtIndex:sel];
        [self notifyAppOfPreferences:[self makePrefs]];
        if(sel>0 && sel < [currentActions count] && [currentActions objectAtIndex:sel]!=nil){
            currentActionDict=[currentActions objectAtIndex:sel];
            [self refreshWithSettings:currentActionDict];
        }else{
            [actionTable deselectAll:self];
            [self refreshWithSettings:nil];
        }
        [actionTable reloadData];
    }else{
        [self refreshWithSettings:nil];
    }    
}
- (IBAction)addActionButtonClicked:(id)sender
{
    //NSLog(@"selection changed to: %d",[actionTable selectedRow]);
    NSMutableDictionary *newAct = [NSMutableDictionary dictionaryWithCapacity:4];
    [currentActions addObject:newAct];
    
    [newAct setObject: [NSNumber numberWithInt:0] forKey:@"action"];
    [newAct setObject: [NSNumber numberWithInt:0] forKey:@"trigger"];
    currentActionDict=newAct;
    [actionTable reloadData];

    [actionTable selectRow:[currentActions count]-1 byExtendingSelection:NO];
        
    [self refreshWithSettings:newAct];
  
}
- (IBAction)optionKeyCheckBoxClicked:(id)sender
{
    [self toggleModifier: OPTION_MASK toState: [sender state]==0?NO:YES];
    [self notifyAppOfPreferences:[self makePrefs]];
    [actionTable reloadData];
}
- (IBAction)shiftKeyCheckBoxClicked:(id)sender
{
    [self toggleModifier: SHIFT_MASK toState: [sender state]==0?NO:YES];
    [self notifyAppOfPreferences:[self makePrefs]];
    [actionTable reloadData];
}
- (IBAction)commandKeyCheckBoxClicked:(id)sender
{
    [self toggleModifier: COMMAND_MASK toState: [sender state]==0?NO:YES];
    [self notifyAppOfPreferences:[self makePrefs]];
    [actionTable reloadData];
}
- (IBAction)controlKeyCheckBoxClicked:(id)sender
{

    [self toggleModifier: CONTROL_MASK toState: [sender state]==0?NO:YES];
    [self notifyAppOfPreferences:[self makePrefs]];
    [actionTable reloadData];
}


@end
