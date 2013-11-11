//
//  OSX_TestAppDelegate.m
//  OSX_Test
//
//  Created by Dragan Petrovic on 10/11/2013.
//  Copyright (c) 2013 Polytonic. All rights reserved.
//

#import "OSX_TestAppDelegate.h"
#import "RapidView.h"

@implementation OSX_TestAppDelegate

- (void) draw:(NSView*)view context:(CGContextRef)context {

    CGRect rect = CGRectMake(0, 0, 64, 64);
    CGContextFillEllipseInRect(context, rect);
}

- (void) dragged:(NSView*)view event:(NSEvent*)theEvent {
    
    NSPoint mousePoint = [theEvent locationInWindow];
    mousePoint.x -= CGRectGetMidX(view.bounds);
    mousePoint.y -= CGRectGetMidY(view.bounds);
    [view setFrameOrigin:mousePoint];
    NSLog(@"%@ %@", view, NSStringFromPoint(mousePoint));
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    CGRect mainFrame = ((NSView*)_window.contentView).frame;
    CGFloat(^Rand)(CGFloat max) = ^CGFloat(CGFloat max) {
        return (rand()/(CGFloat)RAND_MAX)*max;
    };
    
    for(int i = 0; i < 10; ++i) {
        NSRect rect = NSMakeRect(Rand(CGRectGetWidth(mainFrame)), Rand(CGRectGetHeight(mainFrame)), 64, 64);
        NSView* view = drawWithMethod(@selector(draw:context:), self, rect, YES);
        pointDragged(view, self, @selector(dragged:event:));
        view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [_window.contentView addSubview:view];
        view = nil;
        
        rect = NSMakeRect(Rand(CGRectGetWidth(mainFrame)), Rand(CGRectGetHeight(mainFrame)), 64, 64);
        NSView* view2 = drawWithBlock(^(NSView* view, CGContextRef context) {
            CGRect rect = CGRectMake(0, 0, 64, 64);
            CGContextSetFillColorWithColor(context, [NSColor redColor].CGColor);
            CGContextFillEllipseInRect(context, rect);
        }, rect, YES);
        
        view2.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [_window.contentView addSubview:view2];
        view2 = nil;
    }
//    NSView* superview =_window.contentView;
//    NSLog(@"%@", superview.subviews);
}

@end
