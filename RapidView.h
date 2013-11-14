//
//  RapidView.h
//  RapidView
//
//  Created by Dragan Petrovic on 10/11/2013.
//  Copyright (c) 2013 Polytonic. All rights reserved.
//


//Block to use with drawWithBlock NSView & UIView constructor
typedef void(^Function)(id view, CGContextRef context);

//NSView mouse & UIView touch events block
typedef void(^Events)(id view, id set, id events);

//NSView & UIView dynamic constructor methods
id drawWithMethod(SEL selector, id target, CGRect frame, BOOL superDraw=NO);
id drawWithBlock(Function draw, CGRect frame, BOOL superDraw=NO);

//NSView mouse & UIView touch events
BOOL pointDraggedWithMethod(id view, id target, SEL method);
BOOL pointDraggedWithBlock(id view, Events events);
BOOL pointTouchedWithMethod(id view, id target, SEL method);
BOOL pointTouchedWithBlock(id view, Events events);
BOOL pointUntouchedWithMethod(id view, id target, SEL method);
BOOL pointUntouchedWithBlock(id view, Events events);
