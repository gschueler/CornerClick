//
//  ClickBoxPref.h
//  ClickBox
//
//  Created by Greg Schueler on Wed Jul 16 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import <AppKit/NSTableView.h>
#import "clickBG/ClickAction.h"

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
    IBOutlet NSView *chooseURLView;
    IBOutlet NSTextField *urlTextField;
    IBOutlet NSTextField *urlLabelField;
    IBOutlet NSButton *appEnabledCheckBox;
    IBOutlet NSButton *showTooltipCheckBox;
    IBOutlet NSButton *delayTooltipCheckBox;
    IBOutlet NSProgressIndicator *appLaunchIndicator;
    IBOutlet NSTextField *appLaunchErrorLabel;
    IBOutlet NSButton *addActionButton;
    IBOutlet NSButton *removeActionButton;
    IBOutlet NSTableView *actionTable;
    IBOutlet NSButton *optionKeyCheckBox;
    IBOutlet NSButton *shiftKeyCheckBox;
    IBOutlet NSButton *commandKeyCheckBox;
    IBOutlet NSButton *controlKeyCheckBox;
    IBOutlet NSTextView *readmeTextView;
    NSMutableDictionary *tl;
    NSMutableDictionary *tr;
    NSMutableDictionary *bl;
    NSMutableDictionary *br;
    NSMutableDictionary *currentDict;
    NSMutableDictionary *currentActionDict;
    NSMutableDictionary *appPrefs;
    NSMutableArray *currentActions;
    int chosenCorner;
    int chosenAction;
    BOOL active;
    ClickAction *currentAction;
    NSTimer *disableTimer;
}
- (IBAction)actionChosen:(id)sender;
- (IBAction)cornerChosen:(id)sender;
- (IBAction)enableChosen:(id)sender;
- (IBAction)fileChooseClicked:(id)sender;
- (IBAction)triggerChosen:(id)sender;
- (IBAction)appEnable:(id)sender;
- (IBAction)tooltipEnable:(id)sender;
- (IBAction)tooltipDelay:(id)sender;
- (IBAction)urlEntered:(id)sender;
- (IBAction)removeActionButtonClicked:(id)sender;
- (IBAction)addActionButtonClicked:(id)sender;
- (IBAction)optionKeyCheckBoxClicked:(id)sender;
- (IBAction)shiftKeyCheckBoxClicked:(id)sender;
- (IBAction)commandKeyCheckBoxClicked:(id)sender;
- (IBAction)controlKeyCheckBoxClicked:(id)sender;
- (void) mainViewDidLoad;
- (void) didUnselect;
- (void) saveChanges;
- (void) saveChangesFromNotification:(NSNotification *)aNotification;

- (void) refreshWithSettings:(NSDictionary *)settings;
- (void) refreshWithCornerSettings: (NSDictionary *) settings;
- (void) checkIfHelperAppRunning;
- (void) notifyAppOfPreferences:(NSDictionary *) prefs;
- (NSDictionary *) makePrefs;
- (void) setSubFrameForActionType: (int) type;
- (void)toggleModifier: (int)modifier toState:(BOOL) used;
- (NSAttributedString *)makeAttributedLink:(NSString *) link forString:(NSString *) string;

@end
