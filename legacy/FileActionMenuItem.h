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

/* FileActionMenuItem */

#import <Cocoa/Cocoa.h>
#import "ClickBoxPref.h"
@class ClickBoxPref;

@interface FileActionMenuItem : NSMenuItem
{
    NSString *filePath;
    ClickBoxPref *myPref;
}
- (id) initWithFilePath: (NSString *) path andClickPref:(ClickBoxPref *) pref andTitle:(NSString *) title;
- (id) initWithFilePath: (NSString *) path andClickPref:(ClickBoxPref *) pref;
- (IBAction)doAction:(id)sender;
@end
