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
