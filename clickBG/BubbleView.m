//
//  BubbleView.m
//  CornerClick
//
//  Created by Greg Schueler on Fri Apr 30 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "BubbleView.h"

void CCShadeInterpolate( void *info, float const *inData, float *outData ) {
	float *colors = (float *)info;
	register float a = inData[0], a_coeff = 1.0f - a;
	register int i = 0;
    
	for( i = 0; i < 4; i++ )
		outData[i] = a_coeff * colors[i] + a * colors[i + 4];
}

@interface BubbleView (InternalMethods)
- (void) clearBG;
+ (void) resetNormalTextAttrs;
@end

static NSDictionary *normalTextAttrs;

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
        fadedFrame=nil;
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
    if(o!= drawingObject){
        [o retain];
        DEBUG(@"drawingObject retainCount before release: %d",[drawingObject retainCount]);
        DEBUG(@"new drawingObject retainCount after retain: %d",[o retainCount]);
        [drawingObject release];
        drawingObject = o;
        dirty=YES;
        [self recalcSize];
        [self setNeedsDisplayInRect:[self frame]];
    }
}

- (BubbleActionsList *) drawingObject{
    return [[drawingObject retain] autorelease];
}

- (NSRect) modifiersRect
{
    NSRect rect = [self frame];
	float space = roundingSize - insetSize;
	float intHeight = rect.size.height-(int)ceil(space) - (pointCorner==2||pointCorner==3 ? 0:tailLen) ;

    NSString *label = [CornerClickSupport labelForModifiers:[drawingObject selectedModifiers]
                                                 andTrigger:[drawingObject selectedTrigger]
                                                localBundle:[NSBundle bundleForClass:[self class]]];
    
    NSSize tSize = [label sizeWithAttributes:[BubbleView smallTextAttrs]];
    
    NSRect outRect = NSMakeRect(space, intHeight - tSize.height - 8, rect.size.width-(space*2), tSize.height + 8);
    return outRect;
}

-(NSRect) innerContentRect
{
    NSRect rect = [self frame];
    NSSize tSize = NSMakeSize(0,0);
	float space = roundingSize - insetSize;
    if(drawingObject!=nil)
        tSize = [drawingObject preferredSize];
    return NSMakeRect(space, space + (pointCorner==2||pointCorner==3 ? tailLen : 0), rect.size.width-(space *2), tSize.height);
}

- (void) newSelectedMod: (int) ndx
{
    int old = [drawingObject selectedItem];
    NSRect inner = [self innerContentRect];
    NSRect oldR = [drawingObject drawingRectForAction:old isSelected:YES inRect: inner];
    NSRect newR = [drawingObject drawingRectForAction:ndx isSelected:YES inRect: inner];
    [self setNeedsDisplayInRect:oldR];
    [self setNeedsDisplayInRect:newR];
    [drawingObject updateSelected: ndx];
    [self setNeedsDisplayInRect:[self modifiersRect]];
}

- (void) setDrawFont:(NSFont *) font color:(NSColor *) color
{
	
    
}

+ (NSDictionary *) normalTextAttrs
{
    @synchronized(self){
    
        if(normalTextAttrs==nil){
            
            NSShadow *textShad = [[[NSShadow alloc] init] autorelease];
            [textShad setShadowOffset:NSMakeSize(3,-3)];
            [textShad setShadowBlurRadius:1.5];
            
            normalTextAttrs= [[NSDictionary dictionaryWithObjects:
                [NSArray arrayWithObjects: 
                    [NSFont boldSystemFontOfSize: [[CornerClickSettings sharedSettings] textSize]],
                    [NSColor whiteColor],
                    textShad ,
                    nil]
                                         forKeys:
                [NSArray arrayWithObjects:
                    NSFontAttributeName,
                    NSForegroundColorAttributeName, 
                    NSShadowAttributeName, 
                    nil]
                ] retain];
        }
    }
    return [[normalTextAttrs retain] autorelease];
}

+ (NSDictionary *) smallTextAttrs
{
    NSShadow *textShad = [[[NSShadow alloc] init] autorelease];
    [textShad setShadowOffset:NSMakeSize(3,-3)];
    [textShad setShadowBlurRadius:1];
	return [NSDictionary dictionaryWithObjects:
		[NSArray arrayWithObjects: 
			[NSFont systemFontOfSize: 12.0],
			[NSColor whiteColor],textShad ,nil]
									   forKeys:
		[NSArray arrayWithObjects: NSFontAttributeName,
			NSForegroundColorAttributeName,NSShadowAttributeName, nil]
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
+ (void) drawRoundedBezel: (NSRect) rect 
                  rounding:(float) theRounding
                     depth:(float) depth
                   bgColor:(NSColor *)bgcol 
               shadowColor:(NSColor *)shadow
                shineColor:(NSColor *)shine
{
    [BubbleView addShadow:[BubbleView roundedRect:rect rounding:theRounding]
                    depth:depth
                  bgColor:bgcol
              shadowColor:shadow
               shineColor:shine];
}

+ (void) drawRoundedBezel2: (NSRect) rect 
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
+ (void) addGlassBG:(NSRect) therect withColor: (NSColor *)thecolor withRounding: (float) rounding
{
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    thecolor = [thecolor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    float inset = 0;
    rounding = rounding - inset;
    NSRect inRect = NSInsetRect(therect,inset,inset);
    float width = therect.size.width - 2. * inset;
    float height = therect.size.height - 2. * inset;
    float ox = inset;
    float oy = inset;
    
    float midx = width/2. + therect.origin.x + ox;
    float upy = height/2. + therect.origin.y + oy;
    float dy = MIN(20.,height/6.);
    float t1 = atan2(width/2.,dy); // angle for one part of isoceles triangle.
    float h1 = sqrt( dy*dy + (width * width / 4.)); //base of isoceles
    float rad = (1./cos( t1))  * (h1/2.); //radius of arc
    
    [path moveToPoint:NSMakePoint(NSMaxX(inRect),upy)];
    
    float angrad = pi - 2. * t1;
    float angdeg = 360. * (angrad / (2.*pi));
    //NSLog(@"angle is: %f",angdeg);
    [path appendBezierPathWithArcWithCenter:NSMakePoint(midx, upy  + dy - rad )
                                     radius:rad
                                 startAngle:(90.0 - angdeg)
                                   endAngle:(90.0 + angdeg)];
    
    [path lineToPoint:NSMakePoint(NSMinX(inRect),NSMaxY(inRect))];
    [path lineToPoint:NSMakePoint(NSMaxX(inRect),NSMaxY(inRect))];
    [path closePath];
    
    // light gleam upwards from curve across center
    [[NSGraphicsContext currentContext] saveGraphicsState];
    [path addClip];
    [BubbleView drawGradient:NSMakeRect(inRect.origin.x, upy, width,  upy-inRect.origin.y)
                   fromColor:[thecolor colorWithAlphaComponent:0.05]
                     toColor:[thecolor colorWithAlphaComponent:0.0]
                   fromPoint:NSMakePoint(inRect.origin.x,upy)
                     toPoint:NSMakePoint(inRect.origin.x,upy + MIN(NSMaxY(inRect)-upy,40.))
                extendBefore:NO
                 extendAfter:YES
        
        ];
    [[NSGraphicsContext currentContext] restoreGraphicsState];
    // */
        
        // dark gleam downwards from curve across center
        
        path =    [NSBezierPath bezierPath];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(midx, upy  + dy - rad )
                                         radius:rad
                                     startAngle:(90.0 - angdeg)
                                       endAngle:(90.0 + angdeg)];
        [path lineToPoint:inRect.origin];
        [path lineToPoint:NSMakePoint(NSMaxX(inRect),NSMinY(inRect))];
        [path closePath];
        
        [[NSGraphicsContext currentContext] saveGraphicsState];
        [path addClip];
        [BubbleView drawGradient:NSMakeRect(inRect.origin.x, upy, width,  upy-inRect.origin.y)
                       fromColor:[NSColor colorWithCalibratedRed:0. green:0 blue: 0 alpha:0.05]
                         toColor:[NSColor colorWithCalibratedRed:0. green:0 blue: 0 alpha:0.0]
                       fromPoint:NSMakePoint(inRect.origin.x,upy + dy)
                         toPoint:inRect.origin
                    extendBefore:NO
                     extendAfter:YES
            
            ];
        [[NSGraphicsContext currentContext] restoreGraphicsState];
        // */
            
            
            if(rounding > 0. ){
                float minset=0;
                float tilt= (2*rounding) * (2 * rounding) / (inRect.size.width - 2* minset); 
                tilt = tilt / 3.;
                
                NSRect ar = NSMakeRect(inRect.origin.x+minset, NSMinY(inRect) , inRect.size.width-2*minset, 2 * rounding);
                path = [BubbleView roundedRect:ar rounding:rounding - minset];
                
                //add bottom under-shadow
                [[NSGraphicsContext currentContext] saveGraphicsState];
                [path addClip];
                [BubbleView drawGradient:inRect
                               fromColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.1]
                                 toColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.0]
                               fromPoint:NSMakePoint(inRect.origin.x + inRect.size.width,NSMinY(inRect))
                                 toPoint:NSMakePoint(inRect.origin.x + inRect.size.width - tilt, NSMinY(inRect) - 5 + 2 * rounding )
                            extendBefore:NO
                             extendAfter:YES
                    
                    ];
                [[NSGraphicsContext currentContext] restoreGraphicsState];
            }
}
+ (void) addGlassFG:(NSRect) therect withColor: (NSColor *)thecolor withRounding: (float) rounding
{
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    thecolor = [thecolor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    float inset = 0;
    rounding = rounding - inset;
    NSRect inRect = NSInsetRect(therect,inset,inset);
    if(rounding > 0.){
        float minset=0;
        float tilt= (2*rounding) * (2 * rounding) / (inRect.size.width - 2* minset); 
        tilt = tilt / 3.;
        
        NSRect ar = NSMakeRect(inRect.origin.x+minset, NSMaxY(inRect) - 2 * rounding - minset, inRect.size.width-2*minset, 2 * rounding);
        path = [BubbleView roundedRect:ar rounding:rounding - minset];
        
        //add top over-gleam
        [[NSGraphicsContext currentContext] saveGraphicsState];
        [path addClip];
        [BubbleView drawGradient:inRect
                       fromColor:[thecolor colorWithAlphaComponent:0.4]
                         toColor:[thecolor colorWithAlphaComponent:0.0]
                       fromPoint:NSMakePoint(inRect.origin.x,NSMaxY(inRect) - minset)
                         toPoint:NSMakePoint(inRect.origin.x + tilt ,NSMaxY(inRect) - 2 * rounding + 5 -minset)
                    extendBefore:NO
                     extendAfter:YES
            
            ];
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    }
}
+ (void) addGlass:(NSRect) therect{
    [BubbleView addGlass: therect withColor: [NSColor colorWithCalibratedRed:1. green:1. blue:1. alpha:0.2]
            withRounding:0];
}
+ (void) addGlass:(NSRect) therect withColor: (NSColor *)thecolor withRounding: (float) rounding
{
    [BubbleView addGlassBG: therect withColor: thecolor withRounding: rounding];
    [BubbleView addGlassFG: therect withColor: thecolor withRounding: rounding];
}
+ (void) drawGradient:(NSRect) therect fromColor:(NSColor *) fromCol toColor:(NSColor *) tocol
            direction: (int) dir
{
    BOOL up = (dir > 0 ? YES : NO );
    [BubbleView drawGradient: therect fromColor: fromCol toColor: tocol
             fromPoint: NSMakePoint(NSMinX(therect), up ? NSMinY(therect) : NSMaxY(therect))
               toPoint: NSMakePoint(NSMinX(therect), up ? NSMaxY(therect) : NSMinY(therect))];
}

+ (void) drawGradient:(NSRect) therect fromColor: (NSColor *) fromCol toColor:(NSColor *) tocol
            fromPoint:(NSPoint) sPoint toPoint: (NSPoint) ePoint
{
    [BubbleView drawGradient:therect
                   fromColor:fromCol
                     toColor:tocol
                   fromPoint:sPoint
                     toPoint:ePoint
                extendBefore:NO
                 extendAfter:NO];
}

+ (void) drawGradient:(NSRect) therect fromColor: (NSColor *) fromCol toColor:(NSColor *) tocol
            fromPoint:(NSPoint) sPoint toPoint: (NSPoint) ePoint extendBefore:(BOOL)ebefore extendAfter:(BOOL)eafter
{
    float colarr[8];
    
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
	//[path setClip];
    
    colarr[0] = [fromCol redComponent];
    colarr[1] = [fromCol greenComponent];
    colarr[2] = [fromCol blueComponent];
    colarr[3] = [fromCol alphaComponent];
    colarr[4] = [tocol redComponent];
    colarr[5] = [tocol greenComponent];
    colarr[6] = [tocol blueComponent];
    colarr[7] = [tocol alphaComponent];
    
	struct CGFunctionCallbacks callbacks = { 0, CCShadeInterpolate, NULL };
    
	CGFunctionRef function = CGFunctionCreate( &colarr, 1, NULL, 4, NULL, &callbacks );
	CGColorSpaceRef cspace = CGColorSpaceCreateDeviceRGB();
    
	float srcX = sPoint.x, srcY = sPoint.y;
	float dstX = ePoint.x, dstY = ePoint.y;
	CGShadingRef shading = CGShadingCreateAxial( cspace, 
												 CGPointMake( srcX, srcY ), 
												 CGPointMake( dstX, dstY ), 
												 function, 
                                                 ebefore ? true : false, 
                                                 eafter? true : false );	
    
	CGContextDrawShading( [[NSGraphicsContext currentContext] graphicsPort], shading );
    
	CGShadingRelease( shading );
	CGColorSpaceRelease( cspace );
	CGFunctionRelease( function );
    
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

+ (void) addShadow: (NSBezierPath *)path 
             depth:(float) depth
{
    [BubbleView addShadow: path
                    depth: depth
                  bgColor:[[NSColor blackColor] colorWithAlphaComponent:0.2]
              shadowColor:[NSColor blackColor]
               shineColor:[NSColor whiteColor]];
}

+ (void) addShadow: (NSBezierPath *)path 
                    depth:(float) depth
                  bgColor:(NSColor *)bgcol 
              shadowColor:(NSColor *)shadow
               shineColor:(NSColor *)shine
{
    NSRect rect = [ path bounds ];
    //NSLog(@"shaddow rect bounds: %@",NSStringFromRect(rect));
    NSRect t = NSMakeRect(0,0,rect.size.width, rect.size.height);

    NSAffineTransform *originXform = [NSAffineTransform transform];
    [originXform translateXBy:-1*rect.origin.x yBy:-1*rect.origin.y];
    
    
    NSBezierPath *p = [ [ path copyWithZone:nil ] autorelease];
    [p transformUsingAffineTransform: originXform];
    //NSLog(@"copied path translated rect bounds: %@",NSStringFromRect([p bounds]));
    
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:depth yBy:-depth];
    

    NSBezierPath *p1 = [ [ path copyWithZone:nil ] autorelease];
    [p1 transformUsingAffineTransform: originXform];
    [p1 transformUsingAffineTransform: transform];
   // NSLog(@"p1 rect bounds: %@, t1 rect: %@",NSStringFromRect([p1 bounds]), NSStringFromRect(t1));
    
    transform = [NSAffineTransform transform];
    [transform translateXBy:-depth yBy:depth];
    NSBezierPath *p2 = [ [ path copyWithZone:nil ] autorelease ];
    [ p2 transformUsingAffineTransform:originXform];
    [ p2 transformUsingAffineTransform:transform];
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
    return [BubbleView roundedRect: rect roundingTopLeft: theRounding roundingTopRight:theRounding
                roundingBottomLeft:theRounding roundingBottomRight:theRounding];
}
+ (NSBezierPath *)roundedRect: (NSRect)rect roundingTopLeft: (float) roundTL roundingTopRight: (float) roundTR
           roundingBottomLeft: (float)roundBL roundingBottomRight: (float) roundBR
{
    NSBezierPath *fadePath;
    float ox=rect.origin.x;
    float oy=rect.origin.y;
    float wide=ox+rect.size.width;
    float high=oy+rect.size.height;

    if(roundTL > (rect.size.width/2) || roundTL > (rect.size.height/2)){
        roundTL = rect.size.height/2;
        if(roundTL > rect.size.width/2)
            roundTL= rect.size.width/2;
    }
    if(roundTR > (rect.size.width/2) || roundTR > (rect.size.height/2)){
        roundTR = rect.size.height/2;
        if(roundTR > rect.size.width/2)
            roundTR= rect.size.width/2;
    }
    if(roundBL > (rect.size.width/2) || roundBL > (rect.size.height/2)){
        roundBL = rect.size.height/2;
        if(roundBL > rect.size.width/2)
            roundBL= rect.size.width/2;
    }
    if(roundBR > (rect.size.width/2) || roundBR > (rect.size.height/2)){
        roundBR = rect.size.height/2;
        if(roundBR > rect.size.width/2)
            roundBR= rect.size.width/2;
    }
	
    fadePath = [[NSBezierPath bezierPath] retain];
    [fadePath moveToPoint: NSMakePoint(wide-roundBR,oy)];
	[fadePath appendBezierPathWithArcWithCenter:NSMakePoint(wide-roundBR,roundBR+oy)
										 radius: roundBR
									 startAngle:270.0
									   endAngle:0.0];
	[fadePath
appendBezierPathWithArcWithCenter:NSMakePoint(wide-roundTR,high-roundTR)
                           radius: roundTR
                       startAngle:0.0
                         endAngle:90.0];
	[fadePath appendBezierPathWithArcWithCenter:NSMakePoint(ox+roundTL,high-roundTL)
										 radius: roundTL
									 startAngle:90.0
									   endAngle:180.0];
	[fadePath appendBezierPathWithArcWithCenter:NSMakePoint(ox+roundBL,oy+roundBL)
										 radius: roundBL
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
    [BubbleView drawGradient: NSMakeRect(0,0,rect.size.width,roundingSize+2)
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
	//[fadePath fill];   
    //tempImg = [[NSImage alloc] initWithSize:NSMakeSize(rect.size.width,rect.size.height)];
    //[tempImg lockFocus];
    [[NSGraphicsContext currentContext] saveGraphicsState];
    [fadePath setClip];
    [BubbleView drawGradient: rect
             fromColor: [CornerClickSettings defaultBubbleColorA] //fadeFromColor
               toColor: [CornerClickSettings defaultBubbleColorB]
             fromPoint: rect.origin
               toPoint: NSMakePoint(NSMinX(rect),NSMaxY(rect))

        ];
    [BubbleView addGlass:NSMakeRect(ox,oy,wide-ox,high-oy)
               withColor:[NSColor colorWithCalibratedRed:1.
                                                   green:1.
                                                    blue:1.
                                                   alpha:0.2]
            withRounding:roundingSize];
    [[NSGraphicsContext currentContext] restoreGraphicsState];
    //[tempImg unlockFocus];
    //[tempImg compositeToPoint: NSZeroPoint operation:NSCompositeSourceIn];
    //[tempImg release];
    
    /*[BubbleView addShadow:fadePath
                    depth:-1.5
                  bgColor:[NSColor clearColor]
              shadowColor:[NSColor blackColor]
               shineColor:[NSColor whiteColor]];*/
    [fadePath release];

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
    NSRect oldPref=prefFrame;
    [self calcPreferredFrame:YES];
    if(!NSEqualRects(oldPref,prefFrame)){
        [self clearBG];
    }
    [BubbleView resetNormalTextAttrs];
}
+ (void) resetNormalTextAttrs
{
    @synchronized(self){
        [normalTextAttrs release];
        normalTextAttrs=nil;
    }
}

- (void) calcPreferredFrame
{
    [self calcPreferredFrame:NO];
}
- (void) calcPreferredFrame:(BOOL) recalc
{
    NSSize textSize;
	float mwidth,mheight;
    float space = roundingSize-insetSize;
	mwidth=0;
	mheight=0;
	textSize = NSMakeSize(0,0);
	if(drawingObject!=nil){
        if(recalc)
            [drawingObject calcPreferredSize:recalc];
		textSize = [drawingObject preferredSize];
		if([drawingObject selectedItem] >=0){
			int mods = [drawingObject selectedModifiers];
			int trig = [drawingObject selectedTrigger];
			DEBUG(@"calc size for selected modifier: %d, and trigger: %d",mods,trig);
			NSString *label = [CornerClickSupport labelForModifiers:mods
														 andTrigger:trig
														localBundle:[NSBundle bundleForClass:[self class]]];
			NSSize tSize = [label sizeWithAttributes:[BubbleView smallTextAttrs]];
			textSize.height+= tSize.height+4;
			textSize.height+=space+4;
			if(textSize.width < tSize.width+4)
				textSize.width = tSize.width+8;
		}
	}
		
    textSize.height+=(pointCorner>=0 ? tailLen : 0 );
	
    prefFrame= NSMakeRect([self frame].origin.x,[self frame].origin.y,
						  (int)ceil(((roundingSize - insetSize)*2) + textSize.width),
						  (int)ceil(((roundingSize - insetSize)*2)+textSize.height));
	
}

- (void) drawGradientX: (NSRect) therect fromColor:(NSColor *) fromCol toColor:(NSColor *) toCol
            direction: (int) dir
{
    int i=0;
    NSColor *tcol,*from,*to;
    from = [fromCol colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    to = [toCol colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    BOOL up = (dir > 0 ? YES : NO );
    int change;
    //NSLog(@"dir is %d, dR %f, dG %f, dB %f, dA %f",dir,dR,dG,dB,dA);
	
	float fract;
    for(i=0;i<therect.size.height;i++){
        change = (up?i : (therect.size.height-1)-i);
        fract = (up?i/therect.size.height: (therect.size.height - i)/therect.size.height);
        tcol = [from blendedColorWithFraction:fract ofColor:to];
        [tcol set];
        NSRectFill(NSMakeRect(0,i,therect.size.width,1));
    }
}


- (void) clearBG
{
    [fadedFrame release];
    fadedFrame =nil;
}

- (void) drawBG: (NSRect) therect
{
    
    
    NSRect rect = [self frame];
    [[NSColor clearColor] set];
    NSRectFill(therect);
    //draw the bubble background for the content
    if(fadedFrame==nil){
        fadedFrame = [[NSImage alloc] initWithSize:NSMakeSize(rect.size.width, rect.size.height)];
        [fadedFrame lockFocus];
        [self drawFadeFrame: NSMakeRect(0,0,rect.size.width,rect.size.height)];            
        [fadedFrame unlockFocus];
    }
    [fadedFrame compositeToPoint:rect.origin operation:NSCompositeSourceOver];
}

- (void)drawRect:(NSRect)therect
{
       NSRect rect = [self frame];
	float space = roundingSize - insetSize;
	float intHeight = rect.size.height-(int)ceil(space) - (pointCorner==2||pointCorner==3 ? 0:tailLen) ;
    
    [self drawBG: therect];
    
    //draw the selected modifiers label
    
    if([drawingObject selectedItem] >=0 && NSIntersectsRect(therect,[self modifiersRect])){
            
        NSString *label = [CornerClickSupport labelForModifiers:[drawingObject selectedModifiers]
                                                     andTrigger:[drawingObject selectedTrigger]
                                                    localBundle:[NSBundle bundleForClass:[self class]]];
        
        NSSize tSize = [label sizeWithAttributes:[BubbleView smallTextAttrs]];
        
        NSRect toRect= NSMakeRect(rect.size.width/2 - tSize.width/2, intHeight - tSize.height - 4, tSize.width, tSize.height);
        NSRect outRect = NSMakeRect(space, intHeight - tSize.height - 8, rect.size.width-(space*2), tSize.height + 8);
        [BubbleView drawRoundedBezel:outRect
                            rounding:9
                               depth:1];
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
    NSRect d = [self innerContentRect];
    /*
    tSize = NSMakeSize(0,0);
    if(drawingObject!=nil)
        tSize = [drawingObject preferredSize];
    NSRect d= NSMakeRect(space, space + (pointCorner==2||pointCorner==3 ? tailLen : 0), rect.size.width-(space *2), tSize.height);
     */
    if(drawingObject!=nil)
        [drawingObject drawInRect:NSIntersectionRect(therect,d)];

    dirty=NO;
    
#ifdef WRITE_BUBBLES
    NSBitmapImageRep *rep = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:[self frame]] autorelease];
            [[rep TIFFRepresentation] writeToFile: [@"~/Desktop/test.tiff" stringByExpandingTildeInPath] atomically:YES];
#endif
	
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
- (float) roundingSize
{
    return roundingSize;
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
    [fadedFrame release];
    [shadowAttrs release];
}



- (BubbleActionsList *) bubbleActionsList: (NSArray *)actions 
                                forCorner: (int) corn
                                 selected:(int) sel
						andHighlightColor:(NSColor *) theColor
{
	return [[[BubbleActionsList alloc] initWithSpacing: (roundingSize-insetSize)
											   andActions: actions
											 itemSelected: sel
										andHighlightColor: theColor 
                                                forCorner: corn] autorelease];
}
- (BubbleAction *) bubbleAction: (NSArray *)actions
{
	return [[[BubbleAction alloc] initWithSpacing:(roundingSize-insetSize) 
												andActions:actions] autorelease];
}

@end
