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
//  ClickApp.m
//  CornerClick
//
//  Created by Greg Schueler on Thu May 06 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "ClickApp.h"


@implementation ClickApp

- (void)sendEvent:(NSEvent *)anEvent
{
	//DEBUG(@"ClickApp rcvd event: %@",[anEvent description]);
	if([anEvent windowNumber]==0
	   && (
		//    [anEvent type]==NSLeftMouseDown
	//	   || [anEvent type]==		   NSLeftMouseUp
		    [anEvent type]==		   NSRightMouseDown
		   || [anEvent type]==		   NSRightMouseUp
		   || [anEvent type]==		   NSOtherMouseDown
		   || [anEvent type]==		   NSOtherMouseUp
		   || [anEvent type]==		   NSMouseMoved
		   || [anEvent type]==		   NSLeftMouseDragged
		   || [anEvent type]==		   NSRightMouseDragged
		   || [anEvent type]==		   NSOtherMouseDragged
		   )
	   ){
		[(Clicker*)[self delegate] sendEvent:anEvent];
	}else{
		[super sendEvent:anEvent];		
	}
}
@end
