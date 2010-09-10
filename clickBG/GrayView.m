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
            fadeFrom: (NSColor *)fromCol fadeTo: (NSColor *) toCol cornerSize: (CGFloat) cornerSize
         pointCorner: (NSInteger) pCorner

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
            myString = [[NSString stringWithString:msg] retain];
            stringAttrs = [[NSDictionary dictionaryWithObjects:
                [NSArray arrayWithObjects: 
					[NSFont boldSystemFontOfSize: 32.0],
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
        [self setNeedsDisplay:YES];
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
    [self recalcSize];
}

- (void)drawRoundedRect: (NSRect)rect rounding: (CGFloat) theRounding alpha: (CGFloat) alpha color: (NSColor *) color
{
    NSBezierPath *fadePath;
    CGFloat ox=rect.origin.x;
    CGFloat oy=rect.origin.y;
    CGFloat wide=ox+rect.size.width;
    CGFloat high=oy+rect.size.height;
    CGFloat rounding=theRounding;
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
    CGFloat ox=0;
    CGFloat wide=rect.size.width;
    CGFloat high=roundingSize+2;
    
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
    CGFloat ox=rect.origin.x;
    CGFloat oy=rect.origin.y;
    CGFloat taily=oy;
    CGFloat wide=ox+rect.size.width;
    CGFloat high;
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

- (void) setActionsTemp: (NSArray *) theActions
{
	[theActions retain];
	[actions release];
	if(actions!=theActions){
		dirty=YES;
	}
	[self setIcon:nil];
	[self setDrawString:nil];
	actions=theActions;
	[self recalcSize];
	//[self display];
	[self setNeedsDisplay:YES];
}
- (void) setActions: (NSArray *) theActions
{
	[theActions retain];
	[actions release];
	if(actions!=theActions){
		dirty=YES;
	}
	actions=theActions;
	/*if(theActions !=nil && [theActions count] > 0){
		ClickAction *act = (ClickAction *)[theActions objectAtIndex:0];
		[self setIcon:[act icon]];
		[self setDrawString:[act label]];		
	}*/
	[self recalcSize];
	[self setNeedsDisplay:YES];
	//[self display];
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
        //[self display];
		[self setNeedsDisplay:YES];
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
        //[self display];
		[self setNeedsDisplay:YES];
    }
}

- (NSRect) preferredFrame
{
	return prefFrame;
}

- (void) recalcSize
{
    prefFrame = [self calcPreferredFrame];
    NSLog(@"recalc'd size: %@",NSStringFromRect(prefFrame));
    /*if([self frame].size.width != prefFrame.size.width || [self frame].size.height != prefFrame.size.height){
        [self setFrame: prefFrame];
        //[[self window] setFrame: NSMakeRect([[self window] frame].origin.x,[[self window] frame].origin.y,pref.size.width,pref.size.height) display: NO];
		[self setNeedsDisplay:YES];
    }*/
}

- (NSRect) calcPreferredFrame
{
    NSSize textSize;
	NSSize temp;
	NSInteger i;
	CGFloat x,y;
	CGFloat mwidth,mheight;
	mwidth=0;
	mheight=0;
	if(actions != nil){
		textSize=NSMakeSize(0,0);
		for(i=0;i<[actions count];i++){
			x=0;
			y=0;
			ClickAction* act = (ClickAction*)[actions objectAtIndex:i];
			if([act label]!=nil){
				temp = [[act label] sizeWithAttributes:stringAttrs];
				x = temp.width/2;
				y = temp.height/2;
			}
			if([act icon]!=nil){
				
					x+=36;
				if(y<32)
					y=32;
			}
			if(x>mwidth){
				mwidth=x;
			}
			mheight+=y;
			if(i>0)
				mheight+=(NSInteger)ceil(roundingSize - insetSize);
		}
		textSize.width=mwidth;
		textSize.height=mheight;
	}
    else{
			
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
	}
    textSize.height+=(pointCorner>=0 ? tailLen : 0 );
    return NSMakeRect([self frame].origin.x,[self frame].origin.y,(NSInteger)ceil(((roundingSize - insetSize)*2) + textSize.width),(NSInteger)ceil(((roundingSize - insetSize)*2)+textSize.height));

}

- (void) drawGradient2: (NSRect) therect fromColor:(NSColor *) fromCol toColor:(NSColor *) toCol
            direction: (NSInteger) dir
{
    //CGContext *ctx;


    //ctx = CGBitmapCreateContext(
}

- (void) drawGradient: (NSRect) therect fromColor:(NSColor *) fromCol toColor:(NSColor *) toCol
            direction: (NSInteger) dir
{
    NSInteger i=0;
    NSColor *tcol,*from,*to;
    from = [fromCol colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    to = [toCol colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    CGFloat dR = ([from redComponent] - [to redComponent])/therect.size.height;
    CGFloat dG = ([from greenComponent] - [to greenComponent])/therect.size.height;
    CGFloat dB = ([from blueComponent] - [to blueComponent])/therect.size.height;
    CGFloat dA = ([from alphaComponent] - [to alphaComponent])/therect.size.height;
    BOOL up = (dir > 0 ? YES : NO );
    NSInteger change;
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

- (void)drawAction:(NSString*)label withIcon:(NSImage*)icon atPoint:(NSPoint)inside
{
	BOOL aa;
    NSImage *tempImg;
    NSSize tSize;
	
	
	CGFloat xoff=0;
	CGFloat yoff=0;
	
	if(label == nil){
		tSize=NSMakeSize(0,0);
	}else{
		tSize=[label sizeWithAttributes: stringAttrs];
	}
	//draw an icon if it's set
	if(icon!=nil){
		xoff+=36;
		yoff+=(32 - (tSize.height/2))/2;
		[icon drawInRect:NSMakeRect(inside.x, inside.y, 32, 32) 
				fromRect:NSMakeRect(0,0,[icon size].width, [icon size].height)
			   operation:NSCompositeSourceOver
				fraction:1.0];
		//[icon compositeToPoint: inside operation:NSCompositeSourceOver];
	}
	
	if(label!=nil){
		//create a new image, draw double size text, composite at half size on top of bubble
		
		tempImg = [[NSImage alloc] initWithSize:tSize];
		[tempImg lockFocus];
		
		[[NSColor clearColor] set];
		NSRectFill(NSMakeRect(0,0,tSize.width,tSize.height));
		aa = [[NSGraphicsContext currentContext] shouldAntialias];
		[[NSGraphicsContext currentContext] setShouldAntialias: YES];
		
		
		[label drawAtPoint:NSZeroPoint withAttributes: stringAttrs ];
		
		[tempImg unlockFocus];
		
		[[NSGraphicsContext currentContext] setShouldAntialias: aa];
		
		//NSImageRep *brep = [tempImg bestRepresentationForDevice:nil];
		
		[tempImg  drawInRect:NSMakeRect(inside.x+xoff, inside.y+yoff, tSize.width/2,tSize.height/2)
					fromRect:NSMakeRect(0, 0, tSize.width, tSize.height)
				   operation:NSCompositeSourceOver
					fraction:1.0];
		[tempImg release];
	}
	
	
}

- (void)drawRect:(NSRect)therect
{
    NSRect rect = [self frame];
	NSPoint inside;
	CGFloat intHeight = rect.size.height-(NSInteger)ceil((roundingSize-insetSize)) - (pointCorner==2||pointCorner==3 ? 0:tailLen) ;
	CGFloat curHeight=intHeight;
	
	CGFloat tF;
	NSInteger i;
	
    if(dirty){
        [textArea setSize: NSMakeSize(rect.size.width,rect.size.height)];
        [textArea lockFocus];
		
        [[NSColor clearColor] set];
        NSRectFill(NSMakeRect(0,0,rect.size.width, rect.size.height));
        //draw the bubble background for the content
        [self drawFadeFrame: NSMakeRect(0,0,rect.size.width,rect.size.height)];
		
		
		if(actions==nil){
			inside=NSMakePoint((roundingSize - insetSize),(roundingSize - insetSize) + (pointCorner==2||pointCorner==3 ? tailLen: 0));
			[self drawAction:myString withIcon:iconImage atPoint:inside];
		}else{
			for(i=0;i<[actions count];i++){
				ClickAction *act = (ClickAction *)[actions objectAtIndex:i];
				tF=0;
				if([act label]!=nil){
					NSSize temp = [[act label] sizeWithAttributes:stringAttrs];
					tF = temp.height/2;
					
				}
				if([act icon] !=nil && tF<32){
					tF=32;
				}
				curHeight = curHeight-tF;
				if(i>0){
					curHeight-=(roundingSize -insetSize);
				}
				inside = NSMakePoint((roundingSize -insetSize), curHeight); 
				[self drawAction:[act label] withIcon:[act icon] atPoint:inside];
					
				
			}
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

- (void)drawRectOld:(NSRect)therect
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

        CGFloat xoff=0;
        CGFloat yoff=0;
        
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
    NSColor *temp = [color copy];
	
    //NSLog(@"fadeColor retainCount before release: %d",[fadeColor retainCount]);
    [fadeFromColor release];
    fadeFromColor = temp;
	dirty=YES;
	[self setNeedsDisplay:YES];
	
}

- (void) setFadeToColor: (NSColor *) color
{
    //NSColor *temp = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    //[temp retain];
	NSColor *temp = [color copy];
    //NSLog(@"fadeColor retainCount before release: %d",[fadeColor retainCount]);
	
    [fadeToColor release];
    fadeToColor = temp;
	[self setNeedsDisplay:YES];
	dirty=YES;
}
- (void) setPointCorner: (NSInteger) pCorner
{
    pointCorner=pCorner;
}

- (void) setShowModifiersTitle: (BOOL) showTitle
{
	showModifierTitle=showTitle;
}

- (void)setDrawHilite:(BOOL)draw
{
    drawHilite=draw;
}
- (BOOL)drawHilite
{
    return drawHilite;
}
- (BOOL) showModifiersTitle
{
	return showModifierTitle;
}

- (void) setInsetSize:(CGFloat) size
{
    insetSize=size;
    [self recalcSize];
    //[self display];
	[self setNeedsDisplay:YES];
}
- (CGFloat) insetSize
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
    [super dealloc];
}

@end
