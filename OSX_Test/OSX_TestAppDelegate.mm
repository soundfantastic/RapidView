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
    
    CGFloat(^Rand)(CGFloat max) = ^CGFloat(CGFloat max) {
        return (rand()/(CGFloat)RAND_MAX)*max;
    };
    CGRect rect = CGRectMake(Rand(CGRectGetWidth(view.bounds)), Rand(CGRectGetHeight(view.bounds)), 64, 64);
    CGContextFillEllipseInRect(context, rect);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    for(int i = 0; i < 100; ++i) {
        NSView* view = drawWithMethod(@selector(draw:context:), self, ((NSView*)_window.contentView).frame);
        view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [_window.contentView addSubview:view];
        view = nil;
        
        NSView* view2 = drawWithBlock(^(NSView* view, CGContextRef context) {
            CGFloat(^Rand)(CGFloat max) = ^CGFloat(CGFloat max) {
                return (rand()/(CGFloat)RAND_MAX)*max;
            };
            CGRect rect = CGRectMake(Rand(CGRectGetWidth(view.bounds)), Rand(CGRectGetHeight(view.bounds)), 64, 64);
            CGContextSetFillColorWithColor(context, [NSColor redColor].CGColor);
            CGContextFillEllipseInRect(context, rect);
        }, ((NSView*)_window.contentView).frame);
        
        view2.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [_window.contentView addSubview:view2];
        view2 = nil;
    }
    NSView* superview =_window.contentView;
    NSLog(@"%@", superview.subviews);
}

@end
