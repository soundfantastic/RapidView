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
    
    CGFloat(^Rand)(CGFloat max) = ^CGFloat(CGFloat max) {
        return (rand()/(CGFloat)RAND_MAX)*max;
    };
    CGRect rect = CGRectMake(Rand(CGRectGetWidth(view.bounds)), Rand(CGRectGetHeight(view.bounds)), 64, 64);
    CGContextFillEllipseInRect(context, rect);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIView* superview = self.view;
    for(int i = 0; i < 10; ++i) {
        UIView* view = drawWithMethod(@selector(draw:context:), self, superview.frame);
        view.backgroundColor = [UIColor clearColor];
        [superview addSubview:view];
        view = nil;
        UIView* view2 = drawWithBlock(^(UIView* view, CGContextRef context) {
            CGFloat(^Rand)(CGFloat max) = ^CGFloat(CGFloat max) {
                return (rand()/(CGFloat)RAND_MAX)*max;
            };
            CGRect rect = CGRectMake(Rand(CGRectGetWidth(view.bounds)), Rand(CGRectGetHeight(view.bounds)), 64, 64);
            CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
            CGContextFillEllipseInRect(context, rect);
        }, superview.frame);
        view2.backgroundColor = [UIColor clearColor];
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
