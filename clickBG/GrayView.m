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
                      fadeFrom: nil
                        fadeTo: nil
                    cornerSize: -1
                   pointCorner: -1];
        
    
    return self;
}

- (id) initWithFrame: (NSRect) frame andString: (NSString *)msg andImage: (NSImage *) img
{
    self = [self initWithFrame: frame
                     andString: msg
                      andImage: img
                      fadeFrom: nil
                        fadeTo: nil
                    cornerSize: -1
                   pointCorner: -1];


    return self;
}
- (id) initWithFrame: (NSRect) frame andString: (NSString *)msg andImage: (NSImage *) img
            fadeFrom: (NSColor *)fromCol fadeTo: (NSColor *) toCol cornerSize: (float) cornerSize
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
                [NSArray arrayWithObjects: [NSFont boldSystemFontOfSize: 32.0],
                    [NSColor whiteColor],nil]
                                                       forKeys:
                [NSArray arrayWithObjects: NSFontAttributeName,
                    NSForegroundColorAttributeName, nil]
                ] retain];

            shadowAttrs = [[NSDictionary dictionaryWithObjects:
                [NSArray arrayWithObjects: [NSFont boldSystemFontOfSize: 32.0],
                    [NSColor blackColor],nil]
                                                       forKeys:
                [NSArray arrayWithObjects: NSFontAttributeName,
                    NSForegroundColorAttributeName, nil]
                ] retain];
        }else{
            myString=nil;
        }
        textArea = [[NSImage alloc] initWithSize: frame.size];
        if(fromCol!=nil){
            fadeFromColor = [fromCol retain];
        }else{
            fadeFromColor = [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha: 0.6] retain];
        }
        if(toCol!=nil){
            fadeToColor = [toCol retain];
        }else{
            fadeToColor = [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha: 0.2] retain];
        }
        roundingSize= (cornerSize <= 0 ? 22 : cornerSize);
        insetSize = 10;
        pointCorner=pCorner;
        dirty=YES;
        tailLen=30;
        drawHilite=NO;
    }else{
        NSLog(@"couldn't initWithFrame");
    }
    //[textContainert release];
    //[layoutManagert release];

    return self;
}

- (void) setDrawFont:(NSFont *) font color:(NSColor *) color
{

    NSDictionary *dict = [[NSDictionary dictionaryWithObjects:
        [NSArray arrayWithObjects: font,color,nil]
                                               forKeys:
        [NSArray arrayWithObjects: NSFontAttributeName,
            NSForegroundColorAttributeName, nil]
        ] retain];
    [stringAttrs release];
    stringAttrs=dict;
}

- (void)drawRoundedRect: (NSRect)rect rounding: (float) theRounding alpha: (float) alpha color: (NSColor *) color
{
    NSBezierPath *fadePath;
    float ox=rect.origin.x;
    float oy=rect.origin.y;
    float wide=ox+rect.size.width;
    float high=oy+rect.size.height;
    float rounding=theRounding;
    if(rounding > (rect.size.width/2) || rounding > (rect.size.height/2)){
        rounding = rect.size.height/2;
        if(rounding > rect.size.width/2)
            rounding= rect.size.width/2;
    }

    fadePath = [[NSBezierPath bezierPath] retain];
    [fadePath moveToPoint: NSMakePoint(wide-rounding,oy)];
        [fadePath appendBezierPathWithArcWithCenter:NSMakePoint(wide-rounding,rounding+oy)
                                             radius: rounding
                                         startAngle:270.0
                                           endAngle:0.0];
        [fadePath
appendBezierPathWithArcWithCenter:NSMakePoint(wide-rounding,high-rounding)
                           radius: rounding
                       startAngle:0.0
                         endAngle:90.0];
        [fadePath appendBezierPathWithArcWithCenter:NSMakePoint(ox+rounding,high-rounding)
                                             radius: rounding
                                         startAngle:90.0
                                           endAngle:180.0];
        [fadePath appendBezierPathWithArcWithCenter:NSMakePoint(ox+rounding,oy+rounding)
                                             radius: rounding
                                         startAngle:180.0
                                           endAngle:270.0];
    [fadePath closePath];
    //[fadePath setLineWidth: 0.5];


    // [[NSColor clearColor] set];
    // NSRectFill(NSMakeRect(ox,oy,rect.size.width, rect.size.height));
    //[[NSGraphicsContext currentContext] saveGraphicsState];
    //[fadePath setClip];
    [[color colorWithAlphaComponent: alpha] set];
    //NSRectFill(rect);
    //[[NSGraphicsContext currentContext] restoreGraphicsState];
    [fadePath fill];
    //[[NSColor blackColor] set];
    //[fadePath stroke];
    [fadePath release];
}

- (void)doDrawHilite: (NSRect) rect
{
    NSBezierPath *fadePath;
    NSImage *tempImg,*tempIn;
    tempIn = [[NSImage alloc] initWithSize: NSMakeSize(rect.size.width,roundingSize+2)];
    [tempIn lockFocus];
    float ox=0;
    float oy=0;
    float wide=rect.size.width;
    float high=roundingSize+2;
    
    fadePath = [[NSBezierPath bezierPath] retain];
    [fadePath moveToPoint: NSMakePoint(roundingSize,high)];

    [fadePath appendBezierPathWithArcWithCenter: NSMakePoint(roundingSize,high-roundingSize)
                                         radius: roundingSize
                                     startAngle: 90.0
                                       endAngle: 180.0];
    [fadePath lineToPoint: NSMakePoint(ox,high-roundingSize-2)];

    [fadePath appendBezierPathWithArcWithCenter: NSMakePoint(wide-roundingSize,high-roundingSize)
                                         radius: roundingSize
                                     startAngle: 45.00
                                       endAngle: 90.00];
    [fadePath closePath];

    [fadePath setLineWidth: 1];

    [[NSColor blackColor] set];
    [fadePath fill];
    [fadePath release];
    tempImg = [[NSImage alloc] initWithSize:rect.size];
    [tempImg lockFocus];
    [self drawGradient: NSMakeRect(0,0,rect.size.width,roundingSize+2)
             fromColor: [[NSColor whiteColor] colorWithAlphaComponent: 0.2]
               toColor: [[NSColor whiteColor] colorWithAlphaComponent: 0.0]
             direction: -1
        ];
    [tempImg unlockFocus];
    [tempImg compositeToPoint: NSZeroPoint operation:NSCompositeSourceIn];
    [tempImg release];
    [[NSColor redColor] set];
    //[fadePath stroke];
    [tempIn unlockFocus];
    [tempIn compositeToPoint: NSMakePoint(rect.origin.x,rect.origin.y+rect.size.height-roundingSize-2) operation:NSCompositeSourceOver];
    [tempIn release];
}


- (void)drawFadeFrame: (NSRect)rect
{
    NSBezierPath *fadePath;
    NSImage *tempImg;
    float ox=rect.origin.x;
    float oy=rect.origin.y;
    float taily=oy;
    float wide=ox+rect.size.width;
    float high;
    if(pointCorner==2 || pointCorner==3){
        oy+=tailLen;
        high = NSMaxY(rect);
    }
    else if(pointCorner==0 || pointCorner==1){
        taily=NSMaxY(rect);
        high = taily-tailLen;
    }else{
        taily=NSMaxY(rect);
        high = NSMaxY(rect);
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

    /*
    [[NSColor clearColor] set];
    NSRectFill(NSMakeRect(ox,oy,rect.size.width, rect.size.height));
    [[NSGraphicsContext currentContext] saveGraphicsState];
    [fadePath setClip];
    tempImg = [[NSImage alloc] initWithSize:NSMakeSize(rect.size.width,rect.size.height)];
    [tempImg lockFocus];
    [self drawGradient: NSMakeRect(0,0,rect.size.width,rect.size.height)
             fromColor: fadeFromColor
               toColor: fadeToColor
             direction: (pointCorner==2||pointCorner==3 ? -1 : 1)
        ];
    [tempImg unlockFocus];
    [tempImg compositeToPoint: NSZeroPoint operation:NSCompositeSourceIn];
    [tempImg release];
    [[NSGraphicsContext currentContext] restoreGraphicsState];
    [fadePath release];
     */
    

    [[NSColor blackColor] set];
    [fadePath fill];
    [fadePath release];
    tempImg = [[NSImage alloc] initWithSize:NSMakeSize(rect.size.width,rect.size.height)];
    [tempImg lockFocus];
    [self drawGradient: NSMakeRect(0,0,rect.size.width,rect.size.height)
             fromColor: fadeFromColor
               toColor: fadeToColor
             direction: (pointCorner==2||pointCorner==3 ? -1 : 1)
        ];
    [tempImg unlockFocus];
    [tempImg compositeToPoint: NSZeroPoint operation:NSCompositeSourceIn];
    [tempImg release];
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
    if([newString isEqualToString:@" "])
        myString=nil;
    else
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
    NSSize textSize;
    if(myString == nil){
        textSize=NSMakeSize(0,0);
    }else{
        textSize = [myString sizeWithAttributes: stringAttrs];
        textSize.width/=2;
        textSize.height/=2;
    }
    if(iconImage!=nil){
        textSize.width+=36;
        if(textSize.height<32)
            textSize.height=32;
    }
    textSize.height+=(pointCorner>=0 ? tailLen : 0 );
    return NSMakeRect([self frame].origin.x,[self frame].origin.y,(int)ceil(((roundingSize - insetSize)*2) + textSize.width),(int)ceil(((roundingSize - insetSize)*2)+textSize.height));

}

- (void) drawGradient2: (NSRect) therect fromColor:(NSColor *) fromCol toColor:(NSColor *) toCol
            direction: (int) dir
{
    //CGContext *ctx;


    //ctx = CGBitmapCreateContext(
}

- (void) drawGradient: (NSRect) therect fromColor:(NSColor *) fromCol toColor:(NSColor *) toCol
            direction: (int) dir
{
    int i=0;
    NSColor *tcol,*from,*to;
    from = [fromCol colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    to = [toCol colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    float dR = ([from redComponent] - [to redComponent])/therect.size.height;
    float dG = ([from greenComponent] - [to greenComponent])/therect.size.height;
    float dB = ([from blueComponent] - [to blueComponent])/therect.size.height;
    float dA = ([from alphaComponent] - [to alphaComponent])/therect.size.height;
    BOOL up = (dir > 0 ? YES : NO );
    int change;
    //NSLog(@"dir is %d, dR %f, dG %f, dB %f, dA %f",dir,dR,dG,dB,dA);


    for(i=0;i<therect.size.height;i++){
        change = (up?i : (therect.size.height-1)-i);
        tcol =[NSColor colorWithCalibratedRed: [from redComponent] - (change*dR)
                                   green: [from greenComponent] - (change*dG)
                                    blue: [from blueComponent] - (change*dB)
                                   alpha: [from alphaComponent] - (change*dA)
            ];
        [tcol set];
/*        NSLog(@"color %@\n values: %f, %f, %f, %f",tcol, [from redComponent] + (i*dR),
              [from greenComponent] + (i*dG),
              [from blueComponent] + (i * dB),
              [from alphaComponent] + (i * dA));
*/
        NSRectFill(NSMakeRect(0,i,therect.size.width,1));
    }
}

- (void)drawRect:(NSRect)therect
{
    BOOL aa;
    NSImage *tempImg;
    NSSize tSize;
    NSRect rect = [self frame];


    NSPoint inside=NSMakePoint((roundingSize - insetSize),(roundingSize - insetSize) + (pointCorner==2||pointCorner==3 ? tailLen: 0));

    if(dirty){
        [textArea setSize: NSMakeSize(rect.size.width,rect.size.height)];
        [textArea lockFocus];
        
        [[NSColor clearColor] set];
        NSRectFill(NSMakeRect(0,0,rect.size.width, rect.size.height));
        //draw the bubble background for the content
        [self drawFadeFrame: NSMakeRect(0,0,rect.size.width,rect.size.height)];

        float xoff=0;
        float yoff=0;
        
        if(myString == nil){
            tSize=NSMakeSize(0,0);
        }else{
            tSize=[myString sizeWithAttributes: stringAttrs];
        }
        //draw an icon if it's set
        if(iconImage!=nil){
            xoff+=36;
            yoff+=(32 - (tSize.height/2))/2;

            [iconImage compositeToPoint: inside operation:NSCompositeSourceOver];
        }
        
        if(myString!=nil){
            //create a new image, draw double size text, composite at half size on top of bubble
            
            tempImg = [[NSImage alloc] initWithSize:tSize];
            [tempImg lockFocus];
            
            [[NSColor clearColor] set];
            NSRectFill(NSMakeRect(0,0,tSize.width,tSize.height));
            aa = [[NSGraphicsContext currentContext] shouldAntialias];
            [[NSGraphicsContext currentContext] setShouldAntialias: YES];
    
            
                [myString drawAtPoint:NSZeroPoint withAttributes: stringAttrs ];
            
            [tempImg unlockFocus];
    
            [[NSGraphicsContext currentContext] setShouldAntialias: aa];
            
            //NSImageRep *brep = [tempImg bestRepresentationForDevice:nil];
            
            [tempImg  drawInRect:NSMakeRect(inside.x+xoff, inside.y+yoff, tSize.width/2,tSize.height/2)
                                fromRect:NSMakeRect(0, 0, tSize.width, tSize.height)
                                operation:NSCompositeSourceOver
                                fraction:1.0];
            [tempImg release];
        }

        if(drawHilite){
            [self doDrawHilite:NSMakeRect(rect.origin.x,rect.origin.y+(pointCorner==2||pointCorner==3 ? tailLen : 0),
                                          rect.size.width,rect.size.height-(pointCorner>=0? tailLen : 0))];
        }
        [textArea unlockFocus];
        dirty=NO;
    }
    [[NSColor clearColor] set];
    NSRectFill(rect);

    [[NSGraphicsContext currentContext] setShouldAntialias: NO];
    [textArea compositeToPoint:NSMakePoint(rect.origin.x,rect.origin.y) operation:NSCompositeSourceOver];

    if(DEBUG_ON){
        if(pointCorner==1){
            [[textArea TIFFRepresentation] writeToFile: [@"~/Desktop/test.tiff" stringByExpandingTildeInPath] atomically:YES];
        }
    }

}

- (void) setFadeFromColor: (NSColor *) color
{
    NSColor *temp = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    [temp retain];
    //NSLog(@"fadeColor retainCount before release: %d",[fadeColor retainCount]);
    [fadeFromColor release];
    fadeFromColor = temp;
}

- (void) setFadeToColor: (NSColor *) color
{
    NSColor *temp = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    [temp retain];
    //NSLog(@"fadeColor retainCount before release: %d",[fadeColor retainCount]);
    [fadeToColor release];
    fadeToColor = temp;
}
- (void) setPointCorner: (int) pCorner
{
    pointCorner=pCorner;
}

- (void)setDrawHilite:(BOOL)draw
{
    drawHilite=draw;
}
- (BOOL)drawHilite
{
    return drawHilite;
}

- (void) setInsetSize:(float) size
{
    insetSize=size;
    [self recalcSize];
    [self display];
}
- (float) insetSize
{
    return insetSize;
}

- (void) fadeOut
{

}

- (BOOL) isOpaque
{
    return NO;
}


- (void) dealloc
{
    [iconImage release];
    [fadeFromColor release];
    [fadeToColor release];
    [textArea release];
    [myString release];
    [stringAttrs release];
    [shadowAttrs release];
}

@end
