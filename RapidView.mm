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
    #define _THIS_SUPERVIEW_STRING @"UIView"
    #define _THIS_RECT CGRect
    #define _THIS_CONTEXT UIGraphicsGetCurrentContext()
#else
    #import <objc/objc-runtime.h>
    #define _THIS_SUPERVIEW_STRING @"NSView"
    #define _THIS_RECT NSRect
    #define _THIS_CONTEXT (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort]
#endif

static int32_t _THIS_VIEW_COUNT = 0;
//struct objc_super superView = { _THIS_VIEW_, _THIS_SUPERCLASS };
//objc_msgSendSuper(&superView, @selector(drawRect:));

id drawWithMethod(SEL selector, id target, CGRect frame) {
    const char* name = [[NSString stringWithFormat:@"_VIEW_WITH_METHOD_%d", ++_THIS_VIEW_COUNT] UTF8String];
    Class _THIS_SUPERCLASS = NSClassFromString(_THIS_SUPERVIEW_STRING);
    Class _THIS_VIEW_ = objc_allocateClassPair(_THIS_SUPERCLASS, name, 0);
    class_addMethod(_THIS_VIEW_, NSSelectorFromString(@"drawRect:"), imp_implementationWithBlock(^(id _self, CGRect dirtyRect) {
        if(class_respondsToSelector(object_getClass(target), selector)) {
            objc_msgSend(target, selector, _self, _THIS_CONTEXT);
        }
    }), [[NSString stringWithFormat:@"v:%s", @encode(_THIS_RECT)] UTF8String]);
    return [[_THIS_VIEW_ alloc] initWithFrame:frame]; //dont forget to release this object
}

id drawWithBlock(Draw block, CGRect frame) {
    const char* name = [[NSString stringWithFormat:@"_VIEW_WITH_BLOCK_%d", ++_THIS_VIEW_COUNT] UTF8String];
    Class _THIS_SUPERCLASS = NSClassFromString(_THIS_SUPERVIEW_STRING);
    Class _THIS_VIEW_ = objc_allocateClassPair(_THIS_SUPERCLASS, name, 0);
    class_addMethod(_THIS_VIEW_, NSSelectorFromString(@"drawRect:"), imp_implementationWithBlock(^(id _self, CGRect dirtyRect) {
        if(block) {
            block(_self, _THIS_CONTEXT);
        }
    }), [[NSString stringWithFormat:@"v:%s", @encode(_THIS_RECT)] UTF8String]);
    return [[_THIS_VIEW_ alloc] initWithFrame:frame]; //dont forget to release this object
}
