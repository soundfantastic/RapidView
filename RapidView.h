//
//  RapidView.h
//  RapidView
//
//  Created by Dragan Petrovic on 10/11/2013.
//  Copyright (c) 2013 Polytonic. All rights reserved.
//

id drawWithMethod(SEL selector, id target, CGRect frame, BOOL superDraw=NO);
typedef void(^Function)(id view, CGContextRef context);
id drawWithBlock(Function draw, CGRect frame, BOOL superDraw=NO);
void pointDragged(id view, id target, SEL method);
void pointTouched(id view, id target, SEL method);