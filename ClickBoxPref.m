//
//  ClickBoxPref.m
//  ClickBox
//
//  Created by Greg Schueler on Wed Jul 16 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "ClickBoxPref.h"
extern double CornerClickVersionNumber;

@interface ClickBoxPref (InternalMethods)
- (NSArray *) quickScriptsList;
- (NSArray *) quickFilesList;
- (void) loadQuickItems;
@end

@implementation ClickBoxPref

- (void) mainViewDidLoad
{    
    appSettings = [self appSettings];
    [readmeTextView readRTFDFromFile:[[self bundle] pathForResource:@"Information" ofType:@"rtf"]];
    [readmeTextView setContinuousSpellCheckingEnabled: NO];
    [versionStringField setStringValue: MARKETING_VERSION_STRING ];
    [self loadQuickItems];
}

- (void) addActionMenuItems: (NSArray *) list toMenu: (NSMenu *) menu
{
    int i;
    
    BOOL x=YES;
    for(i=0;i<[list count];i++){
        id obj = [list objectAtIndex:i];
        if([obj isKindOfClass:[NSArray class]]){
            NSArray *arr = (NSArray *)obj;
            NSMenu *newMenu = [[[NSMenu alloc] initWithTitle:(NSString *)[arr objectAtIndex:0]] autorelease];
            [self addActionMenuItems: [arr subarrayWithRange:NSMakeRange(1,[arr count]-1)]
                              toMenu: newMenu];
            if([newMenu numberOfItems] > 0){
                NSMenuItem *subItem = [[[NSMenuItem alloc] initWithTitle:(NSString *)[arr objectAtIndex:0]
                                                                  action:nil
                                                           keyEquivalent:@""] autorelease];
                [menu addItem: subItem];
                    [menu setSubmenu:newMenu forItem:subItem];
                x=NO;
            }
            continue;
        }else if([obj isKindOfClass:[NSString class]]){
            
        
            NSString *path = (NSString *)obj;
            NSString *exp = [path stringByExpandingTildeInPath];
            BOOL isDir=NO;
            if([path isEqualToString:@"-"]){
                if(!x)
                    [ menu addItem:[NSMenuItem separatorItem]];
                x=YES;
            }else if([[NSFileManager defaultManager] fileExistsAtPath:exp isDirectory: &isDir] || isDir){
                
                [ menu addItem:[[[FileActionMenuItem alloc] initWithFilePath:exp andClickPref:self] autorelease]];  
                x=NO;
            }
        }
    }
    
}

- (void) loadQuickItems
{
    if(!loadedQuickFiles){
            
        //quick apps
        [quickFilePopup removeAllItems];
        NSMenuItem *scriptItem = [[[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""] autorelease];
        NSImage *scptIcon = [[[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericApplicationIcon)] retain] autorelease];
        [scptIcon setSize:NSMakeSize(16,16)];
        [scriptItem setImage:scptIcon];
        [scriptItem setTitle:LOCALIZE([self bundle],@"Files")];
        [[quickFilePopup menu] addItem:scriptItem];

        //[quickFilePopup addItemWithTitle:LOCALIZE([self bundle],@"Quick...")];
        DEBUG(@"Bundle path: %@",[[self bundle] bundlePath]);
        [[quickFilePopup menu] addItem:[[[FileActionMenuItem alloc] initWithFilePath: [[self bundle] bundlePath] 
                                                                        andClickPref: self
                                                                            andTitle: LOCALIZE([self bundle], @"CornerClick Preferences")] autorelease]];  
       
        NSArray *list = [self quickFilesList];
        //[self _storeList:list atPath:@"~/Desktop/quickFiles.plist"];
        [self addActionMenuItems:list toMenu:[quickFilePopup menu]];
        loadedQuickFiles=YES;
    }
}
/*
- (void) _storeList: (id) plist atPath:(NSString *)aPath
{
    NSString *path = [aPath stringByExpandingTildeInPath];
    
    NSData *xmlData;
    
    NSString *error;
    
    
    xmlData = [NSPropertyListSerialization dataFromPropertyList:plist
        
                                                         format:NSPropertyListXMLFormat_v1_0
        
                                               errorDescription:&error];
    
    if(xmlData)
        
    {
        
        NSLog(@"No error creating XML data.");
        
        [xmlData writeToFile:path atomically:YES];
        
    }
    
    else
        
    {
        
        NSLog(error);
        
        [error release];
        
    }
}*/

+ (NSArray *) loadPlistArrayFromFile: (NSString *) path
{
    NSData *plistData;
    NSString *error;
    id plist;
    plistData = [NSData dataWithContentsOfFile:path];
    plist = [NSPropertyListSerialization propertyListFromData:plistData
                                             mutabilityOption:NSPropertyListImmutable
                                                       format:nil
                                             errorDescription:&error];
    
    if(!plist)
    {
        NSLog(error);
        [error release];
        return [[[NSArray alloc] init] autorelease];
    }else if(! [plist isKindOfClass: [NSArray class]]){
        NSLog(@"quickFiles.plist is not an Array");
        return [[[NSArray alloc] init] autorelease];
        
    }else{
        return (NSArray *)plist;
    }
}

- (void) loadQuickScripts
{
    if(!loadedQuickScripts){
            
        [quickScriptPopup removeAllItems];
        NSMenuItem *scriptItem = [[[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""] autorelease];
        NSImage *scptIcon = [[NSWorkspace sharedWorkspace] iconForFileType:@"scpt"];
        [scptIcon setSize:NSMakeSize(16,16)];
        [scriptItem setImage:scptIcon];
        [scriptItem setTitle:LOCALIZE([self bundle],@"Scripts")];
        [[quickScriptPopup menu] addItem:scriptItem];
        
        //[quickScriptPopup addItemWithTitle:LOCALIZE([self bundle],@"Quick...")];
        NSArray *list = [self quickScriptsList];
        [self addActionMenuItems:list toMenu:[quickScriptPopup menu]];
        /*
        for(i=0;i<[list count];i++){
            NSString *path = (NSString *)[list objectAtIndex:i];
            [[quickScriptPopup menu] addItem:[[[FileActionMenuItem alloc] initWithFilePath:path andClickPref:self] autorelease]];  
            
        }*/
        loadedQuickScripts=YES;
    }
}

- (void) showQuickScriptsPopup
{
    [self loadQuickScripts];
    [quickScriptPopup setHidden:NO];
}

- (void) hideQuickScriptsPopup
{
    
    [quickScriptPopup setHidden:YES];
}


- (NSArray *) quickFilesList
{
    return [ClickBoxPref loadPlistArrayFromFile:
        [[NSBundle bundleForClass:[self class]] pathForResource:@"quickFiles"
                                                         ofType:@"plist"]];
   
}


- (NSArray *) quickScriptsList
{
    NSString *file;
    BOOL isDir;
    NSMutableArray *marr = [[[NSMutableArray alloc] init] autorelease];
    NSArray *arrs = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    int i;
    for(i=0;i<[arrs count];i++){
        NSString *tempDir = [[[[arrs objectAtIndex:i] stringByAppendingString:LOCALIZE([self bundle],@"/Scripts")] retain] autorelease];
        //NSLog(@"looking in dir for scripts: %@",tempDir);
        isDir=NO;
        if([[NSFileManager defaultManager] fileExistsAtPath:tempDir isDirectory:&isDir] && isDir){
            
            NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]        
                enumeratorAtPath:tempDir];
            
            while (file = [enumerator nextObject]) {
                OSType hfsType = [[enumerator fileAttributes] fileHFSTypeCode];
                //NSLog(@"file has osType: %@",[[NSNumber numberWithUnsignedInt:hfsType] description]);
                if ([[file pathExtension] isEqualToString:@"scpt"] || hfsType == 'osas'){
                    [marr addObject:[NSString stringWithFormat:@"%@/%@",tempDir,file]];
                   //NSLog(@"Added script with path: %@",[NSString stringWithFormat:@"%@/%@",tempDir,file]);
                }
                    
            }
        }
    }
    return marr;
}
/*- (IBAction)loadInformationRTF:(id)sender
{   
    [[NSWorkspace sharedWorkspace] openFile:[[self bundle] pathForResource:@"Information" ofType:@"rtf"]];
}*/
- (IBAction)loadReadmeRTF:(id)sender
{
    
    [[NSWorkspace sharedWorkspace] openFile:[[self bundle] pathForResource:@"Readme" ofType:@"rtf"]];
}


- (IBAction)openExposePrefPane: (id) sender
{
    [[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/Expose.prefPane"];
}
- (IBAction)checkVersionUpdate: (id) sender
{
    
}
- (CornerClickSettings *) appSettings
{
    return [CornerClickSettings sharedSettings];
}
+ (void) initialize
{
    [CornerClickSettings sharedSettingsFromUserPreferences];
    NSLog(@"initialized ClickBoxPref");
}

- (void)setAppSettings: (CornerClickSettings *) settings
{
    [settings retain];
    [appSettings release];
    appSettings=settings;
}

- (NSMutableDictionary *) mySettings
{
    return mySettings;
}

- (void)setMySettings: (NSMutableDictionary *) settings
{
    [settings retain];
    [mySettings release];
    mySettings=settings;
}

static NSString *UI_VIEW_CHANGE_CTX=@"UI_VIEW_CHANGE_CTX";

- (void) observeValueForKeyPath: (NSString *)path ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object==[self appSettings] && context == UI_VIEW_CHANGE_CTX){
            [self saveChanges];            
    }else if(object==currentAction){
        
        [self saveChanges];
        [actionTable reloadData];
    }
}
- (void) didSelect
{
    
    [[self appSettings] addObserver:self 
                         forKeyPath:@"toolTipEnabled"
                            options:NSKeyValueObservingOptionNew
                            context:UI_VIEW_CHANGE_CTX];
    [[self appSettings] addObserver:self 
                         forKeyPath:@"toolTipDelayed"
                            options:NSKeyValueObservingOptionNew
                            context:UI_VIEW_CHANGE_CTX];
    [[self appSettings] addObserver:self 
                  forKeyPath:@"textSize"
                     options:NSKeyValueObservingOptionNew
                     context:UI_VIEW_CHANGE_CTX];
    [[self appSettings] addObserver:self 
                         forKeyPath:@"iconSize"
                            options:NSKeyValueObservingOptionNew
                            context:UI_VIEW_CHANGE_CTX];
    

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

    [[NSNotificationCenter defaultCenter]
        addObserver: self
           selector: @selector(screenChangedNotification:)
               name: @"NSApplicationDidChangeScreenParametersNotification"
             object: nil];
    


    [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                        selector: @selector(helperAppIsRunning:)
                                                            name: @"CornerClickPingBackNotification"
                                                          object: nil
                                              suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
    
    chosenCorner=0;
    chosenScreen=0;
    active=NO;
    [appLaunchIndicator setStyle: NSProgressIndicatorSpinningStyle];
    
//    [showTooltipCheckBox setState:[appSettings toolTipEnabled]?1:0];
 //   [delayTooltipCheckBox setState:[appSettings toolTipDelayed]?1:0];
 //   [delayTooltipCheckBox setEnabled: [appSettings toolTipEnabled]];
    [appEnabledCheckBox setState: [appSettings appEnabled]];
    [highlightColorWell setEnabled:YES];
	if([appSettings highlightColor]!=nil){
		[highlightColorWell setColor:[appSettings highlightColor]];
	}else{
		
		[highlightColorWell setColor:[NSColor blackColor]];
	}
	[highlightPopup selectItemAtIndex:[appSettings colorOption]];
	[highlightColorWell setHidden:[appSettings colorOption]!=2];
	//[bubbleColorWellA setColor:[appSettings bubbleColorA]];
    //[bubbleColorWellA setEnabled: [appSettings toolTipEnabled]];
	//[bubbleColorWellB setColor:[appSettings bubbleColorB]];
    //[bubbleColorWellB setEnabled: [appSettings toolTipEnabled]];

	//[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
	
    [[NSColorPanel sharedColorPanel] setTarget:nil];
    [self checkScreens];
    

    [self refreshWithCornerSettings];
    [self refreshWithSettings:nil];

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
    awaitingDisabledHelperNotification=NO;
    reloadHelperOnHelperDeactivation=NO;
    [self checkIfHelperAppRunning];
}

- (void) didUnselect
{
    
    [highlightColorWell setEnabled:NO];
    [[NSColorPanel sharedColorPanel] setTarget:nil];
    [self saveChanges];
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


- (void) checkScreens
{
    int i;
    NSArray *s;

    if(allScreens !=nil)
        [allScreens release];
    s = [NSScreen screens];
    allScreens = [[NSMutableArray arrayWithCapacity:[s count]] retain];
    if(screenNums !=nil)
        [screenNums release];
    screenNums = [[NSMutableDictionary dictionaryWithCapacity:[s count]] retain];

    for(i=0;i<[s count];i++){
        [screenNums setObject:[s objectAtIndex:i] forKey:[[[s objectAtIndex:i] deviceDescription] objectForKey:@"NSScreenNumber"]];
        [allScreens addObject:[[[s objectAtIndex:i] deviceDescription] objectForKey:@"NSScreenNumber"]];
    }
    [screenIDButton removeAllItems];
    [screenIDButton addItemWithTitle:LOCALIZE([self bundle],@"Main Screen")];
    if([allScreens count]>1){
        [screenCountTextField setStringValue:[NSString stringWithFormat:LOCALIZE([self bundle],@"%d screens"), [allScreens count]]];
        [screenCountTextField setHidden:NO];
        [screenIDButton setEnabled:YES];
        [cycleScreensButton setEnabled:YES];
        for(i=1;i<[allScreens count]; i++){
            //NSLog(@"add title for screen %d",(i+1));
            [screenIDButton addItemWithTitle:[NSString stringWithFormat:LOCALIZE([self bundle],@"Screen #%d"),(i+1)]];
        }
        if(chosenScreen >= [allScreens count] || chosenScreen < 0){
            chosenScreen=0;
            [screenIDButton selectItemAtIndex: 0];
        }
    }else{
        [screenCountTextField setHidden:YES];
        [screenIDButton setEnabled:NO];
        [cycleScreensButton setEnabled:NO];
        chosenScreen=0;
    }
    [screenIDButton selectItemAtIndex: chosenScreen];
    i=chosenScreen;
    chosenScreen=-1;
    [self doChooseScreen:i withPopupWindow:NO];
}

- (void) checkIfHelperAppRunning
{
    //NSLog(@"send ping to app");
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName: @"CornerClickPingAppNotification"
                                                                   object: nil
                                                                 userInfo: [NSDictionary dictionaryWithObjects:
                                                                     [NSArray arrayWithObjects: [NSNumber numberWithInt: CC_APP_VERSION], [NSNumber numberWithInt: CC_PATCH_VERSION], nil]
                                                                                        forKeys:
                                                                     [NSArray arrayWithObjects: @"CornerClickAppVersion", @"CornerClickPatchVersion",nil]]
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
- (void) alertSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    switch(returnCode){
        case NSAlertDefaultReturn:
            //DEBUG(@"disabling and enabling");
            //reloadHelperOnHelperDeactivation=YES;
            //[self deactivateHelper];
            break;
        case NSAlertAlternateReturn:
            DEBUG(@"Open readme file");
            [self loadReadmeRTF:self];
            break;
        case NSAlertErrorReturn:
            DEBUG(@"Error running alert sheet");
            break;
        default:
            DEBUG(@"Unknown returnCode in alertSheetDidEnd");
    }
}

- (void) helperAppIsRunning: (NSNotification *) notice
{
    NSNumber *num = [[notice userInfo] objectForKey:@"CornerClickAppVersion"];
    //NSNumber *pat = [[notice userInfo] objectForKey:@"CornerClickPatchVersion"];
    int vers = [num intValue];
    //int patch = (pat==nil?0:[pat intValue]);
    int min= vers%1000;
    int maj = (int)(((vers-min)/1000));
    
    int cmin= ((int) CornerClickVersionNumber ) % 1000;
    int cmaj =(int)(((CornerClickVersionNumber - cmin)/1000));

    active=YES;
    if(vers != CornerClickVersionNumber ){
        reloadHelperOnHelperDeactivation=YES;
        [self deactivateHelper];
        NSBeginAlertSheet(LOCALIZE([self bundle],@"New CornerClick Version"),
                          LOCALIZE([self bundle],@"OK"),
                          LOCALIZE([self bundle],@"Open Readme File"),
                          nil, [NSApp mainWindow], self, @selector(alertSheetDidEnd:returnCode:contextInfo:), NULL, NULL,
                          LOCALIZE([self bundle],@"An old version of CornerClick was active (version %d.%d). It will be deactivated and version %d.%d will be activated."),maj,min,cmaj,cmin);

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
    [appSettings setAppEnabled:active];
    //[appPrefs setObject:[NSNumber numberWithInt: active?1:0] forKey:@"appEnabled"];
    awaitingDisabledHelperNotification=NO;
    [appEnabledCheckBox setEnabled:YES];
    if(reloadHelperOnHelperDeactivation){
        reloadHelperOnHelperDeactivation=NO;
        [self activateHelper];
    }
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
    [appLaunchIndicator stopAnimation:self];
    [appLaunchErrorLabel setStringValue: @""];

    NSBeginAlertSheet(LOCALIZE([self bundle],@"Deactivate Failed"),
                      LOCALIZE([self bundle],@"OK"),
                      nil,nil, [NSApp mainWindow], self, NULL, NULL, NULL,
                      LOCALIZE([self bundle],@"The CornerClick helper application could not be deactivated."));
    //[appLaunchErrorLabel setStringValue: @"Couldn't quit helper application"];
    [appEnabledCheckBox setState:1];
    [appEnabledCheckBox setNeedsDisplay: YES];
    active=YES;
    [appSettings setAppEnabled:active];
    //[appPrefs setObject:[NSNumber numberWithInt: active?1:0] forKey:@"appEnabled"];
    awaitingDisabledHelperNotification=NO;
    [appEnabledCheckBox setEnabled:YES];
}

- (void) deactivateHelper
{
    NSString *apppath;
    apppath = [[self bundle] pathForResource:@"CornerClickBG" ofType:@"app"];

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

    [appLaunchErrorLabel setStringValue: LOCALIZE([self bundle],@"Trying to deactivate")];
    awaitingDisabledHelperNotification=YES;
    [appEnabledCheckBox setState:0];
    [appEnabledCheckBox setEnabled:NO];
    
}

- (void) activateHelper
{
    BOOL success;
    NSString *apppath;
    apppath = [[self bundle] pathForResource:@"CornerClickBG" ofType:@"app"];
    //[appLaunchErrorLabel setStringValue: @""];
    [appLaunchIndicator startAnimation:self];
    [appLaunchErrorLabel setStringValue: LOCALIZE([self bundle],@"Trying to activate")];
    [appEnabledCheckBox setEnabled:NO];
    [self saveChanges];
    if(apppath ==nil)
        success=NO;
    else
        success = [[NSWorkspace sharedWorkspace] launchApplication: apppath];
    if(!success){
        [appLaunchIndicator stopAnimation:self];
        [appEnabledCheckBox setState:0];
        [appLaunchErrorLabel setStringValue: @""];
        NSBeginAlertSheet(LOCALIZE([self bundle],@"Activate Failed"),
                          LOCALIZE([self bundle],@"OK"),
                          nil,nil, [NSApp mainWindow], self, NULL, NULL, NULL,
                          LOCALIZE([self bundle],@"The CornerClick helper application could not be launched."));
        active=NO;
    }else{
        [self setAutoLaunch:YES forApp:apppath];
        [appLaunchErrorLabel setStringValue: @""];
        [appLaunchIndicator stopAnimation:self];
        [appEnabledCheckBox setState:1];
        active=YES;
    }
    [appEnabledCheckBox setEnabled:YES];
    
}

- (IBAction)tableViewAction:(id)sender
{
    //NSLog(@"table view action: %@",sender);
}

- (IBAction)appEnable:(id)sender
{
    //appLaunchIndicator
    if(active && [sender state]==0){
        [self deactivateHelper];
    }else if(active && awaitingDisabledHelperNotification){
        [sender setState:0];
        return;
    }else if(!active && [sender state]){
        [self activateHelper];
    }
    //[appPrefs setObject:[NSNumber numberWithInt: active?1:0] forKey:@"appEnabled"];
}

- (void) refreshWithCornerSettings
{

    [enabledCheckBox setState:[appSettings cornerEnabled:chosenCorner forScreen:[allScreens objectAtIndex:chosenScreen]]];
    //[appEnabledCheckBox setState:[[appPrefs objectForKey:@"appEnabled"] intValue]];
}

- (void) refreshWithSettings:(ClickAction *)theAction
{
    int flags=0;    //NSLog(@"retain count of settings: %d",[settings retainCount]);
    if(theAction!=nil){
        flags = [theAction modifiers];
        
        [removeActionButton setEnabled:YES];
        [optionKeyCheckBox setEnabled:YES];
        [shiftKeyCheckBox setEnabled:YES];
        [controlKeyCheckBox setEnabled:YES];
        [commandKeyCheckBox setEnabled:YES];
        [functionKeyCheckBox setEnabled:YES];
        //NSLog(@"flags (%d) & OPTION_MASK (%d) : %d",flags,OPTION_MASK,(flags & OPTION_MASK));

        [optionKeyCheckBox setState: ((flags & OPTION_MASK) > 0 ? NSOnState: NSOffState)];
        [shiftKeyCheckBox setState: ((flags & SHIFT_MASK) > 0 ? NSOnState: NSOffState)];
        [controlKeyCheckBox setState: ((flags & CONTROL_MASK) > 0 ? NSOnState: NSOffState)];
        [commandKeyCheckBox setState: ((flags & COMMAND_MASK) > 0 ? NSOnState: NSOffState)];
        [functionKeyCheckBox setState: ((flags & FN_MASK) > 0 ? NSOnState: NSOffState)];
        
        [actionChoicePopupButton setEnabled:YES];
        [triggerChoicePopupButton setEnabled:YES];
        [actionChoicePopupButton selectItemAtIndex: [theAction type]];
        [triggerChoicePopupButton selectItemAtIndex: [theAction trigger]]; //TODO handle other types of triggers
        [hoverTriggerDelayedCheckbox setEnabled:[theAction trigger]==TRIGGER_HOVER];
        [hoverTriggerDelayedCheckbox setHidden:[theAction trigger]!=TRIGGER_HOVER];
        [hoverTriggerDelayedCheckbox setState: ([theAction trigger]==TRIGGER_HOVER && [theAction hoverTriggerDelayed]) ? NSOnState:NSOffState];

        
        NSString *str = [theAction string];
        NSString *label = [theAction labelSetting];
        switch([theAction type]){
            case ACT_FILE:
                if(str!=nil){
                    if([str isEqualToString:[[self bundle] bundlePath]]){
                        [chosenFileTitle setStringValue: LOCALIZE([self bundle],@"CornerClick Preferences")];
                    }else if([str hasSuffix:@".app"]){
                        [chosenFileTitle setStringValue: [[str lastPathComponent] stringByDeletingPathExtension]];
                    }else{
                        [chosenFileTitle setStringValue: [str lastPathComponent]];
                    }
                    [chosenFileLabel setStringValue: str];
                    [fileIconImageView setImage: [[NSWorkspace sharedWorkspace] iconForFile: str]];
                }else{
                    [chosenFileTitle setStringValue: LOCALIZE([self bundle],@"no file chosen")];
                    [chosenFileLabel setStringValue: @""];
                    [fileIconImageView setImage: nil];
                }
                DEBUG(@"set choose button hidden: no");
                [fileChooseButton setHidden:NO];
                [quickFilePopup setHidden:NO];
                [actionChoicePopupButton setNextKeyView: quickFilePopup];
                [fileChooseButton setNextKeyView: screenIDButton];
                [self hideQuickScriptsPopup];
                 
                break;
            case ACT_URL:
                if(str!=nil){
                    [urlTextField setStringValue:str];
                }else{
                    [urlTextField setStringValue:@"http://"];
                }
                if(label!=nil){
                    [urlLabelField setStringValue:label];
                }else{
                    [urlLabelField setStringValue:@""];
                }
                [fileChooseButton setHidden:YES];
                [quickFilePopup setHidden:YES];
                [actionChoicePopupButton setNextKeyView: urlTextField];
                [self hideQuickScriptsPopup];
                break;
            case ACT_SCPT:
                if(str!=nil){
                    [chosenScriptLabel setStringValue: str];
                    [scriptIconImageView setImage: [[NSWorkspace sharedWorkspace] iconForFile: str]];
                }else{
                    [chosenScriptLabel setStringValue: LOCALIZE([self bundle],@"no script chosen")];
                    [scriptIconImageView setImage: nil];
                }
                if(label!=nil){
                    [scriptLabelField setStringValue: label];
                }else{
                    [scriptLabelField setStringValue: @""];
                }
                [fileChooseButton setHidden:NO];
                [quickFilePopup setHidden:YES];
                [actionChoicePopupButton setNextKeyView: quickScriptPopup];
                [fileChooseButton setNextKeyView: urlLabelField];
                [self showQuickScriptsPopup];
                break;
            default:
                
                [fileChooseButton setHidden:YES];
                [quickFilePopup setHidden:YES];
                [actionChoicePopupButton setNextKeyView: screenIDButton];
                [self hideQuickScriptsPopup];
                break;
        }

        [self setSubFrameForActionType: [theAction type]];
        
    }else{
        [fileChooseButton setHidden:YES];
        [quickFilePopup setHidden:YES];
        [self hideQuickScriptsPopup];
        [removeActionButton setEnabled:NO];
        [optionKeyCheckBox setEnabled:NO];
        [shiftKeyCheckBox setEnabled:NO];
        [controlKeyCheckBox setEnabled:NO];
        [commandKeyCheckBox setEnabled:NO];
        [functionKeyCheckBox setEnabled:NO];
        [optionKeyCheckBox setState:NSOffState];
        [shiftKeyCheckBox setState:NSOffState];
        [controlKeyCheckBox setState:NSOffState];
        [commandKeyCheckBox setState:NSOffState];
        [functionKeyCheckBox setState:NSOffState];
        [actionChoicePopupButton setEnabled:NO];
        [triggerChoicePopupButton setEnabled:NO];
        [hoverTriggerDelayedCheckbox setEnabled:NO];
        [hoverTriggerDelayedCheckbox setHidden:YES];
        [hoverTriggerDelayedCheckbox setState:NSOffState];
        
        [self setSubFrameForActionType: -1];
        [chosenFileLabel setStringValue:@""];
        [chosenFileTitle setStringValue:@""];
        [fileIconImageView setImage:nil];
        [urlTextField setStringValue:@""];
        [urlLabelField setStringValue:@""];
        [chosenScriptLabel setStringValue:@""];
        [scriptLabelField setStringValue:@""];
        [scriptIconImageView setImage:nil];
    }
}

- (void)openSheetDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    NSString *thefile;
    //NSLog(@"Sheet finished");

    [sheet orderOut: self];
    if(returnCode==NSOKButton){
        thefile = [[[sheet filenames] objectAtIndex:0] retain];
        [self setSelectedActionPath: thefile];
    }
}
- (void) setSelectedActionPath: (NSString *) thefile
{
    [self setSelectedActionPath:thefile resettingScriptLabel:NO];
}

- (void) setSelectedActionPath: (NSString *) thefile resettingScriptLabel:(BOOL) doReset
{
    
    switch([currentAction type]){
        case ACT_FILE:
            [currentAction setString:thefile];
            [currentAction setLabelSetting:nil];

            if([thefile isEqualToString:[[self bundle] bundlePath]]){
                [chosenFileTitle setStringValue: LOCALIZE([self bundle],@"CornerClick Preferences")];
                [currentAction setLabelSetting: LOCALIZE([self bundle],@"CornerClick Preferences")];
            }else if([thefile hasSuffix:@".app"]){
                [chosenFileTitle setStringValue: [[thefile lastPathComponent] stringByDeletingPathExtension]];
            }else{
                [chosenFileTitle setStringValue: [thefile lastPathComponent]];
            }
                [chosenFileLabel setStringValue: thefile];

            [fileIconImageView setImage: [[NSWorkspace sharedWorkspace] iconForFile: thefile]];
            break;
        case ACT_SCPT:
            [currentAction setString:thefile];
            [currentAction setLabelSetting:nil];
            [chosenScriptLabel setStringValue: thefile];
            [scriptIconImageView setImage: [[NSWorkspace sharedWorkspace] iconForFile: thefile]];
            if(doReset || [[scriptLabelField stringValue] length] == 0){
                [scriptLabelField setStringValue: [[thefile lastPathComponent] stringByDeletingPathExtension]];
            }
            [scriptLabelField selectText:self];
            break;

    }
    [self saveChanges];
    [actionTable reloadData];
    [thefile release];

}

- (void) urlEntered: (id) sender
{
    switch([currentAction type]){
        case ACT_URL:
            [currentAction setString:[urlTextField stringValue]];
            if([[urlLabelField stringValue] length] > 0){
                [currentAction setLabelSetting:[urlLabelField stringValue]];
            }else{
                [currentAction setLabelSetting:nil];
            }
            break;
        case ACT_SCPT:

            if([[scriptLabelField stringValue] length] > 0){
                [currentAction setLabelSetting:[scriptLabelField stringValue]];
            }else{
                [currentAction setLabelSetting:nil];
            }
            break;
    }
    
    //[self notifyAppOfPreferences: [appSettings asDictionary]];
    [self saveChanges];
    [actionTable reloadData];
}


- (void) saveChangesFromNotification:(NSNotification*)aNotification
{
    [self saveChanges];
}

- (void) screenChangedNotification: (NSNotification *)notice
{
    [self checkScreens];
}

- (void) saveChanges
{

    [CornerClickSupport savePreferences:[CornerClickSettings sharedSettings]];
    [self notifyAppOfPreferences: [appSettings asDictionary]];
}

- (void) notifyAppOfPreferences: (NSDictionary *) prefs
{
    //notify the app if it's running
    [[NSDistributedNotificationCenter defaultCenter]
     postNotificationName: @"CornerClickLoadPrefsNotification" object: nil
                 userInfo:prefs
       deliverImmediately:YES];
}

+ (NSString *)ordinalForNumber: (int) which
{
    switch(which){
        case 1: return @"A";
        case 2: return @"B";
        case 3: return @"C";
        case 4: return @"D";
        case 5: return @"E";
        case 6: return @"F";
        default:
            return @"ZZZZ";
    }
}

- (IBAction)actionChosen:(id)sender
{

    //NSLog(@"Choose action: %d",[sender indexOfSelectedItem]);
    int oldval = [currentAction type];
    if(oldval==[sender indexOfSelectedItem]){
        return;
    }
    [currentAction setType: [sender indexOfSelectedItem] ];
    [currentAction setString:nil];
    [currentAction setLabelSetting:nil];
    //DEBUG(@"before refresh settings");
    [self refreshWithSettings:currentAction];
    //DEBUG(@"after refresh settings");
    //[self setSubFrameForActionType: [sender indexOfSelectedItem]];
    [self saveChanges];
    //DEBUG(@"reload data");
    [actionTable reloadData];
}

- (void) syncCurrentAction
{
    /*[appSettings replaceActionAtIndex: chosenAction
                           withAction:currentAction
                            forScreen:[allScreens objectAtIndex:chosenScreen]
                            andCorner:chosenCorner];
*/
}

- (void) setSubFrameForActionType: (int) type
{
    float diffh=0,diffy=0;
    NSArray *sub = [actionView subviews];
    NSRect oldr = [[NSApp mainWindow] frame];
    NSRect oldt = [myTabView frame];
    //NSLog(@"old window: %@, oldTabView : %@, old actionView : %@",NSStringFromRect(oldr),NSStringFromRect(oldt),NSStringFromRect([actionView frame]));
    diffh-=[actionView frame].size.height;
    diffy+=[actionView frame].size.height;
    int i;
    for(i=0;i<[sub count];i++){
        [[sub objectAtIndex:i] retain];
        [[sub objectAtIndex:i] removeFromSuperview];
    }
    //NSRect frame = [actionView frame];
    switch(type){
        case ACT_SCPT:
            [self showQuickScriptsPopup];
            [actionView addSubview: chooseScriptView];
            diffh+=[chooseScriptView frame].size.height;
            diffy-=[chooseScriptView frame].size.height;
            //[actionView setFrameSize: [chooseScriptView frame].size];
            [chooseScriptView setFrameSize:[actionView frame].size];
            //[actionView setFrameOrigin: NSMakePoint([actionView frame].origin.x,[actionView frame].origin.y+diffy)];
            
            break;
        case ACT_FILE: //open file
            [actionView addSubview: chooseFileView];
            diffh+=[chooseFileView frame].size.height;
            diffy-=[chooseFileView frame].size.height;
            //[actionView setFrameSize: [chooseFileView frame].size];
            [chooseFileView setFrameSize:[actionView frame].size];
            //[actionView setFrameOrigin: NSMakePoint([actionView frame].origin.x,[actionView frame].origin.y+diffy)];
            break;
        case ACT_URL:
            [actionView addSubview: chooseURLView];
            diffh+=[chooseURLView frame].size.height;
            diffy-=[chooseURLView frame].size.height;
            //[actionView setFrameSize: [chooseURLView frame].size];
            [chooseURLView setFrameSize:[actionView frame].size];
            //[actionView setFrameOrigin: NSMakePoint([actionView frame].origin.x,[actionView frame].origin.y+diffy)];
            break;
        case ACT_EALL:
        case ACT_EAPP:
        case ACT_EDES:
            [actionView addSubview: exposeNoteView];
            break;
        default:
            //[actionView setFrameSize: NSMakeSize([actionView frame].size.width,0)];
            break;
    }
    [actionView setNeedsDisplay:YES];
    oldt.size.height+=diffh;
    //[myTabView setFrameSize: oldt.size];
    oldr.origin.y+=diffy;
    oldr.size.height+=diffh;
    //[[actionView window] setFrame:oldr display:YES animate:YES];
    //NSLog(@"new window: %@, oldTabView : %@, old actionView : %@", NSStringFromRect(oldr),NSStringFromRect(oldt),NSStringFromRect([actionView frame]));
}
- (void)doChooseCorner:(int) corner
{
    //NSLog(@"Choose corner: %d",[sender indexOfSelectedItem]);
    chosenCorner=corner;
    [cornerMatrix selectCellWithTag:corner];
    
    [self refreshWithCornerSettings];
    [self refreshWithSettings:nil];
    [actionTable deselectAll:self];
    [actionTable reloadData];
}

- (IBAction)tlCornerClick:(id)sender
{
    [self doChooseCorner:0];
}
- (IBAction)trCornerClick:(id)sender
{

    [self doChooseCorner:1];
}
- (IBAction)blCornerClick:(id)sender
{

    [self doChooseCorner:2];
}
- (IBAction)brCornerClick:(id)sender
{

    [self doChooseCorner:3];
}

- (IBAction)cornerChosen:(id)sender
{
    //NSLog(@"Choose corner: %d",[sender indexOfSelectedItem]);
    [self doChooseCorner:[sender indexOfSelectedItem]];
}


- (ClickAction *) currentAction
{
    return currentAction;
}

- (IBAction)enableChosen:(id)sender
{
    [appSettings setCorner:chosenCorner
                   enabled:[sender state]==NSOnState
                 forScreen:[allScreens objectAtIndex:chosenScreen]];
    [self refreshWithCornerSettings];
    [self refreshWithSettings:nil];
    [actionTable deselectRow:[actionTable selectedRow]];
    [actionTable setNeedsDisplay:YES];
    [self saveChanges];
    //[self notifyAppOfPreferences: [appSettings asDictionary]];

}

- (IBAction)fileChooseClicked:(id)sender
{
    //NSLog(@"Choose file button");
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    NSString *dir, *file;
    NSArray *types=nil;
    dir=file=nil;
    [openPanel setAllowsMultipleSelection: NO];
    if([currentAction type] == ACT_FILE){
        [openPanel setCanChooseDirectories: YES];
        [openPanel setCanChooseFiles: YES];
        NSLog(@"choose file chosen");        
    }else if([currentAction type] == ACT_SCPT){
        [openPanel setCanChooseDirectories: NO];
        [openPanel setCanChooseFiles: YES];
        types=[NSArray arrayWithObject:@"scpt"];
        NSLog(@"choose script chosen");
        if([currentAction string]==nil){
            
            NSArray *arrs = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            NSString *scptdir = (NSString *)[arrs objectAtIndex:0] ;
            dir = scptdir ;
            file = LOCALIZE([self bundle], @"/Scripts");
        }
    }
    if([currentAction string]!=nil){
        
        dir = [[currentAction string] stringByDeletingLastPathComponent];
        file = [[currentAction string] lastPathComponent];
    }
    [openPanel beginSheetForDirectory: dir 
                                 file: file
                                types: types
                       modalForWindow:[NSApp mainWindow]
                        modalDelegate:self
                       didEndSelector:@selector(openSheetDidEnd:returnCode:contextInfo:) 
                          contextInfo: nil];
    //int result = [openPanel runModalForDirectory: nil file: nil types: nil];
    //[self openSheetDidEnd:openPanel returnCode: result contextInfo:nil];
}


- (void) doChooseScreen: (int) which withPopupWindow: (BOOL) popup
{
    
    if(chosenScreen==0){
        eerepeated++;
    }else{
        // eerepeated=0;
    }
    if(chosenScreen==which)
        return;
    chosenScreen=which;
    if(chosenScreen >=[allScreens count]){
        DEBUG(@"bad screen selection");
        return;
    }

    if(popup)
        [self displayScreenIdentification];
    //TODO update controls for screen data
    [self doChooseCorner:0];
    
}

- (IBAction)screenIDClicked:(id)sender
{
    [self doChooseScreen:[sender indexOfSelectedItem] withPopupWindow:YES];

}


- (IBAction)chooseNextScreen:(id)sender
{
    if(chosenScreen+1 >= [allScreens count]){
        [screenIDButton selectItemAtIndex:0];
        [self doChooseScreen:0 withPopupWindow:YES];
    }else{
        [screenIDButton selectItemAtIndex:chosenScreen+1];
        [self doChooseScreen:chosenScreen+1 withPopupWindow:YES];
    }
}

- (void)displayPopupAlert: (NSString *)grayString withHilite: (BOOL) hilite fadeFrom:(NSColor *) colorA to:(NSColor *) colorB
				 onScreen: (NSScreen *)theScreen
{
    NSRect pref,theRect;
    if(screenIdWindow==nil){
        screenIdView = [[GrayView alloc] initWithFrame: NSMakeRect(0,0,10,10)
                                             andString:  grayString
                                              andImage: nil
                                              fadeFrom: colorA
                                                fadeTo: colorB
                                            cornerSize: -1
                                           pointCorner: -1];
		
        [screenIdView setDrawHilite:hilite];
        [screenIdView setInsetSize: -5];
        [screenIdView setDrawFont:[NSFont boldSystemFontOfSize:96] color:[NSColor whiteColor]];
        pref = [screenIdView preferredFrame];
        [screenIdView setFrame:pref];
        screenIdWindow = [[NSWindow alloc] initWithContentRect:pref 
													 styleMask:NSBorderlessWindowMask 
													   backing:NSBackingStoreBuffered
														 defer:YES
														screen:theScreen ];
        [screenIdWindow setLevel:NSStatusWindowLevel];
        [screenIdWindow setAlphaValue:0.0];
        [screenIdWindow setHasShadow: NO];
        [screenIdWindow setOpaque:NO];
		
        [screenIdWindow setContentView: screenIdView];
    }else{
        [screenIdWindow setAlphaValue:0];
        [screenIdWindow orderBack:self];
        [screenIdView setDrawString: grayString ];
		[screenIdView setFadeFromColor:colorA];
		[screenIdView setFadeToColor:colorB];
    }
    pref = [screenIdView preferredFrame];
    [screenIdView setFrame:pref];
	
    theRect = NSIntegralRect(NSMakeRect([theScreen frame].origin.x + (([theScreen frame].size.width/2) - (pref.size.width/2)),
                                        [theScreen frame].origin.y + (([theScreen frame].size.height/2) - (pref.size.height/2)),
                                        pref.size.width,
                                        pref.size.height));
	
    [screenIdWindow setFrame: theRect display:YES];
    [screenIdWindow setAlphaValue:1.0];
    //NSLog(@"at rect: %@",NSStringFromRect(theRect));
    [screenIdWindow orderFront:self];
	
    //make timer to fade out.
    if( delayTimer!=nil){
        [delayTimer invalidate];
        [delayTimer release];
        delayTimer=nil;
    }
    NSInvocation *nsinv = [NSInvocation invocationWithMethodSignature: [self methodSignatureForSelector:@selector(fadeScreenIdentification)]];
    [nsinv setSelector:@selector(fadeScreenIdentification)];
    [nsinv setTarget:self];
	
    delayTimer = [[NSTimer scheduledTimerWithTimeInterval:2 invocation:nsinv repeats:NO] retain];
    
}

- (void) displayColorExample
{
	NSLog(@"display color example");
	[self displayPopupAlert:LOCALIZE([self bundle], @"Color Test")
				 withHilite:YES
				   fadeFrom:[appSettings bubbleColorA]
						 to:[appSettings bubbleColorB]
				   onScreen:[NSScreen mainScreen]];
}

- (void)displayScreenIdentification
{
    NSScreen *theScreen=[screenNums objectForKey:[allScreens objectAtIndex:chosenScreen]];
    NSString *grayString;

        if(chosenScreen==0)
                grayString=LOCALIZE([self bundle],@"Main Screen");
            else
                grayString=[NSString stringWithFormat: LOCALIZE([self bundle],@"Screen #%d") , chosenScreen+1];
            
			if(eerepeated>4){
				grayString=[NSString stringWithString:@"Main Screen Turn On!"];
			}
			[self displayPopupAlert:grayString
						 withHilite:YES 
						   fadeFrom: [NSColor colorWithCalibratedRed:0 green:0 blue:1 alpha:0.25]
								 to: [NSColor colorWithCalibratedRed:0 green:0 blue:0.5 alpha:1]
						   onScreen:theScreen];                                         
}

- (void) fadeScreenIdentification
{
    if( delayTimer!=nil){
        [delayTimer invalidate];
        [delayTimer release];
        delayTimer=nil;
    }
    [screenIdWindow setAlphaValue:0.0];
    [screenIdWindow orderBack:self];
}



- (IBAction)triggerChosen:(id)sender
{
    //nothing to do yet
    //[self notifyAppOfPreferences: [appSettings asDictionary]];
    //[actionTable reloadData];
	NSLog(@"settings trigger for item to %d ",[triggerChoicePopupButton indexOfSelectedItem]);
	[currentAction setTrigger:[triggerChoicePopupButton indexOfSelectedItem]];
	
    [self refreshWithSettings:currentAction];
    [self saveChanges];
    [actionTable reloadData];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if(allScreens==nil || appSettings ==nil)
        return 0;
    //NSLog(@"allScreens: %@",allScreens);
    //NSLog(@"appSettings: %@",appSettings);
    int count= [appSettings countActionsForScreen: [allScreens objectAtIndex:chosenScreen] andCorner:chosenCorner];
    //NSLog(@"%d rows in table",count);
    return count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    int type,modifiers, trigger;
    NSString *theFile;
    ClickAction *theAction;
    theAction = [appSettings actionAtIndex:rowIndex
                                 forScreen:[allScreens objectAtIndex:chosenScreen]
                                 andCorner:chosenCorner];

    type = [theAction type];
    modifiers = [theAction modifiers];
	trigger = [theAction trigger];
    //NSLog(@"objectValueForTableColumn called: currentAcctions : %@",currentActions);
    if([[aTableColumn identifier] isEqualToString: @"icon"]){
        NSImage *tblIcon;
        switch(type){
            case ACT_SCPT:
            case ACT_FILE:
                if([theAction string]!=nil){
                    tblIcon= [[NSWorkspace sharedWorkspace] iconForFile:[theAction string]];
                    [tblIcon setScalesWhenResized:YES];
                    [tblIcon setSize:NSMakeSize(16,16)];
                    return tblIcon;
                }
                    
                else
                    return nil;
                break;
            case ACT_URL: 
                tblIcon=  [[[NSImage alloc] initWithContentsOfFile: [[self bundle] pathForResource:@"BookmarkPreferences" ofType:@"tiff"]] autorelease];
                [tblIcon setScalesWhenResized:YES];
                [tblIcon setSize:NSMakeSize(16,16)];
                return tblIcon;
            case ACT_EALL:
            case ACT_EAPP:
            case ACT_EDES:
                return [NSImage imageNamed:@"WindowVous" ];

			default: return nil;
        }
    }
    else if([[aTableColumn identifier] isEqualToString: @"desc"]){
        switch(type){
            case ACT_SCPT:
            case ACT_FILE:
                if([theAction labelSetting] !=nil)
                    return [theAction labelSetting];
                return [theAction label];
            case ACT_HIDE: return LOCALIZE([self bundle],@"Hide Current Application");
            case ACT_HIDO: return LOCALIZE([self bundle],@"Hide Other Applications");
            case ACT_URL:
                if([theAction labelSetting] !=nil){
                    theFile= [theAction labelSetting];
                }else if([theAction string] !=nil){
                    theFile= [theAction string];
                }else{
                    theFile=@"";
                }
                return [NSString stringWithFormat:LOCALIZE([self bundle],@"Open URL %@"),theFile];
            case ACT_EALL: return [NSString stringWithFormat:@"%@ - %@",
                LOCALIZE([self bundle],@"Expose"),
                LOCALIZE([self bundle],@"All Windows")]
                ;
            case ACT_EAPP: return [NSString stringWithFormat:@"%@ - %@",
                LOCALIZE([self bundle],@"Expose"),
                LOCALIZE([self bundle],@"Application Windows")]
                ;
            case ACT_EDES: return [NSString stringWithFormat:@"%@ - %@",
                LOCALIZE([self bundle],@"Expose"),
                LOCALIZE([self bundle],@"Desktop")]
                ;
            default: return @"???";
        }
    }else if([[aTableColumn identifier] isEqualToString: @"modifiers"]){
        theFile = [CornerClickSupport labelForClickAction:theAction localBundle:[self bundle]];
        return theFile;
        
    }
    return nil;
}


- (void)tableSelectionChanged:(NSNotification *) notice
{
    if([notice object]==actionTable){
        chosenAction = [actionTable selectedRow];
        if([actionTable selectedRow]>=0){
            ClickAction *newAction=[appSettings actionAtIndex: chosenAction
                                           forScreen:[allScreens objectAtIndex:chosenScreen]
                                           andCorner:chosenCorner];
            if(newAction!=currentAction){
                
                if(nil!=currentAction){
                    [currentAction removeObserver:self
                                       forKeyPath:@"hoverTriggerDelayed"];
                }
                [newAction addObserver:self
                            forKeyPath:@"hoverTriggerDelayed"
                               options:NSKeyValueObservingOptionNew
                               context:nil];
                currentAction=newAction;
                [self refreshWithSettings:currentAction];                
            }
        }else{
            if(nil!=currentAction){
                [currentAction removeObserver:self
                                   forKeyPath:@"hoverTriggerDelayed"];
            }
            currentAction=nil;
            [self refreshWithSettings:nil];
        }
    }
}

- (void)toggleModifier: (int)modifier toState:(BOOL) used
{
    int flags=0;
    flags = [currentAction modifiers];
    if(used){
        flags = flags|modifier;
    }else{
        flags = flags & (~modifier);
    }
    [currentAction setModifiers:flags];
    [self syncCurrentAction];
}

- (IBAction)highlightColorWellChosen:(id)sender
{
	NSLog(@"corner color: %@",[highlightColorWell color]);
	
    [appSettings setHighlightColor:[sender color]];
	
    //[self notifyAppOfPreferences: [appSettings asDictionary]];
    [self saveChanges];
}
- (IBAction)bubbleColorWellAChosen:(id)sender
{
	
	//NSLog(@"bubble color: %@",[bubbleColorWellA color]);
	//[appSettings setBubbleColorA:[[bubbleColorWellA color] colorWithAlphaComponent:0.8]];
	//[appSettings setBubbleColorB:[[bubbleColorWellA color] colorWithAlphaComponent:0.4]];
	
    //[self notifyAppOfPreferences: [appSettings asDictionary]];
	
    //[self saveChanges];
	//[self displayColorExample];
	
}
- (IBAction)bubbleColorWellBChosen:(id)sender
{
	
	//NSLog(@"bubble color: %@",[bubbleColorWellB color]);
	//[appSettings setBubbleColorB:[bubbleColorWellB color]];
	
    //[self notifyAppOfPreferences: [appSettings asDictionary]];
	
    //[self saveChanges];
	//[self displayColorExample];
	
}
- (IBAction)highlightOptionChosen:(id)sender
{
	
	int colorOption = [sender indexOfSelectedItem];
	if(colorOption == 2){		
		[highlightColorWell setHidden:NO];
		if([appSettings highlightColor] != nil)
			[highlightColorWell setColor: [appSettings highlightColor]];
		else
			[highlightColorWell setColor: [NSColor blackColor]];
	}else{
		[highlightColorWell setHidden:YES];
	}
    //[self doChooseScreen:[sender indexOfSelectedItem] withPopupWindow:YES];
	
    [appSettings setColorOption:colorOption];
	
    //[self notifyAppOfPreferences: [appSettings asDictionary]];
    [self saveChanges];
}


- (IBAction)gotoWebURL:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:
		[NSURL URLWithString:WEB_SITE_URL]];
}
- (IBAction)gotoEmailURL:(id)sender
{
	
	[[NSWorkspace sharedWorkspace] openURL:
		[NSURL URLWithString:EMAIL_URL]];
}


- (IBAction)removeActionButtonClicked:(id)sender
{
    int sel=[actionTable selectedRow];
    //NSLog(@"selection changed to: %d",[actionTable selectedRow]);
    if(sel>=0){

        [actionTable deselectAll:self];
        [appSettings removeActionAtIndex: sel forScreen:[allScreens objectAtIndex:chosenScreen]
                               andCorner:chosenCorner];
        
//        [self notifyAppOfPreferences: [appSettings asDictionary]];

        [self saveChanges];
        if(sel>0 &&
           sel < [appSettings countActionsForScreen:[allScreens objectAtIndex:chosenScreen]
                                                   andCorner:chosenCorner]){

            [self refreshWithSettings:[appSettings actionAtIndex:sel
                                                       forScreen:[allScreens objectAtIndex:chosenScreen]
                                                       andCorner:chosenCorner]];
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

    ClickAction *newAct = [[[ClickAction alloc] initWithType: 0 
												andModifiers: 0 
												  andTrigger: 0
                                                   isDelayed: NO
												   andString: nil
												   forCorner: chosenCorner
												   withLabel:nil
												  andClicker:nil] autorelease];

    [appSettings addAction: newAct forScreen:[allScreens objectAtIndex:chosenScreen] andCorner:chosenCorner];
    [actionTable reloadData];

    [actionTable selectRow:[appSettings countActionsForScreen:[allScreens objectAtIndex:chosenScreen] andCorner:chosenCorner]-1 byExtendingSelection:NO];
    [actionTable scrollRowToVisible:[actionTable selectedRow]];
    //[self refreshWithSettings:newAct];
  
}
- (IBAction)optionKeyCheckBoxClicked:(id)sender
{
    [self toggleModifier: OPTION_MASK toState: [sender state]==0?NO:YES];
    //[self notifyAppOfPreferences: [appSettings asDictionary]];
    [self saveChanges];
    [actionTable reloadData];
}
- (IBAction)shiftKeyCheckBoxClicked:(id)sender
{
    [self toggleModifier: SHIFT_MASK toState: [sender state]==0?NO:YES];
    //[self notifyAppOfPreferences: [appSettings asDictionary]];
    [self saveChanges];
    [actionTable reloadData];
}
- (IBAction)commandKeyCheckBoxClicked:(id)sender
{
    [self toggleModifier: COMMAND_MASK toState: [sender state]==0?NO:YES];
    //[self notifyAppOfPreferences: [appSettings asDictionary]];
    [self saveChanges];
    [actionTable reloadData];
}
- (IBAction)controlKeyCheckBoxClicked:(id)sender
{

    [self toggleModifier: CONTROL_MASK toState: [sender state]==0?NO:YES];
    //[self notifyAppOfPreferences: [appSettings asDictionary]];
    [self saveChanges];
    [actionTable reloadData];
}
- (IBAction)functionKeyCheckBoxClicked:(id)sender
{
	
    [self toggleModifier: FN_MASK toState: [sender state]==0?NO:YES];
    //[self notifyAppOfPreferences: [appSettings asDictionary]];
    [self saveChanges];
    [actionTable reloadData];
}



@end
