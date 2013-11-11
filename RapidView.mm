//
//  RapidView.cpp
//  RapidView
//
//  Created by Dragan Petrovic on 10/11/2013.
//  Copyright (c) 2013 Polytonic. All rights reserved.
//

#include "RapidView.h"

#if TARGET_OS_IPHONE
    #import <objc/runtime.h>
    #import <objc/message.h>
    #define SUPERVIEW_STRING @"UIView"
    typedef CGRect gRect;
    typedef UIEvent ViewEvent;
    #define GRAPHIC_CONTEXT UIGraphicsGetCurrentContext()
#else
    #import <objc/objc-runtime.h>
    #define SUPERVIEW_STRING @"NSView"
    typedef NSRect gRect;
    typedef NSEvent ViewEvent;
    #define GRAPHIC_CONTEXT (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort]
#endif

static int32_t VIEW_WITH_METHOD_COUNT = 0;
static int32_t VIEW_WITH_BLOCK_COUNT  = 0;

void superDrawRect(Class view, gRect dirtyRect) {
    struct objc_super superView;
    superView.receiver = (id)view;
    superView.super_class = class_getSuperclass(view);
    objc_msgSendSuper(&superView, @selector(drawRect:), dirtyRect);
}

id drawWithMethod(SEL selector, id target, CGRect frame, BOOL superDraw) {
    const char* name = [[NSString stringWithFormat:@"VIEW_WITH_METHOD_%d", ++VIEW_WITH_METHOD_COUNT] UTF8String];
    Class superClass = NSClassFromString(SUPERVIEW_STRING);
    Class RapidView = objc_allocateClassPair(superClass, name, 0);
    class_addMethod(RapidView, NSSelectorFromString(@"drawRect:"), imp_implementationWithBlock(^(id sender, gRect dirtyRect) {
        if(superDraw) {
            superDrawRect(RapidView, dirtyRect);
        }
        if(class_respondsToSelector(object_getClass(target), selector)) {
            objc_msgSend(target, selector, sender, GRAPHIC_CONTEXT);
        }
    }), [[NSString stringWithFormat:@"v:%s", @encode(gRect)] UTF8String]);
    return [[RapidView alloc] initWithFrame:frame]; //dont forget to release this object
}

id drawWithBlock(Function draw, CGRect frame, BOOL superDraw) {
    const char* name = [[NSString stringWithFormat:@"VIEW_WITH_BLOCK_%d", ++VIEW_WITH_BLOCK_COUNT] UTF8String];
    Class superClass = NSClassFromString(SUPERVIEW_STRING);
    Class RapidView = objc_allocateClassPair(superClass, name, 0);
    class_addMethod(RapidView, NSSelectorFromString(@"drawRect:"), imp_implementationWithBlock(^(id sender, gRect dirtyRect) {
        if(superDraw) {
            superDrawRect(RapidView, dirtyRect);
        }
        if(draw) {
            draw(sender, GRAPHIC_CONTEXT);
        }
    }), [[NSString stringWithFormat:@"v:%s", @encode(gRect)] UTF8String]);
    return [[RapidView alloc] initWithFrame:frame]; //dont forget to release this object
}

void pointDragged(id view, id target, SEL selector) {
    Class viewClass = object_getClass(view);
    class_addMethod(viewClass, NSSelectorFromString(@"mouseDragged:"), imp_implementationWithBlock(^(id sender, ViewEvent* event) {
        if(class_respondsToSelector(object_getClass(target), selector)) {
            objc_msgSend(target, selector, sender, event);
        }
    }), [[NSString stringWithFormat:@"v:%s", @encode(ViewEvent*)] UTF8String]);
}

void pointTouched(id view, id target, SEL selector) {
    Class viewClass = object_getClass(view);
    class_addMethod(viewClass, NSSelectorFromString(@"mouseDown:"), imp_implementationWithBlock(^(id sender, ViewEvent* event) {
        if(class_respondsToSelector(object_getClass(target), selector)) {
            objc_msgSend(target, selector, sender, event);
        }
    }), [[NSString stringWithFormat:@"v:%s", @encode(ViewEvent*)] UTF8String]);
}


