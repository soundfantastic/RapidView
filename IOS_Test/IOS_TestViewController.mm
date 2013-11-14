//
//  IOS_TestViewController.m
//  IOS_Test
//
//  Created by Dragan Petrovic on 10/11/2013.
//  Copyright (c) 2013 Polytonic. All rights reserved.
//

#import "IOS_TestViewController.h"
#import "RapidView.h"

@interface IOS_TestViewController ()

@end

@implementation IOS_TestViewController

- (void) draw:(UIView*)view context:(CGContextRef)context {
    CGRect rect = CGRectMake(0, 0, 64, 64);
    CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
    CGContextFillEllipseInRect(context, rect);
}

- (void) view:(UIView*)view touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
   CGPoint touchLocation = [touch locationInView:touch.view];
    touch.view.center = touchLocation;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect mainFrame = self.view.bounds;
    CGFloat(^Rand)(CGFloat max) = ^CGFloat(CGFloat max) {
        return (rand()/(CGFloat)RAND_MAX)*max;
    };
    
	// Do any additional setup after loading the view, typically from a nib.
    UIView* superview = self.view;
    for(int i = 0; i < 10; ++i) {
        CGRect rect = CGRectMake(Rand(CGRectGetWidth(mainFrame)), Rand(CGRectGetHeight(mainFrame)), 64, 64);
        UIView* view = drawWithMethod(@selector(draw:context:), self, rect);
        view.backgroundColor = [UIColor clearColor];
        pointDraggedWithBlock(view, ^(UIView* view, id set, id theEvent) {
            UITouch *touch = [[theEvent allTouches] anyObject];
            CGPoint touchLocation = [touch locationInView:touch.view];
            touch.view.center = touchLocation;
        });
        view.userInteractionEnabled = YES;
        [superview addSubview:view];
        view = nil;
        rect = CGRectMake(Rand(CGRectGetWidth(mainFrame)), Rand(CGRectGetHeight(mainFrame)), 64, 64);
        UIView* view2 = drawWithBlock(^(UIView* view, CGContextRef context) {
            CGRect rect = CGRectMake(0, 0, 64, 64);
            CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
            CGContextFillEllipseInRect(context, rect);
        }, rect);
        view2.backgroundColor = [UIColor clearColor];
        pointDraggedWithMethod(view2, self, @selector(view:touchesMoved:withEvent:));
        view2.userInteractionEnabled = YES;
        [superview addSubview:view2];
        view2 = nil;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
