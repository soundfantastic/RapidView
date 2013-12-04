//
//  CPPView.h
//
//  Created by Dragan Petrovic on 04/12/2013.
//
//

//C++ class for dynamic NSView/UIView drawing using C function pointer, Objective-C block, Objective-C method
//Example:
//NSView* view = ViewEngine<NSView>().functionDraw<Block, NSRect>(^(NSView* view, CGContextRef context){draw here}, frame, (BOOL)superDraw);
//UIView* view = ViewEngine<UIView>().methodDraw<CGRect>(@selector(view:context:), target, frame, (BOOL)superDraw);
//- (void) view:(UIView*)view context:(CGContextRef)context { draw here }
//...

#ifndef __muzikBox__CPPView__
#define __muzikBox__CPPView__

#include <iostream>
#include <typeinfo>

#if TARGET_OS_IPHONE
    #import <objc/runtime.h>
    #import <objc/message.h>
#else
    #import <objc/objc-runtime.h>
#endif


typedef void(^Block)(id view, CGContextRef context);
typedef void(*Function)(id view, CGContextRef context);

static int32_t VIEW_INDEX = 0;

template <class Superview> class ViewEngine {
    
public:
    ViewEngine() {}
    ~ViewEngine() {}

public:
    
    //Create view with Objective-c block or C function pointer
    template <class Type, class Rect>
    Class functionDraw(Type function, Rect frame, BOOL superDraw=YES) {
        NSString *ident = [NSString stringWithFormat:@"VIEW_WITH_%s_%d", typeid(Type).name(), ++VIEW_INDEX];
        Class Subview = allocateClass(ident);
        Method drawRect = class_getInstanceMethod(class_getSuperclass(Subview), @selector(drawRect:));
        class_addMethod(Subview, @selector(drawRect:), imp_implementationWithBlock(^(id sender, Rect dirtyRect) {
            if(superDraw) {
                superDrawRect(Subview, dirtyRect);
            }
            if(function) {
                CGContextRef graphicContext = NULL;
#if TARGET_OS_IPHONE
                graphicContext = UIGraphicsGetCurrentContext();
#else
                graphicContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
#endif
                function(sender, graphicContext);
            }
        }), method_getTypeEncoding(drawRect));
        
        return [[Subview alloc] initWithFrame:frame];
    }
    
    template <class Rect>
    id methodDraw(SEL selector, id target, Rect frame, BOOL superDraw=YES) {
        NSString* ident = [NSString stringWithFormat:@"VIEW_WITH_OBJC_METHOD_%d", ++VIEW_INDEX];
        Class Subview = allocateClass(ident);
        Method drawRect = class_getInstanceMethod(class_getSuperclass(Subview), @selector(drawRect:));
        class_addMethod(Subview, @selector(drawRect:), imp_implementationWithBlock(^(id sender, Rect dirtyRect) {
            if(superDraw) {
                superDrawRect(Subview, dirtyRect);
            }
            if(class_respondsToSelector(object_getClass(target), selector)) {
                CGContextRef graphicContext = NULL;
#if TARGET_OS_IPHONE
                graphicContext = UIGraphicsGetCurrentContext();
#else
                graphicContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
#endif
                objc_msgSend(target, selector, sender, graphicContext);
            }
        }), method_getTypeEncoding(drawRect));
        
        return [[Subview alloc] initWithFrame:frame];
    }
    
private:
    
    Class allocateClass(NSString* ident) {
        return objc_allocateClassPair([Superview class], [ident UTF8String], 0);
    }
    
    void superDrawRect(Class view, CGRect dirtyRect) {
        struct objc_super superView;
        superView.receiver = (id)view;
        superView.super_class = [Superview class];
        objc_msgSendSuper(&superView, @selector(drawRect:), dirtyRect);
    }
};

#endif /* defined(__muzikBox__CPPView__) */

