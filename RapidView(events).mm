//
//  RapidView(events).mm
//  RapidView
//
//  Created by Dragan Petrovic on 14/11/2013.
//  Copyright (c) 2013 Polytonic. All rights reserved.
//

#include "RapidView.h"
#include "RapidView(events).h"

#if TARGET_OS_IPHONE
    #import <objc/runtime.h>
    #import <objc/message.h>
#else
    #import <objc/objc-runtime.h>
#endif


#pragma mark - NSView mouseDown & UIVIew touchesBegan
BOOL pointTouchedWithMethod(id view, id target, SEL selector) {
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

BOOL pointTouchedWithBlock(id view, Events events) {
    Class RapidView = object_getClass(view);
    BOOL successful = NO;
#if TARGET_OS_IPHONE
    Method method = class_getInstanceMethod(class_getSuperclass(RapidView), @selector(touchesBegan:withEvent:));
    successful = class_addMethod(RapidView, @selector(touchesBegan:withEvent:), imp_implementationWithBlock(^(id sender, id set, id event) {
        if(events) {
            events(sender, set, event);
        }
    }), method_getTypeEncoding(method));
#else
    Method method = class_getInstanceMethod(class_getSuperclass(RapidView), @selector(mouseDown:));
    successful = class_addMethod(RapidView, @selector(mouseDown:), imp_implementationWithBlock(^(id sender, id event) {
        if(events) {
            events(sender, nil, event);
        }
    }), method_getTypeEncoding(method));
#endif
    return successful;
}

#pragma mark - NSView mouseDragged & UIVIew touchesMoved
BOOL pointDraggedWithMethod(id view, id target, SEL selector) {
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

BOOL pointDraggedWithBlock(id view, Events events) {
    Class RapidView = object_getClass(view);
    BOOL successful = NO;
#if TARGET_OS_IPHONE
    Method method = class_getInstanceMethod(class_getSuperclass(RapidView), @selector(touchesMoved:withEvent:));
    successful = class_addMethod(RapidView, @selector(touchesMoved:withEvent:), imp_implementationWithBlock(^(id sender, id set, id event) {
        if(events) {
            events(sender, set, event);
        }
    }), method_getTypeEncoding(method));
#else
    Method method = class_getInstanceMethod(class_getSuperclass(RapidView), @selector(mouseDragged:));
    successful = class_addMethod(RapidView, @selector(mouseDragged:), imp_implementationWithBlock(^(id sender, id event) {
        if(events) {
            events(sender, nil, event);
        }
    }), method_getTypeEncoding(method));
#endif
    return successful;
}

#pragma mark - NSView mouseUp & UIVIew touchesEnded
BOOL pointUntouchedWithMethod(id view, id target, SEL selector) {
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

BOOL pointUntouchedWithBlock(id view, Events events) {
    Class RapidView = object_getClass(view);
    BOOL successful = NO;
#if TARGET_OS_IPHONE
    Method method = class_getInstanceMethod(class_getSuperclass(RapidView), @selector(touchesEnded:withEvent:));
    successful = class_addMethod(RapidView, @selector(touchesEnded:withEvent:), imp_implementationWithBlock(^(id sender, id set, id event) {
        if(events) {
            events(sender, set, event);
        }
    }), method_getTypeEncoding(method));
#else
    Method method = class_getInstanceMethod(class_getSuperclass(RapidView), @selector(mouseUp:));
    successful = class_addMethod(RapidView, @selector(mouseUp:), imp_implementationWithBlock(^(id sender, id event) {
        if(events) {
            events(sender, nil, event);
        }
    }), method_getTypeEncoding(method));
#endif
    return successful;
}
