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
    #define GRAPHIC_CONTEXT UIGraphicsGetCurrentContext()
#else
    #import <objc/objc-runtime.h>
    #define SUPERVIEW_STRING @"NSView"
    #define GRAPHIC_CONTEXT (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort]
#endif

static int32_t VIEW_WITH_METHOD_COUNT = 0;
static int32_t VIEW_WITH_BLOCK_COUNT  = 0;

void superDrawRect(Class view, CGRect dirtyRect) {
    struct objc_super superView;
    superView.receiver = (id)view;
    superView.super_class = class_getSuperclass(view);
    objc_msgSendSuper(&superView, @selector(drawRect:), dirtyRect);
}

Class allocateClass(NSString* ident) {
    const char* name = [ident UTF8String];
    Class superClass = NSClassFromString(SUPERVIEW_STRING);
    return objc_allocateClassPair(superClass, name, 0);
}

id drawWithMethod(SEL selector, id target, CGRect frame, BOOL superDraw) {
    Class RapidView = allocateClass([NSString stringWithFormat:@"VIEW_WITH_METHOD_%d", ++VIEW_WITH_METHOD_COUNT]);
    Method drawRect = class_getInstanceMethod(class_getSuperclass(RapidView), @selector(drawRect:));
    class_addMethod(RapidView, @selector(drawRect:), imp_implementationWithBlock(^(id sender, CGRect dirtyRect) {
        if(superDraw) {
            superDrawRect(RapidView, dirtyRect);
        }
        if(class_respondsToSelector(object_getClass(target), selector)) {
            objc_msgSend(target, selector, sender, GRAPHIC_CONTEXT);
        }
    }), method_getTypeEncoding(drawRect));
    return [[RapidView alloc] initWithFrame:frame]; //dont forget to release this object
}

id drawWithBlock(Function draw, CGRect frame, BOOL superDraw) {
    Class RapidView = allocateClass([NSString stringWithFormat:@"VIEW_WITH_BLOCK_%d", ++VIEW_WITH_BLOCK_COUNT]);
    Method drawRect = class_getInstanceMethod(class_getSuperclass(RapidView), @selector(drawRect:));
    class_addMethod(RapidView, @selector(drawRect:), imp_implementationWithBlock(^(id sender, CGRect dirtyRect) {
        if(superDraw) {
            superDrawRect(RapidView, dirtyRect);
        }
        if(draw) {
            draw(sender, GRAPHIC_CONTEXT);
        }
    }), method_getTypeEncoding(drawRect));
    return [[RapidView alloc] initWithFrame:frame]; //dont forget to release this object
}

#pragma mark - Mouse&touch events
BOOL pointTouched(id view, id target, SEL selector) {
    Class RapidView = object_getClass(view);
    BOOL successful = NO;
#if TARGET_OS_IPHONE
    Method method = class_getInstanceMethod(class_getSuperclass(RapidView), @selector(touchesBegan:withEvent:));
    successful = class_addMethod(RapidView,@selector(touchesBegan:withEvent:), imp_implementationWithBlock(^(id sender, id set, id event) {
        if(class_respondsToSelector(object_getClass(target), selector)) {
            objc_msgSend(target, selector, sender, set, event);
        }
    }), method_getTypeEncoding(method));
#else
    Method method = class_getInstanceMethod(class_getSuperclass(RapidView), @selector(mouseDown:));
    successful = class_addMethod(RapidView, @selector(mouseDown:), imp_implementationWithBlock(^(id sender, id event) {
        if(class_respondsToSelector(object_getClass(target), selector)) {
            objc_msgSend(target, selector, sender, event);
        }
    }), method_getTypeEncoding(method));
#endif
    return successful;
}

BOOL pointDragged(id view, id target, SEL selector) {
    Class RapidView = object_getClass(view);
    BOOL successful = NO;
#if TARGET_OS_IPHONE
    Method method = class_getInstanceMethod(class_getSuperclass(RapidView), @selector(touchesMoved:withEvent:));
    successful = class_addMethod(RapidView, @selector(touchesMoved:withEvent:), imp_implementationWithBlock(^(id sender, id set, id event) {
        if(class_respondsToSelector(object_getClass(target), selector)) {
            objc_msgSend(target, selector, sender, set, event);
        }
    }), method_getTypeEncoding(method));
#else
    Method method = class_getInstanceMethod(class_getSuperclass(RapidView), @selector(mouseDragged:));
    successful = class_addMethod(RapidView, @selector(mouseDragged:), imp_implementationWithBlock(^(id sender, id event) {
        if(class_respondsToSelector(object_getClass(target), selector)) {
            objc_msgSend(target, selector, sender, event);
        }
    }), method_getTypeEncoding(method));
#endif
    return successful;
}

BOOL pointUnTouched(id view, id target, SEL selector) {
    Class RapidView = object_getClass(view);
    BOOL successful = NO;
#if TARGET_OS_IPHONE
    Method method = class_getInstanceMethod(class_getSuperclass(RapidView), @selector(touchesEnded:withEvent:));
    successful = class_addMethod(RapidView, @selector(touchesEnded:withEvent:), imp_implementationWithBlock(^(id sender, id set, id event) {
        if(class_respondsToSelector(object_getClass(target), selector)) {
            objc_msgSend(target, selector, sender, set, event);
        }
    }), method_getTypeEncoding(method));
#else
    Method method = class_getInstanceMethod(class_getSuperclass(RapidView), @selector(mouseUp:));
    successful = class_addMethod(RapidView, @selector(mouseUp:), imp_implementationWithBlock(^(id sender, id event) {
        if(class_respondsToSelector(object_getClass(target), selector)) {
            objc_msgSend(target, selector, sender, event);
        }
    }), method_getTypeEncoding(method));
#endif
    return successful;
}


