//
//  GrayView.m
//  TestBox
//
//  Created by Greg Schueler on Fri Jul 18 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "GrayView.h"


@implementation GrayView

- (id) initWithFrame: (NSRect) frame andString: (NSString *)msg
{
    self = [self initWithFrame: frame
                     andString: msg
                      andImage: nil
                     fadeColor: nil
                     fadeAlpha:-1
                    cornerSize:-1
                   pointCorner:-1];
        
    
    return self;
}

- (id) initWithFrame: (NSRect) frame andString: (NSString *)msg andImage: (NSImage *) img
{
    self = [self initWithFrame: frame
                     andString: msg
                      andImage: img
                     fadeColor: nil
                     fadeAlpha:-1
                    cornerSize:-1
                   pointCorner:-1];


    return self;
}
- (id) initWithFrame: (NSRect) frame andString: (NSString *)msg andImage: (NSImage *) img
           fadeColor: (NSColor *)fadeCol fadeAlpha: (float)fAlpha cornerSize: (float) cornerSize
         pointCorner: (int) pCorner

{
    //[self setAlphaValue: 0.5];
    //return self;
    

    if(self = [super initWithFrame: frame]){
        if(img !=nil){
            iconImage = [img retain];
            [iconImage setSize: NSMakeSize(32,32)];
        }else{
            iconImage=nil;
        }
        if(msg!=nil){
            myString = [msg retain];
            stringAttrs = [[NSDictionary dictionaryWithObjects:
                [NSArray arrayWithObjects: [NSFont boldSystemFontOfSize: 16.0],
                    [NSColor whiteColor],nil]
                                                       forKeys:
                [NSArray arrayWithObjects: NSFontAttributeName,
                    NSForegroundColorAttributeName, nil]
                ] retain];

            shadowAttrs = [[NSDictionary dictionaryWithObjects:
                [NSArray arrayWithObjects: [NSFont boldSystemFontOfSize: 16.0],
                    [NSColor blackColor],nil]
                                                       forKeys:
                [NSArray arrayWithObjects: NSFontAttributeName,
                    NSForegroundColorAttributeName, nil]
                ] retain];
        }else{
            msg=nil;
        }
        textArea = [[NSImage alloc] initWithSize: frame.size];
        if(fadeCol!=nil){
            fadeColor = [fadeCol retain];
        }else{
            fadeColor = [NSColor blackColor];
        }
        fadeAlpha= (fAlpha < 0 ? 0.15 : fAlpha);
        roundingSize= (cornerSize <= 0 ? 22 : cornerSize);
        insetSize = 10;
        pointCorner=pCorner;
        dirty=YES;
        tailLen=30;
    }else{
        NSLog(@"couldn't initWithFrame");
    }
    //[textContainert release];
    //[layoutManagert release];

    return self;
}
- (void)drawFadeFrame: (NSRect)rect
{
    NSBezierPath *fadePath;
    float ox=rect.origin.x;
    float oy=rect.origin.y;
    float taily=oy;
    float wide=ox+rect.size.width;
    float high;
    if(pointCorner==2 || pointCorner==3){
        oy+=tailLen;
        high = rect.origin.y+rect.size.height;
    }
    else{
        taily=oy+rect.size.height;
        high = taily-tailLen;
    }

    fadePath = [[NSBezierPath bezierPath] retain];
            [fadePath moveToPoint: NSMakePoint(wide-roundingSize,oy)];
    if(pointCorner==3){
        //[fadePath lineToPoint: NSMakePoint(wide,oy)];
        [fadePath lineToPoint: NSMakePoint(wide,taily)];
    }else{
        [fadePath appendBezierPathWithArcWithCenter:NSMakePoint(wide-roundingSize,roundingSize+oy)
                                    radius: roundingSize
                                startAngle:270.0
                                    endAngle:0.0];
    }
    if(pointCorner==1){
        //[fadePath lineToPoint: NSMakePoint(wide,high)];
        [fadePath lineToPoint: NSMakePoint(wide,taily)];
        [fadePath lineToPoint: NSMakePoint(wide-roundingSize,high)];
    }else{
        [fadePath
appendBezierPathWithArcWithCenter:NSMakePoint(wide-roundingSize,high-roundingSize)
                        radius: roundingSize
                    startAngle:0.0
                        endAngle:90.0];
    }
    if(pointCorner==0){
        //[fadePath lineToPoint: NSMakePoint(ox,high)];

        [fadePath lineToPoint: NSMakePoint(ox+roundingSize,high)];
        [fadePath lineToPoint: NSMakePoint(ox,taily)];
    }else{
        [fadePath appendBezierPathWithArcWithCenter:NSMakePoint(ox+roundingSize,high-roundingSize)
                                    radius: roundingSize
                                startAngle:90.0
                                    endAngle:180.0];
    }
    if(pointCorner==2){
        //[fadePath lineToPoint: NSMakePoint(ox,oy)];

        [fadePath lineToPoint: NSMakePoint(ox,taily)];
        [fadePath lineToPoint: NSMakePoint(ox+roundingSize,oy)];
    }else{
    [fadePath appendBezierPathWithArcWithCenter:NSMakePoint(ox+roundingSize,oy+roundingSize)
                                    radius: roundingSize
                                startAngle:180.0
                                    endAngle:270.0];
    }
    [fadePath closePath];
    [fadePath setLineWidth: 0.5];


   // [[NSColor clearColor] set];
   // NSRectFill(NSMakeRect(ox,oy,rect.size.width, rect.size.height));
    //[[NSGraphicsContext currentContext] saveGraphicsState];
    //[fadePath setClip];
    [[fadeColor colorWithAlphaComponent: fadeAlpha] set];
    //NSRectFill(rect);
    //[[NSGraphicsContext currentContext] restoreGraphicsState];
    [fadePath fill];
    //[[NSColor blackColor] set];
    //[fadePath stroke];
    
}

- (void) setIcon: (NSImage *) icon
{
    [icon retain];
    //NSLog(@"iconImage retainCount before release: %d",[iconImage retainCount]);
    [iconImage release];
    if(icon != iconImage)
        dirty=YES;
    iconImage=icon;
    if(dirty){
       // NSLog(@"set Icon: now dirty");
        [self recalcSize];
        [self display];
    }
}

- (void) setDrawString: (NSString *) newString
{
    [newString retain];
    //NSLog(@"myString retainCount before release: %d",[myString retainCount]);
    [myString release];
    if(newString != myString)
        dirty=YES;
    myString=newString;
    if(dirty){
        //NSLog(@"set draw string: now dirty");
        [self recalcSize];
        [self display];
    }
}


- (void) recalcSize
{
    NSRect pref = [self preferredFrame];
    //NSLog(@"recalc'd size: %@",NSStringFromRect(pref));
    if([self frame].size.width != pref.size.width || [self frame].size.height != pref.size.height){
        [self setFrame: pref];
        [[self window] setFrame: NSMakeRect([[self window] frame].origin.x,[[self window] frame].origin.y,pref.size.width,pref.size.height) display: NO];
    }
}

- (NSRect) preferredFrame
{
    NSSize textSize = [myString sizeWithAttributes: stringAttrs];
    if(iconImage!=nil){
        textSize.width+=36;
        if(textSize.height<32)
            textSize.height=32;
    }
    textSize.height+=tailLen;
    return NSMakeRect([self frame].origin.x,[self frame].origin.y,(int)ceil(((roundingSize - insetSize)*2) + textSize.width),(int)ceil(((roundingSize - insetSize)*2)+textSize.height));

}

- (void)drawRect:(NSRect)therect
{
    BOOL aa;
    NSRect rect = [self frame];
    NSPoint inside=NSMakePoint((roundingSize - insetSize)+2,2+(roundingSize - insetSize) + (pointCorner==2||pointCorner==3 ? tailLen: 0));
    if(dirty){
        [textArea setSize: NSMakeSize(rect.size.width+4,rect.size.height+4)];
        [textArea lockFocus];
        [[NSColor clearColor] set];
        NSRectFill(NSMakeRect(0,0,rect.size.width+4, rect.size.height+4));
        [self drawFadeFrame: NSMakeRect(2,2,rect.size.width,rect.size.height)];
        float xoff=0;
        float yoff=0;
        if(iconImage!=nil){
            NSSize textSize = [myString sizeWithAttributes: stringAttrs];

            [iconImage compositeToPoint: inside operation:NSCompositeSourceOver];
            xoff+=36;
            yoff+=(32 - textSize.height)/2;
        }
        aa = [[NSGraphicsContext currentContext] shouldAntialias];
        [[NSGraphicsContext currentContext] setShouldAntialias: YES];
        [myString drawAtPoint:NSMakePoint(inside.x+xoff-1,inside.y+yoff-1)
               withAttributes: shadowAttrs ];

        [myString drawAtPoint:NSMakePoint(inside.x+xoff,inside.y+yoff)
               withAttributes: stringAttrs ];

        [textArea unlockFocus];
        [[NSGraphicsContext currentContext] setShouldAntialias: aa];
        dirty=NO;
    }
    [[NSColor clearColor] set];
    NSRectFill(NSMakeRect(rect.origin.x-1,rect.origin.y-1,rect.size.width+1, rect.size.height+1));

    [[NSGraphicsContext currentContext] setShouldAntialias: NO];
    [textArea compositeToPoint:NSMakePoint(rect.origin.x-2,rect.origin.y-2) operation:NSCompositeSourceOver];
    if(pointCorner==1){
        //[[textArea TIFFRepresentation] writeToFile: [@"~/Desktop/test.tiff" stringByExpandingTildeInPath] atomically:YES];
    }

}

- (void) setFadeColor: (NSColor *) color
{
    [color retain];
    //NSLog(@"fadeColor retainCount before release: %d",[fadeColor retainCount]);
    [fadeColor release];
    fadeColor = color;
}
- (void) setFadeAlpha: (float) alpha
{
    fadeAlpha=alpha;
}

- (void) setPointCorner: (int) pCorner
{
    pointCorner=pCorner;
}

- (void) fadeOut
{

}

- (BOOL) isOpaque
{
    return NO;
}


@end
