//
//  RapidView.h
//  RapidView
//
//  Created by Dragan Petrovic on 10/11/2013.
//  Copyright (c) 2013 Polytonic. All rights reserved.
//

id drawWithMethod(SEL selector, id target, CGRect frame);
typedef void(^Draw)(id view, CGContextRef context);
id drawWithBlock(Draw block, CGRect frame);