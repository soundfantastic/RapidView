//
//  RapidView(constructor).mm
//  RapidView
//
//  Created by Dragan Petrovic on 14/11/2013.
//  Copyright (c) 2013 Polytonic. All rights reserved.
//

#include "RapidView(constructor).h"
#include "RapidView.h"

#if TARGET_OS_IPHONE
    #import <objc/runtime.h>
    #import <objc/message.h>
    #define SUPERVIEW_STRING @"UIView"
    #define GRAPHIC_CONTEXT UIGraphicsGetCurrentContext()
#else
    #import <objc/objc-runtime.h>
    #define SUPERVIEW_STRING @"NSView"
    #define GRAPHIC_CONTEXT [[NSGraphicsContext currentContext] graphicsPort]
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
    Class superClass = NSClassFromString((NSString*)SUPERVIEW_STRING);
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
            objc_msgSend(target, selector, sender, (CGContextRef)GRAPHIC_CONTEXT);
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
            draw(sender, (CGContextRef)GRAPHIC_CONTEXT);
        }
    }), method_getTypeEncoding(drawRect));
    return [[RapidView alloc] initWithFrame:frame]; //dont forget to release this object
}
