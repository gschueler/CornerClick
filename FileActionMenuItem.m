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

#import "FileActionMenuItem.h"

@implementation FileActionMenuItem

- (id) initWithFilePath: (NSString *) path andClickPref:(ClickBoxPref *) pref
{
    return [self initWithFilePath: path andClickPref: pref andTitle:nil];
}
- (id) initWithFilePath: (NSString *) path andClickPref:(ClickBoxPref *) pref andTitle:(NSString *) title
{
    NSString *theTitle = title;
    if(title == nil)
        theTitle=[[NSFileManager defaultManager] displayNameAtPath:path];
    if(self = [super initWithTitle:theTitle action:@selector(doAction:) keyEquivalent:@""]){
        filePath = [path copy];
        myPref = pref;
        NSImage *img = [[NSWorkspace sharedWorkspace] iconForFile:filePath];
        [img setSize:NSMakeSize(16.0,16.0)];
        [self setImage: img];
        [self setEnabled:YES];
        [self setTarget:self];
    }
    return self;
}
- (IBAction)doAction:(id)sender
{
    [myPref setSelectedActionPath:filePath resettingScriptLabel: YES];
}

- (void) dealloc
{
    [filePath release];
    [super dealloc];
}

@end
