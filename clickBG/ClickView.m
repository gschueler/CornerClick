#import "ClickView.h"
#import "ClickAction.h"

@implementation ClickView


- (id)initWithFrame:(NSRect)frameRect actions:(NSArray *)actions corner:(int) theCorner clicker:(Clicker *)clicker;
{
    int c;
    NSMutableArray *ma;
    if(self = [super initWithFrame:frameRect]){
        myClicker=clicker;
        ma = [[NSMutableArray arrayWithCapacity:[actions count]] retain];
        for(c=0;c<[actions count];c++){
            [ma addObject:[[[actions objectAtIndex:c] copy] autorelease]];
        }
        myActions = ma;
        //myAction=[anAction retain];
        drawed=nil;
        corner=theCorner;
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSURLPboardType,
            NSFilenamesPboardType, nil]];
    }
    return self;
}

- (NSArray *) clickActions
{
    return myActions;
}

- (void) setClickActions: (NSArray *) actions
{
    NSMutableArray *ma;
    int c;

    ma = [[NSMutableArray arrayWithCapacity:[actions count]] retain];
    for(c=0;c<[actions count];c++){
        [ma addObject:[[[actions objectAtIndex:c] copy] autorelease]];
    }
    [myActions release];
    myActions = ma;
	[actionsGroups release];
	actionsGroups=nil;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    return NSDragOperationNone;
    DEBUG(@"draggingEntered");
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask])
        == NSDragOperationGeneric)
    {
        //this means that the sender is offering the type of operation we want
        //return that we want the NSDragOperationGeneric operation that they
        //are offering
        [self setSelected: YES];
        [[self window] setAlphaValue: 1.0];
        [self setNeedsDisplay: YES];
        return NSDragOperationGeneric;
    }
    else
    {
        //since they aren't offering the type of operation we want, we have
        //to tell them we aren't interested
        return NSDragOperationNone;
    }
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    DEBUG(@"draggingExited");
    //we aren't particularily interested in this so we will do nothing
    //this is one of the methods that we do not have to implement
    [self setSelected: NO];
    [self setNeedsDisplay: YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    //ClickAction *temp;
    NSURL *url;
    NSPasteboard *paste = [sender draggingPasteboard];
    //gets the dragging-specific pasteboard from the sender
    NSArray *types = [NSArray arrayWithObjects:
        NSURLPboardType,
        NSFilenamesPboardType, nil];
    //a list of types that we can accept
    NSString *desiredType = [paste availableTypeFromArray:types];
    NSData *carriedData = [paste dataForType:desiredType];

    [self setSelected: NO];
    [self setNeedsDisplay: YES];
    if (nil == carriedData)
    {
        //the operation failed for some reason
        NSRunAlertPanel(@"Paste Error", @"Sorry, but the past operation failed",
                        nil, nil, nil);
        return NO;
    }
    else
    {
        //the pasteboard was able to give us some meaningful data
        if( [desiredType isEqualToString:NSURLPboardType]){
//            id test = [paste propertyListForType:@"NSURLPboardType"];
            url = [NSURL URLFromPasteboard:paste];
            /*
            if(url!=nil){
                temp = [[ClickAction alloc] initWithType:3 andModifiers: 0 andString:[url absoluteString] forCorner:[myAction corner] andClicker:[NSApp delegate]];
                [myAction release];
                myAction=temp;
            }
             */
        }else
        if ([desiredType isEqualToString:NSFilenamesPboardType])
        {
            //we have a list of file names in an NSData object
            NSArray *fileArray =
            [paste propertyListForType:@"NSFilenamesPboardType"];
            //be caseful since this method returns id.
            //We just happen to know that it will be an array.
            NSString *path = [fileArray objectAtIndex:0];
            //assume that we can ignore all but the first path in the list
            NSLog(@"got new path: %@",path);
            //temp = [[ClickAction alloc] initWithType:0 andModifiers: 0 andString:path forCorner:[myAction corner] andClicker:[NSApp delegate]];
                //-(id)initWithType: (int) type andString: (NSString *)theString forCorner: (int) corner withLabel:(NSString *) label;
            //[myAction release];
            //myAction = temp;
        }
        else
        {
            //this can't happen
            NSAssert(NO, @"This can't happen");
            return NO;
        }
    }
//    [self setNeedsDisplay:YES];    //redraw us with the new image
    return YES;
}


- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
    //we don't do anything in our implementation
    //this could be ommitted since NSDraggingDestination is an infomal
    //protocol and returns nothing
    [self setSelected: NO];
    [self setNeedsDisplay: YES];
}

- (void) setSelected: (BOOL)isSelected
{
    if(selected && !isSelected || !selected && isSelected){
        //NSLog(@"drawed retainCount before release: %d",[drawed retainCount]);
        [drawed release];
        drawed=nil;
    }
        
    selected=isSelected;
}

- (void)drawRect:(NSRect)rect
{
    //if(drawed==nil){
    //    [self drawBuf:rect];
    //}
	//NSLog(@"drawing clickview rect");
//    [[NSColor clearColor] set];
    [[NSColor clearColor] set];
    NSRectFill(rect);
	[self drawBuf:rect];
    //[drawed compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];
    //[[drawed TIFFRepresentation] writeToFile: [[NSString stringWithFormat:@"~/Desktop/%d.tiff", corner] stringByExpandingTildeInPath] atomically:YES];
}

- (void) drawBuf: (NSRect) rect
{
    NSBezierPath *path;
    //drawed = [[NSImage alloc] initWithSize: rect.size];
    //[drawed lockFocus];
    NSPoint *from,*to;
    NSPoint tl=NSMakePoint(rect.origin.x,rect.origin.y+rect.size.height);
    NSPoint tr=NSMakePoint(rect.origin.x+rect.size.width,rect.origin.y+rect.size.height);
    NSPoint bl=NSMakePoint(rect.origin.x,rect.origin.y);
    NSPoint br=NSMakePoint(rect.origin.x+rect.size.width,rect.origin.y);

    path = [NSBezierPath bezierPath];
    [path moveToPoint:tl];
    switch(corner){
        case 0:
            [path lineToPoint:tr];
            [path lineToPoint:bl];
            from=&tr;
            to=&bl;
            break;
        case 1:
            [path lineToPoint:tr];
            [path lineToPoint:br];
            from=&tl;
            to=&br;
            break;
        case 2:
            [path lineToPoint:br];
            [path lineToPoint:bl];
            from=&tl;
            to=&br;
            break;
        case 3:
            [path moveToPoint:tr];
            [path lineToPoint:br];
            [path lineToPoint:bl];
            from=&tr;
            to=&bl;
            break;
        default:
            NSLog(@"unknown corner!: %d",corner);
            path = [NSBezierPath bezierPathWithRect:rect];
            from=&tl;
            to=&bl;
    }

	NSColor *theColor;
    if(selected)
        theColor = [[NSColor whiteColor] colorWithAlphaComponent:0.50];
    else
        theColor = [[myClicker determineHighlightColor] colorWithAlphaComponent: 0.5];
	if(nil == theColor){
		theColor = [[NSColor selectedControlColor] colorWithAlphaComponent:0.5];
	}
	[theColor set];
	//NSLog(@"drawn from determined highlightcolor: %@", [theColor description]);

    [path fill];
    
   // [path setLineWidth: 2.0];
    //[[NSColor whiteColor] set];
    //[NSBezierPath strokeLineFromPoint:*from toPoint:*to];
//    [path stroke];
    //[drawed unlockFocus];
}


- (void) dealloc
{
    [drawed release];
    [myActions release];
	[actionsGroups release];
}
- (ClickAction *) clickActionForModifierFlags:(unsigned int) modifiers
{
    int i;
    ClickAction *theAction;
    int flags=0;
    unsigned int evtFlags = modifiers;
	flags = [Clicker modsForEventFlags:evtFlags];
    for(i=0;i<[myActions count]; i++){
        theAction = (ClickAction *)[myActions objectAtIndex:i];
        if([theAction modifiers]==flags){
            return theAction;
            //return;
        }
    }
    return nil;
}
- (NSArray *) clickActionsForModifierFlags:(unsigned int) modifiers
{
	return [self clickActionsForModifierFlags:modifiers andTrigger:-1];
}

- (NSArray *) clickActionsForModifierFlags:(unsigned int) modifiers
								andTrigger:(int) trigger
{
    int i;
    ClickAction *theAction;
	NSMutableArray *thearr = [[NSMutableArray alloc] init];
    int flags=0;
    unsigned int evtFlags = modifiers;
	flags = [Clicker modsForEventFlags:evtFlags];
    for(i=0;i<[myActions count]; i++){
        theAction = (ClickAction *)[myActions objectAtIndex:i];
        if([theAction modifiers]==flags && (trigger<0 || [theAction trigger]==trigger)){
						   
			[thearr addObject: theAction];
            //return theAction;
            //return;
        }
    }
    return [thearr autorelease];
}

- (NSArray *) actionsGroupsForModifiers:(int) mods
{
    int i;
    NSArray *ags = [self actionsGroups];
    NSMutableArray *ma = [[[NSMutableArray alloc] init] autorelease];
    //DEBUG(@"got %d actions groups",[ags count]);
    for(i=0;i<[ags count];i++){
        NSArray *group = (NSArray *)[ags objectAtIndex:i];
        ClickAction *act = (ClickAction *)[group objectAtIndex:0];
        //DEBUG(@"is action mods (%d) equal to mods (%d)? %@",[act modifiers], mods, ([act modifiers]==mods ? @"YES":@"NO"));
        if([act modifiers]==mods){
            [ma addObject:group];
        }
    }
    return ma;
}
- (NSArray *) actionsGroups
{
	int i;
	if(nil!=actionsGroups)
		return actionsGroups;
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    
	for(i=0;i<[myActions count]; i++){
        ClickAction *theAction = (ClickAction *)[myActions objectAtIndex:i];
		NSString *key = [NSString stringWithFormat:@"%d,%d",[theAction trigger],[theAction modifiers]];
		if([dict objectForKey:key]==nil){
			NSMutableArray *marr = [[[NSMutableArray alloc] initWithObjects:theAction,nil] autorelease];
			[dict setObject:marr forKey:key];
		}else{
			NSMutableArray *marr = [dict objectForKey:key];
			[marr addObject:theAction];
		}        
    }
	actionsGroups = [[dict allValues] retain];
	return actionsGroups;
    
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[myClicker mouseDownTrigger:theEvent
						 onView:self
						  flags:-1
						trigger:0
					   onCorner:corner];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
	DEBUG(@"Right mouse button in ClickView.m");
	[myClicker mouseDownTrigger:theEvent
						 onView:self
						  flags:-1
						trigger:1
					   onCorner:corner];
}
- (void)otherMouseDown:(NSEvent *)theEvent
{
	DEBUG(@"Other mouse button in ClickView.m");
}

- (BOOL)acceptsFirstMouse
{
	return YES;
}

- (void) setTrackingRectTag:(NSTrackingRectTag) tag
{
    trackTag=tag;
}
- (NSTrackingRectTag) trackingRectTag
{
    return trackTag;
}
- (BOOL) acceptsFirstResponder
{
	return NO;
}

@end
