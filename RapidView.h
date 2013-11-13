//
//  RapidView.h
//  RapidView
//
//  Created by Dragan Petrovic on 10/11/2013.
//  Copyright (c) 2013 Polytonic. All rights reserved.
//

extern "C" {
id drawWithMethod(SEL selector, id target, CGRect frame, BOOL superDraw=NO);
typedef void(^Function)(id view, CGContextRef context);
id drawWithBlock(Function draw, CGRect frame, BOOL superDraw=NO);
BOOL pointDragged(id view, id target, SEL method);
BOOL pointTouched(id view, id target, SEL method);
BOOL pointUnTouched(id view, id target, SEL method);
}