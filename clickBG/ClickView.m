#import "ClickView.h"
#import "ClickAction.h"

@implementation ClickView

- (id)initWithFrame:(NSRect)frameRect action:(ClickAction *)anAction corner:(int) theCorner;
{
    self = [self initWithFrame:frameRect actions: [NSArray arrayWithObject: anAction] corner:theCorner];
    return self;
}

- (id)initWithFrame:(NSRect)frameRect actions:(NSArray *)actions corner:(int) theCorner;
{
    if(self = [super initWithFrame:frameRect]){
        myActions = [actions retain];
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
    [actions retain];
    [myActions release];
    myActions=actions;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    return NSDragOperationNone;
    NSLog(@"draggingEntered");
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
    NSLog(@"draggingExited");
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
    ClickAction *temp;
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
            if(url!=nil){
                temp = [[ClickAction alloc] initWithType:3 andModifiers: 0 andString:[url absoluteString] forCorner:[myAction corner]];
                [myAction release];
                myAction=temp;
            }
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
            temp = [[ClickAction alloc] initWithType:0 andModifiers: 0 andString:path forCorner:[myAction corner]];
                //-(id)initWithType: (int) type andString: (NSString *)theString forCorner: (int) corner withLabel:(NSString *) label;
            [myAction release];
            myAction = temp;
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
    if(drawed==nil){
        [self drawBuf:rect];
    }
    [[NSColor clearColor] set];
    NSRectFill(rect);
    [drawed compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];
}

- (void) drawBuf: (NSRect) rect
{
    NSBezierPath *path;
    drawed = [[NSImage alloc] initWithSize: rect.size];
    [drawed lockFocus];
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
            NSLog(@"unknown corner: %d",corner);
            path = [NSBezierPath bezierPathWithRect:rect];
            from=&tl;
            to=&bl;
    }



    if(selected)
        [[[NSColor whiteColor] colorWithAlphaComponent:0.50] set];
    else
        [[[NSColor blackColor] colorWithAlphaComponent:0.50] set];

    [path fill];
    
    [path setLineWidth: 2.0];
    [[NSColor whiteColor] set];
    //[NSBezierPath strokeLineFromPoint:*from toPoint:*to];
//    [path stroke];
    [drawed unlockFocus];
}

- (void) dealloc
{
    [drawed release];
    [myAction release];
    [myActions release];
}
- (ClickAction *) clickActionForModifierFlags:(unsigned int) modifiers
{
    int i;
    ClickAction *theAction;
    int flags=0;
    unsigned int evtFlags = modifiers;
    if(evtFlags & NSShiftKeyMask)
        flags|=SHIFT_MASK;
    if(evtFlags & NSAlternateKeyMask)
        flags|=OPTION_MASK;
    if(evtFlags & NSCommandKeyMask)
        flags|=COMMAND_MASK;
    if(evtFlags & NSControlKeyMask)
        flags|=CONTROL_MASK;
    for(i=0;i<[myActions count]; i++){
        theAction = (ClickAction *)[myActions objectAtIndex:i];
        if([theAction modifiers]==flags){
            return theAction;
            //return;
        }
    }
    return nil;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    int i;
    ClickAction *theAction;
    int flags=0;
    unsigned int evtFlags = [theEvent modifierFlags];
    if(evtFlags & NSShiftKeyMask)
        flags|=SHIFT_MASK;
    if(evtFlags & NSAlternateKeyMask)
        flags|=OPTION_MASK;
    if(evtFlags & NSCommandKeyMask)
        flags|=COMMAND_MASK;
    if(evtFlags & NSControlKeyMask)
        flags|=CONTROL_MASK;
    for(i=0;i<[myActions count]; i++){
        theAction = (ClickAction *)[myActions objectAtIndex:i];
        if([theAction modifiers]==flags){
            //NSLog(@"do action %@",[theAction label]);
            [theAction doAction:theEvent];
            //return;
        }
    }
}


@end
