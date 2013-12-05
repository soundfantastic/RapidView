//
//  CPPView.h
//
//  Created by Dragan Petrovic on 04/12/2013.
//
//

//C++ class for dynamic NSView/UIView drawing using C function pointer, Objective-C block, Objective-C method
//Example:
//NSView* view = ViewEngine<NSView>().inject_functionDraw<Block, NSRect>(^(NSView* view, CGContextRef context){draw here}, frame, (BOOL)superDraw);
//UIView* view = ViewEngine<UIView>().inject_methodDraw<CGRect>(@selector(view:context:), target, frame, (BOOL)superDraw);
//- (void) view:(UIView*)view context:(CGContextRef)context { draw here }
//...
//Inject Mouse and UITouch events
//ViewEngine<NSView>().inject_functionPointMoved<BlockEvents>(ns_view, ^(id view, id set, id events) {
//ViewEngine<UIView>().inject_functionPointMoved<BlockEvents>(ui_view, ^(id view, id set, id events) {
//NSLog(@"Moved %@", events);
//});


#ifndef __RapidView__CPPView__
#define __RapidView__CPPView__

#include <iostream>
#include <typeinfo>

#if TARGET_OS_IPHONE
    #import <objc/runtime.h>
    #import <objc/message.h>
#else
    #import <objc/objc-runtime.h>
#endif


static int32_t VIEW_INDEX = 0;

typedef void(^BlockDraw)(id view, CGContextRef context);
typedef void(*FunctionDraw)(id view, CGContextRef context);

typedef void(^BlockEvents)(id view, id set, id events);
typedef void(*FunctionEvents)(id view, id set, id events);

template <class Superview> class ViewEngine {
    
public:
    ViewEngine() {}
    ~ViewEngine() {}
    
    //Create view with Objective-c block or C function pointer
    template <class Type, class Rect>
    Class inject_functionDraw(Type function, Rect frame, BOOL superDraw=YES) {
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
    Class inject_methodDraw(SEL selector, id target, Rect frame, BOOL superDraw=YES) {
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
    
    
    void inject_methodPointTouched(id view, id target, SEL selector) {
        Class Subview = object_getClass(view);
#if TARGET_OS_IPHONE
        Method method = class_getInstanceMethod(class_getSuperclass(Subview), @selector(touchesBegan:withEvent:));
        successful = class_addMethod(Subview, @selector(touchesBegan:withEvent:), imp_implementationWithBlock(^(id sender, id set, id event) {
            if(class_respondsToSelector(object_getClass(target), selector)) {
                objc_msgSend(target, selector, sender, set, event);
            }
        }), method_getTypeEncoding(method));
#else
        Method method = class_getInstanceMethod(class_getSuperclass(Subview), @selector(mouseDown:));
        class_addMethod(Subview, @selector(mouseDown:), imp_implementationWithBlock(^(id sender, id event) {
            if(class_respondsToSelector(object_getClass(target), selector)) {
                objc_msgSend(target, selector, sender, event);
            }
        }), method_getTypeEncoding(method));
#endif
    }
    
    void inject_methodPointUnTouched(id view, id target, SEL selector) {
        Class Subview = object_getClass(view);
#if TARGET_OS_IPHONE
        Method method = class_getInstanceMethod(class_getSuperclass(Subview), @selector(touchesEnded:withEvent:));
        successful = class_addMethod(Subview, @selector(touchesEnded:withEvent:), imp_implementationWithBlock(^(id sender, id set, id event) {
            if(class_respondsToSelector(object_getClass(target), selector)) {
                objc_msgSend(target, selector, sender, set, event);
            }
        }), method_getTypeEncoding(method));
#else
        Method method = class_getInstanceMethod(class_getSuperclass(Subview), @selector(mouseUp:));
        class_addMethod(Subview, @selector(mouseUp:), imp_implementationWithBlock(^(id sender, id event) {
            if(class_respondsToSelector(object_getClass(target), selector)) {
                objc_msgSend(target, selector, sender, event);
            }
        }), method_getTypeEncoding(method));
#endif
    }
    
    void inject_methodPointMoved(id view, id target, SEL selector) {
        Class Subview = object_getClass(view);
#if TARGET_OS_IPHONE
        Method method = class_getInstanceMethod(class_getSuperclass(Subview), @selector(touchesMoved:withEvent:));
        successful = class_addMethod(Subview, @selector(touchesMoved:withEvent:), imp_implementationWithBlock(^(id sender, id set, id event) {
            if(class_respondsToSelector(object_getClass(target), selector)) {
                objc_msgSend(target, selector, sender, set, event);
            }
        }), method_getTypeEncoding(method));
#else
        Method method = class_getInstanceMethod(class_getSuperclass(Subview), @selector(mouseDragged:));
        class_addMethod(Subview, @selector(mouseDragged:), imp_implementationWithBlock(^(id sender, id event) {
            if(class_respondsToSelector(object_getClass(target), selector)) {
                objc_msgSend(target, selector, sender, event);
            }
        }), method_getTypeEncoding(method));
#endif
    }
    
    
    //Functions
    template <class Events>
    BOOL inject_functionPointTouched(id view, Events events) {
        Class Subview = object_getClass(view);
        BOOL successful = NO;
#if TARGET_OS_IPHONE
        Method method = class_getInstanceMethod(class_getSuperclass(Subview), @selector(touchesBegan:withEvent:));
        successful = class_addMethod(Subview, @selector(touchesBegan:withEvent:), imp_implementationWithBlock(^(id sender, id set, id event) {
            if(events) {
                events(sender, set, event);
            }
        }), method_getTypeEncoding(method));
#else
        Method method = class_getInstanceMethod(class_getSuperclass(Subview), @selector(mouseDown:));
        successful = class_addMethod(Subview, @selector(mouseDown:), imp_implementationWithBlock(^(id sender, id event) {
            if(events) {
                events(sender, nil, event);
            }
        }), method_getTypeEncoding(method));
#endif
        return successful;
    }
    
    template <class Events>
    BOOL inject_functionPointUnTouched(id view, Events events) {
        Class Subview = object_getClass(view);
        BOOL successful = NO;
#if TARGET_OS_IPHONE
        Method method = class_getInstanceMethod(class_getSuperclass(Subview), @selector(touchesEnded:withEvent:));
        successful = class_addMethod(Subview, @selector(touchesEnded:withEvent:), imp_implementationWithBlock(^(id sender, id set, id event) {
            if(events) {
                events(sender, set, event);
            }
        }), method_getTypeEncoding(method));
#else
        Method method = class_getInstanceMethod(class_getSuperclass(Subview), @selector(mouseUp:));
        successful = class_addMethod(Subview, @selector(mouseUp:), imp_implementationWithBlock(^(id sender, id event) {
            if(events) {
                events(sender, nil, event);
            }
        }), method_getTypeEncoding(method));
#endif
        return successful;
    }
    
    template <class Events>
    BOOL inject_functionPointMoved(id view, Events events) {
        Class Subview = object_getClass(view);
        BOOL successful = NO;
#if TARGET_OS_IPHONE
        Method method = class_getInstanceMethod(class_getSuperclass(Subview), @selector(touchesMoved:withEvent:));
        successful = class_addMethod(Subview, @selector(touchesMoved:withEvent:), imp_implementationWithBlock(^(id sender, id set, id event) {
            if(events) {
                events(sender, set, event);
            }
        }), method_getTypeEncoding(method));
#else
        Method method = class_getInstanceMethod(class_getSuperclass(Subview), @selector(mouseDragged:));
        successful = class_addMethod(Subview, @selector(mouseDragged:), imp_implementationWithBlock(^(id sender, id event) {
            if(events) {
                events(sender, nil, event);
            }
        }), method_getTypeEncoding(method));
#endif
        return successful;
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
#endif /* defined(__RapidView__CPPView__) */

