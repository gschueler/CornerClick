//
//  ClickBoxPref.h
//  ClickBox
//
//  Created by Greg Schueler on Wed Jul 16 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>


@interface ClickBoxPref : NSPreferencePane
{
    IBOutlet NSPopUpButton *actionChoicePopupButton;
    IBOutlet NSTextField *chosenFileLabel;
    IBOutlet NSPopUpButton *cornerChoicePopupButton;
    IBOutlet NSButton *enabledCheckBox;
    IBOutlet NSButton *fileChooseButton;
    IBOutlet NSPopUpButton *triggerChoicePopupButton;
    IBOutlet NSImageView *fileIconImageView;
    IBOutlet NSView *actionView;
    IBOutlet NSView *chooseFileView;
    IBOutlet NSButton *appEnabledCheckBox;
    IBOutlet NSButton *showTooltipCheckBox;
    IBOutlet NSButton *delayTooltipCheckBox;
    IBOutlet NSProgressIndicator *appLaunchIndicator;
    NSMutableDictionary *tl;
    NSMutableDictionary *tr;
    NSMutableDictionary *bl;
    NSMutableDictionary *br;
    NSMutableDictionary *currentDict;
    NSMutableDictionary *appPrefs;
    int chosenCorner;
    BOOL active;
}
- (IBAction)actionChosen:(id)sender;
- (IBAction)cornerChosen:(id)sender;
- (IBAction)enableChosen:(id)sender;
- (IBAction)fileChooseClicked:(id)sender;
- (IBAction)triggerChosen:(id)sender;
- (IBAction)appEnable:(id)sender;
- (IBAction)tooltipEnable:(id)sender;
- (IBAction)tooltipDelay:(id)sender;
- (void) mainViewDidLoad;
- (void) didUnselect;
- (void) saveChanges;
- (void) saveChangesFromNotification:(NSNotification *)aNotification;

- (void) refreshWithSettings:(NSDictionary *)settings;

@end
