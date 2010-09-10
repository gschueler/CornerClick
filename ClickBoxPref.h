/*
 Copyright 2003-2010 Greg Schueler
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
#import "FileActionMenuItem.h"

@interface ClickBoxPref : NSPreferencePane
{
    IBOutlet NSPopUpButton *actionChoicePopupButton;
    IBOutlet NSTextField *chosenFileLabel;
    IBOutlet NSTextField *chosenFileTitle;
    IBOutlet NSButton *enabledCheckBox;
    IBOutlet NSButton *fileChooseButton;
    IBOutlet NSPopUpButton *triggerChoicePopupButton;
    IBOutlet NSImageView *fileIconImageView;
    IBOutlet NSImageView *scriptIconImageView;
    IBOutlet NSTextField *chosenScriptLabel;
    IBOutlet NSView *actionView;
    IBOutlet NSView *chooseFileView;
    IBOutlet NSView *chooseURLView;
    IBOutlet NSView *chooseScriptView;
    IBOutlet NSTextField *urlTextField;
    IBOutlet NSTextField *urlLabelField;
    IBOutlet NSTextField *scriptLabelField;
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
    IBOutlet NSButton *functionKeyCheckBox;
    IBOutlet NSTextView *readmeTextView;
    IBOutlet NSMatrix *cornerMatrix;
    IBOutlet NSPopUpButton *screenIDButton;
    IBOutlet NSTextField *screenCountTextField;
    IBOutlet NSTabView *myTabView;
    IBOutlet NSButton *cycleScreensButton;
    IBOutlet NSColorWell *highlightColorWell;
    IBOutlet NSColorWell *bubbleColorWellA;
    IBOutlet NSColorWell *bubbleColorWellB;
    IBOutlet NSPopUpButton *highlightPopup;
    IBOutlet NSPopUpButton *quickFilePopup;
    IBOutlet NSPopUpButton *quickScriptPopup;
    IBOutlet NSButton *hoverTriggerDelayedCheckbox;
    IBOutlet NSTextField *hoverDelayLabel;
    IBOutlet NSTextField *tooltipDelayLabel;
    
    IBOutlet NSView *exposeNoteView;
        
    IBOutlet NSTextField *versionStringField;
    IBOutlet NSObjectController *myObjectController;
    
    
    NSInteger chosenCorner;
    NSInteger chosenAction;
    NSInteger chosenScreen;
    NSInteger eerepeated;
    BOOL active;
    BOOL awaitingDisabledHelperNotification;
    BOOL reloadHelperOnHelperDeactivation;
    BOOL loadedQuickScripts;
    BOOL loadedQuickFiles;
    ClickAction *currentAction;
    NSTimer *disableTimer;
    NSWindow *screenIdWindow;
    GrayView *screenIdView;
    NSMutableDictionary *screenNums;
    NSMutableArray *allScreens;
    NSTimer *delayTimer;
    NSArray *ordinalNames;
    CornerClickSettings *appSettings;
    NSMutableDictionary *mySettings;
    BOOL chooseButtonIsVisible;
}
- (void) showQuickScriptsPopup;
- (void)doChooseCorner:(NSInteger) corner;
- (IBAction)tableViewAction:(id)sender;
- (IBAction)chooseNextScreen:(id)sender;
- (IBAction)screenIDClicked:(id)sender;
- (IBAction)tlCornerClick:(id)sender;
- (IBAction)trCornerClick:(id)sender;
- (IBAction)blCornerClick:(id)sender;
- (IBAction)brCornerClick:(id)sender;
- (IBAction)actionChosen:(id)sender;
- (IBAction)cornerChosen:(id)sender;
- (IBAction)enableChosen:(id)sender;
- (IBAction)fileChooseClicked:(id)sender;
- (IBAction)triggerChosen:(id)sender;
- (IBAction)appEnable:(id)sender;
- (IBAction)urlEntered:(id)sender;
- (IBAction)removeActionButtonClicked:(id)sender;
- (IBAction)addActionButtonClicked:(id)sender;
- (IBAction)optionKeyCheckBoxClicked:(id)sender;
- (IBAction)shiftKeyCheckBoxClicked:(id)sender;
- (IBAction)commandKeyCheckBoxClicked:(id)sender;
- (IBAction)controlKeyCheckBoxClicked:(id)sender;
- (IBAction)functionKeyCheckBoxClicked:(id)sender;
- (IBAction)highlightColorWellChosen:(id)sender;
- (IBAction)bubbleColorWellAChosen:(id)sender;
- (IBAction)bubbleColorWellBChosen:(id)sender;
- (IBAction)gotoWebURL:(id)sender;
- (IBAction)gotoEmailURL:(id)sender;
- (IBAction)highlightOptionChosen:(id)sender;
//- (IBAction)loadInformationRTF:(id)sender;
- (IBAction)loadReadmeRTF:(id)sender;
- (IBAction)openExposePrefPane: (id) sender;
- (IBAction)checkVersionUpdate: (id) sender;

- (NSMutableDictionary *) mySettings;
- (void) setMySettings: (NSMutableDictionary *) settings;

- (CornerClickSettings *) appSettings;
- (void)setAppSettings: (CornerClickSettings *) settings;
- (ClickAction *) currentAction;

- (void) deactivateHelper;
- (void) activateHelper;
- (void) mainViewDidLoad;
- (void) didUnselect;
- (void) saveChanges;
- (void) saveChangesFromNotification:(NSNotification *)aNotification;
- (void) syncCurrentAction;
- (void) checkScreens;
- (void) displayScreenIdentification;
- (void) fadeScreenIdentification;
- (void) refreshWithSettings:(ClickAction *)settings;
- (void) refreshWithCornerSettings;
- (void) checkIfHelperAppRunning;
- (void) notifyAppOfPreferences:(NSDictionary *) prefs;
- (void) doChooseScreen: (NSInteger) which withPopupWindow: (BOOL) popup;
- (void) setSelectedActionPath: (NSString *) path;
- (void) setSelectedActionPath: (NSString *) thefile resettingScriptLabel:(BOOL) doReset;
- (void) setSubFrameForActionType: (NSInteger) type;
- (void)toggleModifier: (NSInteger)modifier toState:(BOOL) used;
- (NSAttributedString *)makeAttributedLink:(NSString *) link forString:(NSString *) string;
- (void) addActionMenuItems: (NSArray *) list toMenu: (NSMenu *) menu;

+ (NSString *)ordinalForNumber: (NSInteger) which;

//- (void) _storeList: (id) plist atPath:(NSString *)aPath;
+ (NSArray *) loadPlistArrayFromFile: (NSString *) path;

@end
