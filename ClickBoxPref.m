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
    NSLog(@"Identifier is %@",[[NSBundle bundleForClass:[self class]] bundleIdentifier]);

    [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(saveChangesFromNotification:)
           name:NSApplicationWillTerminateNotification
         object:nil];
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
        
       // [website setStringValue:[prefs objectForKey:@"website"]];
        //[author setState:1 atRow:[[prefs objectForKey:@"author"] intValue]
        //          column:0];
        //[rating setFloatValue:[[prefs objectForKey:@"rating"] floatValue]];
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
        
/*
        tr = [[NSMutableDictionary dictionaryWithCapacity:4] retain];
        [tr setObject: [NSNumber numberWithInt:0] forKey:@"enabled"];
        [tr setObject: [NSNumber numberWithInt:0] forKey:@"action"];
        [tr setObject: [NSNumber numberWithInt:0] forKey:@"trigger"];
        [tr setObject: @"" forKey:@"chosenFilePath"];
        bl = [[NSMutableDictionary dictionaryWithCapacity:4] retain];
        [bl setObject: [NSNumber numberWithInt:0] forKey:@"enabled"];
        [bl setObject: [NSNumber numberWithInt:0] forKey:@"action"];
        [bl setObject: [NSNumber numberWithInt:0] forKey:@"trigger"];
        [bl setObject: @"" forKey:@"chosenFilePath"];
        br = [[NSMutableDictionary dictionaryWithCapacity:4] retain];
        [br setObject: [NSNumber numberWithInt:0] forKey:@"enabled"];
        [br setObject: [NSNumber numberWithInt:0] forKey:@"action"];
        [br setObject: [NSNumber numberWithInt:0] forKey:@"trigger"];
        [br setObject: @"" forKey:@"chosenFilePath"];
     */   
    }
    currentDict = tl;
    [self refreshWithSettings: currentDict];
    //NSLog(@"loaded main view.  current: %@",currentDict);
    //NSLog(@"retain count of current: %d",[currentDict retainCount]);
}

- (IBAction)appEnable:(id)sender
{
    //appLaunchIndicator
    if(active){
        [appLaunchIndicator startAnimation:self];
        active=NO;
    }else{
        [appLaunchIndicator stopAnimation:self];
        active=YES;
    }
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

}
- (IBAction)tooltipDelay:(id)sender
{
    int state = [sender state]==NSOnState?1:0;
    //NSLog(@"Enabled: %d",state);
    if(appPrefs){
        //NSLog(@"CurrentDict type: %@",[currentDict class]);
        [appPrefs setObject: [NSNumber numberWithInt: state ] forKey:@"tooltipDelayed"];
    }
}

- (void) refreshWithSettings:(NSDictionary *)settings
{

    //NSLog(@"retain count of settings: %d",[settings retainCount]);
    
    [enabledCheckBox setState:[[settings objectForKey:@"enabled"] intValue]];
    [actionChoicePopupButton selectItemAtIndex: [[settings objectForKey:@"action"] intValue]];
    [triggerChoicePopupButton selectItemAtIndex: [[settings objectForKey:@"trigger"] intValue]];
    [appEnabledCheckBox setState:[[settings objectForKey:@"appEnabled"] intValue]];
    
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
    NSArray *sub = [actionView subviews];
    if([sub count] && [sub objectAtIndex:0]!=nil){
        [[sub objectAtIndex:0] retain];
        [[sub objectAtIndex:0] removeFromSuperview];
    }
    switch([[settings objectForKey:@"action"] intValue]){
        case 0:
            [actionView addSubview: chooseFileView];
            break;
        case 1:
            break;
    }

    
}

- (void)openSheetDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    //NSLog(@"Sheet finished");

    if(returnCode==NSOKButton){
        NSString *thefile = [[sheet filenames] objectAtIndex:0];
        [currentDict setObject:thefile forKey:@"chosenFilePath"];
        [chosenFileLabel setStringValue: [thefile lastPathComponent]];
        NSFileWrapper *temp = [[[NSFileWrapper alloc] initWithPath: thefile] autorelease];
        [fileIconImageView setImage: [temp icon]];
    }

}


- (void) didUnselect
{
    //NSLog(@"didUnselect");
    [self saveChanges];
}

- (void) saveChangesFromNotification:(NSNotification*)aNotification
{
    [self saveChanges];
}

- (void) saveChanges
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
        nil];
    


    //NSLog(@"Made Dictionary");
    
    [[NSUserDefaults standardUserDefaults]
        removePersistentDomainForName:@"CornerClickPref"];

    //NSLog(@"removedDomain");
    
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:prefs
         forName:@"CornerClickPref"];

    //NSLog(@"setDomain");

    [prefs autorelease];

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
    NSArray *sub = [actionView subviews];
    if([sub count] && [sub objectAtIndex:0]){
        [[sub objectAtIndex:0] retain];
        [[sub objectAtIndex:0] removeFromSuperview];
    }
    switch([sender indexOfSelectedItem]){
        case 0: //open file
            [actionView addSubview: chooseFileView];
            break;
        case 1:
            break;
    }
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

}
@end
