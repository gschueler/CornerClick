//
//  BubbleView.m
//  CornerClick
//
//  Created by Greg Schueler on Fri Apr 30 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "BubbleView.h"


@implementation BubbleView 

- (id) initWithFrame: (NSRect) frame 
	andDrawingObject: (BubbleActionsList *)obj
{
    self = [self initWithFrame: frame
                     andDrawingObject: obj
                      fadeFrom: nil
                        fadeTo: nil
                    cornerSize: -1
                   pointCorner: -1];
	
    
    return self;
}

- (id) initWithFrame: (NSRect) frame 
	andDrawingObject: (BubbleActionsList *)obj
            fadeFrom: (NSColor *)fromCol
			  fadeTo: (NSColor *) toCol 
		  cornerSize: (float) cornerSize
         pointCorner: (int) pCorner

{
    //[self setAlphaValue: 0.5];
    //return self;
    
	
    if(self = [super initWithFrame: frame]){
        drawingObject = [obj retain];
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
            smallTextAttributes = [[BubbleView smallTextAttrs] retain];
        textArea = [[NSImage alloc] initWithSize: frame.size];
        if(fromCol!=nil){
            fadeFromColor = [fromCol retain];
        }else{
            fadeFromColor = [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha: 0.65] retain];
            //fadeFromColor = [[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha: 0.6] retain];
        }
        if(toCol!=nil){
            fadeToColor = [toCol retain];
        }else{
            fadeToColor = [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha: 0.25] retain];
            //fadeToColor = [[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha: 0.2] retain];
        }
        roundingSize= (cornerSize <= 0 ? 22 : cornerSize);
        insetSize = 10;
		//[drawingObject setSpacingSize: roundingSize-insetSize];
        pointCorner=pCorner;
        dirty=YES;
		[self setNeedsDisplay:YES];
        tailLen=30;
        drawHilite=NO;
    }else{
        NSLog(@"couldn't initWithFrame");
    }
    //[textContainert release];
    //[layoutManagert release];
	
    return self;
}

- (void) setDrawingObject: (BubbleActionsList *) o
{
	[o retain];
    DEBUG(@"drawingObject retainCount before release: %d",[drawingObject retainCount]);
    DEBUG(@"new drawingObject retainCount after retain: %d",[o retainCount]);
	[drawingObject release];
	drawingObject = o;
	dirty=YES;
	[self recalcSize];
	[self setNeedsDisplay:YES];
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

+ (NSDictionary *) normalTextAttrs
{
	return [NSDictionary dictionaryWithObjects:
		[NSArray arrayWithObjects: 
			[NSFont boldSystemFontOfSize: 32.0],
			[NSColor whiteColor],nil]
								 forKeys:
		[NSArray arrayWithObjects: NSFontAttributeName,
			NSForegroundColorAttributeName, nil]
		];
}

+ (NSDictionary *) smallTextAttrs
{
	return [NSDictionary dictionaryWithObjects:
		[NSArray arrayWithObjects: 
			[NSFont systemFontOfSize: 12.0],
			[NSColor whiteColor],nil]
									   forKeys:
		[NSArray arrayWithObjects: NSFontAttributeName,
			NSForegroundColorAttributeName, nil]
		];
}

+ (void) drawRoundedBezel: (NSRect) rect 
                 rounding:(float) theRounding
                    depth:(float) depth
{
    
    [BubbleView drawRoundedBezel: rect
                        rounding:theRounding
                           depth:depth
                         bgColor:[[NSColor blackColor] colorWithAlphaComponent:0.2]
                     shadowColor:[NSColor blackColor]
                      shineColor:[NSColor whiteColor]];
}
+ (void) drawRoundedBezel2: (NSRect) rect 
                  rounding:(float) theRounding
                     depth:(float) depth
                   bgColor:(NSColor *)bgcol 
               shadowColor:(NSColor *)shadow
                shineColor:(NSColor *)shine
{
    [BubbleView addShadow:[BubbleView roundedRect:rect rounding:theRounding]
                 rounding:theRounding
                    depth:depth
                  bgColor:bgcol
              shadowColor:shadow
               shineColor:shine];
}

+ (void) drawRoundedBezel: (NSRect) rect 
                 rounding:(float) theRounding
                    depth:(float) depth
                  bgColor:(NSColor *)bgcol 
              shadowColor:(NSColor *)shadow
               shineColor:(NSColor *)shine
{
    NSRect t = NSMakeRect(0,0,rect.size.width, rect.size.height);
    NSBezierPath *p = [BubbleView roundedRect:t rounding:theRounding];
    NSRect t1 = NSOffsetRect(t,depth,-depth);
    NSBezierPath *p1 = [BubbleView roundedRect:t1 rounding:theRounding];
    
    NSRect t2 = NSOffsetRect(t,-depth,depth);
    NSBezierPath *p2 = [BubbleView roundedRect:t2 rounding:theRounding];
    
    //[[bgcol colorWithAlphaComponent:0.2] set];
    [bgcol set];
    [[BubbleView roundedRect:rect rounding:theRounding] fill];
    
    NSImage *tempImg = [[[NSImage alloc] initWithSize:rect.size] autorelease];
    [tempImg lockFocus];
        [[NSColor clearColor] set];NSRectFill(t);
    [[NSColor blackColor] set];
    [p fill];
    
    NSImage *xi = [[[NSImage alloc] initWithSize:rect.size] autorelease];
    [xi lockFocus];
        [[NSColor clearColor] set];NSRectFill(t);
    [[NSColor blackColor] set];
    [p1 fill];
    [xi unlockFocus];
    
    [xi compositeToPoint:NSZeroPoint operation:NSCompositeDestinationOut];//subtract source from dest
    
    NSImage *temp2 = [[[NSImage alloc] initWithSize:rect.size] autorelease];
    [temp2 lockFocus];
    [[NSColor clearColor] set];
    NSRectFill(t);
    [[shadow colorWithAlphaComponent:0.3] set];
    NSRectFill(t);
    [temp2 unlockFocus];
    
    [temp2 compositeToPoint:NSZeroPoint operation:NSCompositeSourceIn];//fill dest with source
    
    [tempImg unlockFocus];
    [tempImg compositeToPoint:rect.origin operation:NSCompositeSourceOver];
    
    
    [tempImg lockFocus];
        [[NSColor clearColor] set];NSRectFill(t);
    [[NSColor blackColor] set];
    [p fill];
    
    [xi lockFocus];
        [[NSColor clearColor] set];NSRectFill(t);
    [[NSColor blackColor] set];
    [p2 fill];
    [xi unlockFocus];
    
    [xi compositeToPoint:NSZeroPoint operation:NSCompositeDestinationOut];//subtract source from dest
        
        
    [temp2 lockFocus];
        [[NSColor clearColor] set];NSRectFill(t);
    [[shine colorWithAlphaComponent:0.3] set];
    NSRectFill(t);
    [temp2 unlockFocus];
    
    [temp2 compositeToPoint:NSZeroPoint operation:NSCompositeSourceIn];
    [tempImg unlockFocus];
    [tempImg compositeToPoint:rect.origin operation:NSCompositeSourceOver];
    
}

+ (void) addShadow: (NSBezierPath *)path 
                 rounding:(float) theRounding
                    depth:(float) depth
                  bgColor:(NSColor *)bgcol 
              shadowColor:(NSColor *)shadow
               shineColor:(NSColor *)shine
{
    NSRect rect = [ path bounds ];
    //NSLog(@"shaddow rect bounds: %@",NSStringFromRect(rect));
    NSRect t = NSMakeRect(0,0,rect.size.width, rect.size.height);

    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:-1*rect.origin.x yBy:-1*rect.origin.y];
    
    
    NSBezierPath *p = [ [ path copyWithZone:nil ] autorelease];
    [p transformUsingAffineTransform:transform];
    
    transform = [NSAffineTransform transform];
    [transform translateXBy:depth yBy:-depth];
    

    NSBezierPath *p1 = [ [ path copyWithZone:nil ] autorelease];
    [p1 transformUsingAffineTransform:transform];
    NSRect t1 = NSOffsetRect(t,depth,-depth);
    //NSLog(@"p1 rect bounds: %@, t1 rect: %@",NSStringFromRect([p1 bounds]), NSStringFromRect(t1));
    
    transform = [NSAffineTransform transform];
    [transform translateXBy:-depth yBy:depth];
    NSBezierPath *p2 = [ [ path copyWithZone:nil ] autorelease ];
    [ p2 transformUsingAffineTransform:transform];
    NSRect t2 = NSOffsetRect(t,-depth,depth);
    //NSLog(@"p2 rect bounds: %@, t2 rect: %@",NSStringFromRect([p2 bounds]), NSStringFromRect(t2));
    
    //NSLog(@"Colors chosen: %@, %@, %@", [bgcol description], [shadow description], [shine description]);
        
    //[[bgcol colorWithAlphaComponent:0.2] set];
    [bgcol set];
    [path fill]; //draw background
    
    NSImage *tempImg = [[[NSImage alloc] initWithSize:rect.size] autorelease];
    [tempImg lockFocus];
    [[NSColor clearColor] set];NSRectFill(t);
    [[NSColor blackColor] set];
    [p fill];
    
    NSImage *xi = [[[NSImage alloc] initWithSize:rect.size] autorelease];
    [xi lockFocus];
    [[NSColor clearColor] set];NSRectFill(t);
    [[NSColor blackColor] set];
    [p1 fill];
    [xi unlockFocus];
    [[xi TIFFRepresentation] writeToFile:@"~/Desktop/test2.tiff" atomically:YES];
    
    [xi compositeToPoint:NSZeroPoint operation:NSCompositeDestinationOut];//subtract source from dest
        
        NSImage *temp2 = [[[NSImage alloc] initWithSize:rect.size] autorelease]; //shadow color
        [temp2 lockFocus];
        [[NSColor clearColor] set]; NSRectFill(t);
        [[shadow colorWithAlphaComponent:0.3] set];
        NSRectFill(t);
        [temp2 unlockFocus];
        
        [temp2 compositeToPoint:NSZeroPoint operation:NSCompositeSourceIn];//fill dest with source
            
            [tempImg unlockFocus];
            [tempImg compositeToPoint:rect.origin operation:NSCompositeSourceOver];//draw shadow
            
            
            [tempImg lockFocus];
            [[NSColor clearColor] set];NSRectFill(t);
            [[NSColor blackColor] set];
            [p fill];
            
            [xi lockFocus];
            [[NSColor clearColor] set];NSRectFill(t);
            [[NSColor blackColor] set];
            [p2 fill];
            [xi unlockFocus];
            
            [xi compositeToPoint:NSZeroPoint operation:NSCompositeDestinationOut];//subtract source from dest
                
                
                [temp2 lockFocus];
                [[NSColor clearColor] set];NSRectFill(t);
                [[shine colorWithAlphaComponent:0.3] set];
                NSRectFill(t);
                [temp2 unlockFocus];
                
                [temp2 compositeToPoint:NSZeroPoint operation:NSCompositeSourceIn];
                [tempImg unlockFocus];
                [tempImg compositeToPoint:rect.origin operation:NSCompositeSourceOver];
}

+ (NSBezierPath *)roundedRect: (NSRect)rect rounding: (float) theRounding
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
	return [fadePath autorelease];
}

- (void)drawRoundedRect: (NSRect)rect rounding: (float) theRounding alpha: (float) alpha color: (NSColor *) color
{
    NSBezierPath *fadePath=[BubbleView roundedRect:rect rounding:theRounding];
    [[color colorWithAlphaComponent: alpha] set];
    [fadePath fill];
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
    
    /*[BubbleView drawRoundedBezel:NSMakeRect(ox,oy,wide-ox,high-oy)
                        rounding:roundingSize 
                           depth:1.5
                         bgColor:[NSColor clearColor]
                     shadowColor:[NSColor whiteColor]
                      shineColor:[NSColor blackColor]];
*/
}



- (NSRect) preferredFrame
{
	return prefFrame;
}

- (void) recalcSize
{
    [self calcPreferredFrame];
}

- (void) calcPreferredFrame
{
    NSSize textSize;
	NSSize temp;
	int i;
	float x,y;
	float mwidth,mheight;
	mwidth=0;
	mheight=0;
	textSize = NSMakeSize(0,0);
	if(drawingObject!=nil){
		textSize = [drawingObject preferredSize];
		if([drawingObject selectedItem] >=0){
			int mods = [drawingObject selectedModifiers];
			int trig = [drawingObject selectedTrigger];
			NSLog(@"calc size for selected modifier: %d, and trigger: %d",mods,trig);
			NSString *label = [CornerClickSupport labelForModifiers:mods
														 andTrigger:trig
														localBundle:[NSBundle bundleForClass:[self class]]];
			NSSize tSize = [label sizeWithAttributes:[BubbleView smallTextAttrs]];
			textSize.height+= tSize.height+4;
			textSize.height+=(roundingSize - insetSize)+4;
			if(textSize.width < tSize.width+4)
				textSize.width = tSize.width+8;
		}
	}
		
    textSize.height+=(pointCorner>=0 ? tailLen : 0 );
	
    prefFrame= NSMakeRect([self frame].origin.x,[self frame].origin.y,
						  (int)ceil(((roundingSize - insetSize)*2) + textSize.width),
						  (int)ceil(((roundingSize - insetSize)*2)+textSize.height));
	
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
	NSPoint inside;
	float space = roundingSize - insetSize;
	float intHeight = rect.size.height-(int)ceil(space) - (pointCorner==2||pointCorner==3 ? 0:tailLen) ;
	float curHeight=intHeight;
	
	float tF;
	int i;
	
    if(dirty){
        [textArea setSize: NSMakeSize(rect.size.width,rect.size.height)];
        [textArea lockFocus];
		
        [[NSColor clearColor] set];
        NSRectFill(NSMakeRect(0,0,rect.size.width, rect.size.height));
        //draw the bubble background for the content
        [self drawFadeFrame: NSMakeRect(0,0,rect.size.width,rect.size.height)];
		
		//draw the selected modifiers label
		
		if([drawingObject selectedItem] >=0){
			NSString *label = [CornerClickSupport labelForModifiers:[drawingObject selectedModifiers]
														 andTrigger:[drawingObject selectedTrigger]
														localBundle:[NSBundle bundleForClass:[self class]]];
			
			NSSize tSize = [label sizeWithAttributes:[BubbleView smallTextAttrs]];
			
			NSRect toRect= NSMakeRect(rect.size.width/2 - tSize.width/2, intHeight - tSize.height - 4, tSize.width, tSize.height);
			NSRect outRect = NSMakeRect(space, intHeight - tSize.height - 8, rect.size.width-(space*2), tSize.height + 8);
            [BubbleView drawRoundedBezel:outRect
                                rounding:12
                                   depth:1.5];
			//NSBezierPath *outl = [BubbleView roundedRect:outRect rounding:12];
	//		tempImg = [[NSImage alloc] initWithSize:tSize];
	//		[tempImg lockFocus];
	//		[label drawAtPoint:NSZeroPoint withAttributes:[BubbleView smallTextAttrs]];
			[label drawAtPoint:toRect.origin withAttributes:[BubbleView smallTextAttrs]];
			//[tempImg unlockFocus];
			//[[[NSColor blackColor] colorWithAlphaComponent:0.5] set];
			//[outl fill];
//            [tempImg compositeToPoint:toRect.origin operation:NSCompositeSourceOver
  //                      fraction:1.0];
			//[tempImg drawInRect:toRect fromRect:NSMakeRect(0,0,tSize.width,tSize.height) operation:NSCompositeSourceOver fraction: 1.0];
	//		[tempImg release];
				
		}
		
		NSSize sz = NSMakeSize(0,0);
		if(drawingObject!=nil)
			sz = [drawingObject preferredSize];
		NSRect d= NSMakeRect(space, space + (pointCorner==2||pointCorner==3 ? tailLen : 0), rect.size.width-(space *2), sz.height);
		if(drawingObject!=nil)
			[drawingObject drawInRect:d];
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
	
	if(color!=fadeFromColor){
		NSColor *temp = [color copy];
		dirty=YES;
		[self setNeedsDisplay:YES];
		[fadeFromColor release];
		fadeFromColor = temp;
	}
}

- (void) setFadeToColor: (NSColor *) color
{
    if(color != fadeToColor){
		NSColor *temp = [color copy];
		dirty=YES;
		[self setNeedsDisplay:YES];
		[fadeToColor release];
		fadeToColor = temp;
	}
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
	[self setNeedsDisplay:YES];
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
    [drawingObject release];
    [fadeFromColor release];
    [fadeToColor release];
    [textArea release];
    [stringAttrs release];
    [shadowAttrs release];
    [smallTextAttributes release];
}



- (BubbleActionsList *) bubbleActionsList: (NSArray *)actions selected:(int) sel
						andHighlightColor:(NSColor *) theColor
{
	return [[[BubbleActionsList alloc] initWithAttributes: stringAttrs
                                      smallTextAttributes: smallTextAttributes
											   andSpacing: (roundingSize-insetSize)
											   andActions: actions
											 itemSelected: sel
										andHighlightColor: theColor ] autorelease];
}
- (BubbleAction *) bubbleAction: (NSArray *)actions
{
	return [[[BubbleAction alloc] initWithStringAttributes:stringAttrs
                                       smallTextAttributes: smallTextAttributes
												andSpacing:(roundingSize-insetSize) 
												andActions:actions] autorelease];
}

@end
