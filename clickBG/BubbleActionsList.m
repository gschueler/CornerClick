//
//  BubbleActionsList.m
//  CornerClick
//
//  Created by Greg Schueler on Fri Apr 30 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "BubbleActionsList.h"

@interface BubbleActionsList (InternalMethods)

- (void) drawSelectedInFrame:(NSRect) rect;
- (void) drawSelectedInFrame:(NSRect) rect isLast: (BOOL) last;

- (void) drawSelectedOverlayInFrame:(NSRect) rect isLast: (BOOL) last;
- (void) setSpacings;
@end

@implementation BubbleActionsList

- (id) initWithSpacing: (float) spacing
			   andActions: (NSArray *) actions
			 itemSelected: (int) theSelected
		andHighlightColor:(NSColor *) theColor
                forCorner:(int) corner
{
	if(DEBUG_ON)NSLog(@"init bubbleActionsList, actions class: %@",[actions class]);
	int i;
    if(self=[super init]){
        theCorner=corner;
		spacingSize=spacing;
		selected = theSelected;
        lastSelected=-1;
		bubbleActions = nil;
        showAllModifiers=NO;
		if(theColor != nil){
			highlightColor = [theColor copy];			
		}else{
			highlightColor = [[NSColor selectedControlColor] copy];
		}
		detSize = NSMakeSize(0,0);
		if(actions != nil){
			bubbleActions = [[NSMutableArray alloc] initWithCapacity:[actions count]];
			for(i=0; i<[actions count];i++){
				BubbleAction *ba = (BubbleAction *)[actions objectAtIndex:i];
				NSSize actSz = [ba preferredSize];
				detSize.height+=actSz.height;
				if(i>0){
					detSize.height+=spacingSize;
				}
				if(actSz.width > detSize.width){
					detSize.width=actSz.width;
				}
				[bubbleActions addObject:ba];
			}
			[self calcPreferredSize];

		}
	}
	return self;
}

- (int) corner
{
    return theCorner;
}

- (BOOL) showAllModifiers
{
    return showAllModifiers;
}
- (void) setShowAllModifiers: (BOOL)show
{
    showAllModifiers=show;
	[self calcPreferredSize];
}
- (NSSize) preferredSize
{
	return detSize;
}

- (void) setSpacingSize: (float) size
{
	spacingSize=size;
	[self setSpacings];
	[self calcPreferredSize];
}


- (void) setSpacings
{
	int i;
	for(i=0;i<[bubbleActions count];i++){
		[(BubbleAction *)[bubbleActions objectAtIndex:i] setSpacingSize: spacingSize];
	}
}


- (int) selectedModifiers
{
	if(selected < 0)
		return -1;
	BubbleAction *ba = (BubbleAction *)[bubbleActions objectAtIndex: selected];
	NSArray *actions = [ba actions];
	if(actions !=nil && [actions count]>0){
		ClickAction *act = (ClickAction *)[actions objectAtIndex:0];
		
		return [act modifiers];
	}else{
		return -1;
	}
}
- (int) selectedTrigger
{
	if(selected < 0)
		return -1;
	BubbleAction *ba = (BubbleAction *)[bubbleActions objectAtIndex: selected];
	NSArray *actions = [ba actions];
	if(actions !=nil && [actions count]>0){
		ClickAction *act = (ClickAction *)[actions objectAtIndex:0];
		
		return [act trigger];
	}else{
		return -1;
	}
}

- (int) selectedItem
{
	return selected;
}

- (NSPoint) originForBubbleAction:(int) ndx
{
	float sum=0;
	int i;
	for(i=0;i<[bubbleActions count];i++){
		NSSize s = [(BubbleAction *)[bubbleActions objectAtIndex:i] preferredSize];
		sum+=s.height;
	}
	return NSMakePoint(0,detSize.height-sum);
}

- (NSRect) drawingRectForAction:(int)ndx isSelected:(BOOL)isSelected inRect:(NSRect) rect
{
	int i,ox,oy;
	float ht=spacingSize/2;
	float cur = detSize.height;
    for(i=0; i< [bubbleActions count];i++){
        ox=0;
        oy=0;
        BubbleAction *ba = (BubbleAction *)[bubbleActions objectAtIndex:i];
        NSSize sz = [ba preferredSize];
        if(i>0){
            cur-=spacingSize;
        }
        cur = cur - sz.height;
        if(i == ndx && isSelected){
            
            NSRect r =  NSMakeRect(rect.origin.x-ht,rect.origin.y+cur-ht,rect.size.width+spacingSize,sz.height+spacingSize);
            return NSIntegralRect(NSInsetRect(r,-3,-3));
        }
        else if(i==ndx)
            return NSIntegralRect(NSMakeRect(rect.origin.x + ox,rect.origin.y+cur + oy,sz.width,sz.height));
    }
    ERROR(@"drawingRectForAction:isSelected:inRect: Can't find action: %d",ndx);
    return NSZeroRect;
}
- (void) calcPreferredSize
{
    [self calcPreferredSize:NO];
}
- (void) calcPreferredSize:(BOOL) recalc
{
	int i;
	NSSize sz = NSMakeSize(0,0);
    
    if(showAllModifiers && [bubbleActions count]>1){
        for(i=0; i<[bubbleActions count];i++){
            BubbleAction *ba = (BubbleAction *)[bubbleActions objectAtIndex:i];
            if(recalc){
                [ba calcPreferredSize];
            }
                
            NSSize actSz = [ba preferredSize];
            sz.height= sz.height > actSz.height ? sz.height : actSz.height;
            sz.width+=actSz.width;
            
            if(i>0)
                sz.width+=2*spacingSize+spacingSize/2;
        }
    }else{
        
        for(i=0; i<[bubbleActions count];i++){
            BubbleAction *ba = (BubbleAction *)[bubbleActions objectAtIndex:i];
            if(recalc){
                [ba calcPreferredSize];
            }
                
            NSSize actSz = [ba preferredSize];
            sz.height+=actSz.height;
            if(i>0){
                sz.height+=spacingSize;
            }
            if(actSz.width > sz.width){
                sz.width=actSz.width;
            }
        }
    }
	detSize=sz;
}

- (void) updateSelected: (int) selectedMod
{
    lastSelected=selected;
    selected=selectedMod;
}

- (void) drawInRect:(NSRect) rect
{
	int i,ox,oy;
	float ht=spacingSize/2;
	float cur = rect.size.height;
    float curx;
	if(showAllModifiers && [bubbleActions count] > 1){
        cur = 0;
        curx = 0;
        NSArray *sortedActs = [bubbleActions sortedArrayUsingSelector:@selector(triggerCompare:)];
        for(i=0; i< [sortedActs count];i++){
            ox=0;
            oy=0;
            BubbleAction *ba = (BubbleAction *)[sortedActs objectAtIndex:i];
            NSSize sz = [ba preferredSize];
            if(sz.height < rect.size.height){
                oy = (int)ceil((rect.size.height/2) - (sz.height/2));
            }
            if(i>0){
                curx+=spacingSize;
                NSBezierPath *path = [[[NSBezierPath alloc] init] autorelease];
                float x,y,w,h, ps, mw;
                w = ht;
                x = curx + rect.origin.x;
                y = rect.origin.y + cur - ht;
                h = rect.size.height + spacingSize;
                ps = ht;
                mw=ht;
                float sls=3;

                y=rect.origin.y - spacingSize + 1;
                h=rect.size.height + 2*spacingSize - 2;
                [path moveToPoint: NSMakePoint(x - sls,y)];
                [path lineToPoint: NSMakePoint(x , y)];
                [path lineToPoint: NSMakePoint(x+w+ sls, y+h)];
                [path lineToPoint: NSMakePoint(x + w, y+h)];
                
                
                [path closePath];
                [BubbleView addShadow:path depth:1.5];

                //[BubbleView drawRoundedBezel:NSMakeRect(curx + rect.origin.x, rect.origin.y + cur - ht, ht, rect.size.height + spacingSize) rounding: 1 depth:1.5];
                curx+=spacingSize + ht;
            }
            NSRect selRect;
            if(i==selected){
                selRect=NSMakeRect(rect.origin.x + curx - ht,
                                   rect.origin.y + cur  - ht,
                                   sz.width + spacingSize,
                                   rect.size.height + spacingSize);
                [self drawSelectedInFrame:  selRect];
            }
            NSRect fr = NSMakeRect(rect.origin.x + curx + ox,
                                   rect.origin.y + cur  + oy,
                                   sz.width,
                                   sz.height);
            [ba drawInRect:fr];
            NSArray *actions = [ba actions];
            if([actions count]>0){
                int style=-1;
                if(style==0){
                    
                
                    
                    ClickAction *click=(ClickAction *) [actions objectAtIndex:0];
                    NSImage *draw;
                    if([click trigger]==0){
                        draw = [NSImage imageNamed:@"right-click"] ;
                    }else if([click trigger]==1){
                        draw = [NSImage imageNamed:@"right-click"] ;
                    }else{
                        draw=nil;
                    }
                    if(draw != nil){
                        NSSize isz = [draw size];
                        float rat,newh,neww;
                        newh=10;
                        rat = isz.width/isz.height;
                        neww = rat * newh;
                        float nx=rect.origin.x + curx + ox;
                        if([click trigger]==0){
                            nx+=5;
                        }else{
                            nx+=sz.width - neww - 5;
                        }
                        
                        float ny=rect.origin.y + cur + rect.size.height + ht/2;
                        [draw setScalesWhenResized:YES];
                        [draw setSize:NSMakeSize(neww, newh)];
                        [[NSGraphicsContext currentContext] setShouldAntialias:YES];
                        [draw compositeToPoint:NSMakePoint(nx, ny-newh/2)
                                         operation:NSCompositeSourceOver];
                        
                        /*[draw drawInRect:NSIntegralRect(NSMakeRect(nx, ny-newh/2, neww, newh))
                                fromRect:NSIntegralRect(NSMakeRect(0,0,new))
                               operation:NSCompositeSourceOver
                                fraction:1.0];
                        */
                    }
                    
                    
                }else if(style==1){
                    //NSFont *font = (NSFont *)[smallTextAttributes objectForKey:NSFontAttributeName];

                    NSString *str=nil;
                    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                    ClickAction *click=(ClickAction *) [actions objectAtIndex:0];
                    str = [CornerClickSupport labelForModifiers:[click modifiers]
                                                     andTrigger:[click trigger]
                                                    localBundle:bundle];
                    if([click trigger]==0){
                        //str = [NSString stringWithFormat:@"%C%C", (unichar)0x2606, (unichar)0x261c];//0x2190];
//                        str = [NSString stringWithFormat:@"%C", (unichar)0x2606];
                        //str = [NSString stringWithFormat:@"%C", (unichar)0x261c];
                        //str = [NSString stringWithFormat:@"%C", (unichar)0x25e7];
                        str = [NSString stringWithFormat:@"%C", (unichar)0x21d9];
                    }else if([click trigger]==1){
                        //str = [NSString stringWithFormat:@"%C%C", (unichar)0x261e, (unichar)0x2606];//2192];
                        //str = [NSString stringWithFormat:@"%C%C", (unichar)0x2606, (unichar)0x2606];//0x2190];
                        //str = [NSString stringWithFormat:@"%C", (unichar)0x261e];
                        //str = [NSString stringWithFormat:@"%C", (unichar)0x25e8];
                        str = [NSString stringWithFormat:@"%C", (unichar)0x21d8];
                    }else{
                    }
                    NSShadow *textShad = [[[NSShadow alloc] init] autorelease];
                    [textShad setShadowOffset:NSMakeSize(0,0)];
                    [textShad setShadowBlurRadius:3];
                    [textShad setShadowColor:[NSColor whiteColor]];
                    NSDictionary *myAttrs = [NSDictionary dictionaryWithObjects:
                        [NSArray arrayWithObjects: 
                            [NSFont systemFontOfSize: 16.0],
                            [[NSColor blackColor] colorWithAlphaComponent: 0.5], 
                            textShad, nil]
                                                          forKeys:
                        [NSArray arrayWithObjects: NSFontAttributeName,
                            NSForegroundColorAttributeName, 
                            NSShadowAttributeName, nil]
                        ];
                    if(str != nil){
                        NSSize msz = [str sizeWithAttributes:myAttrs];
                        //float yoff = ht/2 - msz.height/2 - 2;
                        [str drawAtPoint:NSMakePoint(rect.origin.x+curx+ox+sz.width/2-msz.width/2, 
                                                     rect.origin.y+cur +rect.size.height + spacingSize - msz.height - 1)
                          withAttributes:myAttrs];
                        
                    }
                }
                
                if(i==selected){
                    
                    [self drawSelectedOverlayInFrame: selRect
                                            isLast:NO];
                    
                }
                
            }
            
            curx+=sz.width;
        }
    }else{
            
        for(i=0; i< [bubbleActions count];i++){
            ox=0;
            oy=0;
            BubbleAction *ba = (BubbleAction *)[bubbleActions objectAtIndex:i];
            NSSize sz = [ba preferredSize];
            if(i>0){
                cur-=spacingSize;
            }
            cur = cur - sz.height;
            NSRect selRect;
            if(i==selected ){
                selRect = NSMakeRect(rect.origin.x-ht,rect.origin.y+cur-ht,rect.size.width+spacingSize,sz.height+spacingSize);
                if(NSIntersectsRect(rect,selRect)){
                    
                
                    [self drawSelectedInFrame: selRect isLast:(i==[bubbleActions count]-1)];
                }
            }
            NSRect fr = NSMakeRect(rect.origin.x + ox,rect.origin.y+cur + oy,sz.width,sz.height);
            if(NSIntersectsRect(rect,fr)){
                if(i==selected || lastSelected<0 || lastSelected>=0 && i==lastSelected){
                    [ba drawInRect:fr];
                    //DEBUG(@"bub actions list: AM DRAWING item %d",i);
                    
                }
            }
            
            if(i==selected ){
                if(NSIntersectsRect(rect,selRect)){
                    [self drawSelectedOverlayInFrame: selRect isLast:(i==[bubbleActions count]-1)];
                }
            }
            
        }
    }
}

- (void) drawSelectedOverlayInFrame:(NSRect) rect isLast: (BOOL) last
{
    
    int round=10;
    int line=3;
    NSBezierPath *nbp;
    if(last){
        nbp= [BubbleView roundedRect:rect
                     roundingTopLeft:round - line
                    roundingTopRight:round - line
                  roundingBottomLeft:22 - line
                 roundingBottomRight:22 - line
            ];
    }else{
        nbp= [BubbleView roundedRect:rect rounding:round];
    }
    [[NSGraphicsContext currentContext] saveGraphicsState];
    [nbp setClip];
//    [BubbleView addGlass:rect];
    [[NSGraphicsContext currentContext] restoreGraphicsState];
    
}
- (void) drawSelectedInFrame:(NSRect) rect
{
    [self drawSelectedInFrame:rect isLast: NO];
}

- (void) drawSelectedInFrame:(NSRect) rect isLast: (BOOL) last
{
    int style=1;
    int round=10;
    int line=3;

    if(highlightColor == [NSColor blackColor]){
        line=1;
        NSBezierPath *nbp;
        if(last){
            nbp= [BubbleView roundedRect:rect
                         roundingTopLeft:round - line
                        roundingTopRight:round - line 
                      roundingBottomLeft:22  - line
                     roundingBottomRight:22  - line
                ];
        }else{
            nbp= [BubbleView roundedRect:rect rounding:round - line];
        }
        
        if(style==0){
                        [BubbleView addShadow:nbp
                            depth:1.5];
        
        }else{
            [[[NSColor whiteColor] colorWithAlphaComponent:0.2] set];
            [nbp fill];
            [[[NSColor whiteColor] colorWithAlphaComponent:0.8] set];
            [nbp setLineWidth:line];
            [nbp stroke];
            [[NSGraphicsContext currentContext] saveGraphicsState];
            [nbp addClip];
            [BubbleView addGlass:rect
                       withColor:[NSColor whiteColor]
                    withRounding: round - line];
            [[NSGraphicsContext currentContext] restoreGraphicsState];
            
        }
    }else if(style==0){
        
        NSBezierPath *nbp;
        if(last){
            nbp= [BubbleView roundedRect:rect
                         roundingTopLeft:round - line
                        roundingTopRight:round - line
                      roundingBottomLeft:22 - line
                     roundingBottomRight:22 - line
                ];
        }else{
            nbp= [BubbleView roundedRect:rect rounding:round];
        }

        [[ highlightColor colorWithAlphaComponent:0.5] set];
        [nbp fill];
        [[NSColor whiteColor] set];
        [nbp setLineJoinStyle:NSRoundLineJoinStyle];
        [nbp setLineWidth:line];
        [nbp stroke];
               [[NSColor blackColor] set];
        
        [nbp setLineWidth: 1];
        //[nbp stroke];
    }else if(style==1){
        
        NSBezierPath *nbp;
        if(last){
            nbp= [BubbleView roundedRect:rect
                         roundingTopLeft:round - line
                        roundingTopRight:round - line
                      roundingBottomLeft:22 - line
                     roundingBottomRight:22 - line
                ];
        }else{
            nbp= [BubbleView roundedRect:rect rounding:round];
        }
        
        [[highlightColor colorWithAlphaComponent:0.7] set];
        [nbp fill];
        [[NSGraphicsContext currentContext] saveGraphicsState];
        [nbp addClip];
        [BubbleView addGlass:rect
                   withColor:[NSColor whiteColor]
                withRounding: round - line];
        [[NSGraphicsContext currentContext] restoreGraphicsState];
        [[NSColor whiteColor] set];
        [nbp setLineJoinStyle:NSRoundLineJoinStyle];
        [nbp stroke];
    }else if(style==2){
        
        NSBezierPath *nbp;
        if(last){
            nbp= [BubbleView roundedRect:rect
                         roundingTopLeft:round - line
                        roundingTopRight:round - line
                      roundingBottomLeft:22 - line
                     roundingBottomRight:22 - line
                ];
        }else{
            nbp= [BubbleView roundedRect:rect rounding:round];
        }
        
        //[[ highlightColor colorWithAlphaComponent:0.5] set];
        [[NSGraphicsContext currentContext] saveGraphicsState];
        //[nbp fill];
        [nbp setClip];
        [BubbleView drawGradient:rect
                       fromColor:[ highlightColor colorWithAlphaComponent:0.7]
                         toColor:[ highlightColor colorWithAlphaComponent:0.3]
                       fromPoint: rect.origin
                         toPoint: NSMakePoint(NSMaxX(rect),NSMinY(rect))
            ];
        [[NSGraphicsContext currentContext] restoreGraphicsState];
        
        [[NSColor whiteColor] set];
        [nbp setLineJoinStyle:NSRoundLineJoinStyle];
        [nbp setLineWidth:line];
        [nbp stroke];
        
        
        [[NSColor blackColor] set];
        [nbp setLineWidth: 1];
        //[nbp stroke];
        
    }else{
        
        NSBezierPath *nbp = [BubbleView roundedRect:rect rounding:round];
        [[ highlightColor colorWithAlphaComponent:0.4] set];
        
        NSBezierPath *nt = [BubbleView roundedRect:NSInsetRect(rect, -1.5,-1.5) rounding:round];
        [nt appendBezierPath: [BubbleView roundedRect:NSInsetRect(rect, 1.5,1.5) rounding:round]];

        [nt setWindingRule:NSEvenOddWindingRule];
        
        [BubbleView addShadow:nbp
                        depth:1.5
               bgColor:[highlightColor colorWithAlphaComponent:0.8]
                  shadowColor:[NSColor blackColor]
                   shineColor: [NSColor whiteColor] 
            ];
         
    }
	
}

- (void)dealloc
{
	[highlightColor release];
	[bubbleActions release];
}

@end
