//
//  ClickApp.h
//  CornerClick
//
//  Created by Greg Schueler on Thu May 06 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ClickApp : NSApplication {

}

- (void)sendEvent:(NSEvent *)anEvent;
@end
