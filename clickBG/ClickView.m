#import "ClickView.h"
#import "ClickAction.h"

@implementation ClickView

- (id)initWithFrame:(NSRect)frameRect action:(ClickAction *)anAction corner:(int) theCorner;
{
    if(self = [super initWithFrame:frameRect]){
        myAction=[anAction retain];
        drawed=nil;
        corner=theCorner;
    }
    return self;
}

- (void) setSelected: (BOOL)isSelected
{
    if(selected != isSelected){
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
        [[[NSColor whiteColor] colorWithAlphaComponent:0.25] set];
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
}

- (void)mouseDown:(NSEvent *)theEvent
{

    [myAction doAction: theEvent];
}

- (void) rightMouseDown:(NSEvent *)theEvent
{
    [NSApp terminate:nil];
}


@end
