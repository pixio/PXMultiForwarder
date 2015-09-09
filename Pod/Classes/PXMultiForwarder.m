//
//  PXMultiForwarder.m
//  ActiveTrac
//
//  Created by Spencer Phippen on 2015/08/17.
//
//

#import "PXMultiForwarder.h"

static BOOL shouldCollect(NSMethodSignature* sig) {
    const char* const objEncoding = @encode(NSObject*);
    const char* const classEncoding = @encode(typeof([NSObject class]));
    
    BOOL shouldCollect = (strcmp(objEncoding, [sig methodReturnType]) == 0)
                      || (strcmp(classEncoding, [sig methodReturnType]) == 0);
    return shouldCollect;
}

static BOOL needToChange(NSMethodSignature* sig) {
    const char* const classEncoding = @encode(typeof([NSObject class]));
    return strcmp(classEncoding, [sig methodReturnType]) == 0;
}

static NSMethodSignature* newSignatureForSignature(NSMethodSignature* sig) {
    if (!needToChange(sig)) {
        return sig;
    }

    NSMutableData* encodingString = [[NSMutableData alloc] init];
    void (^appendCString)(const char*) = ^(const char* data) {
        [encodingString appendBytes:data length:strlen(data)];
    };
    
    const char* returnType = @encode(id);
    appendCString(returnType);
    
    for (NSUInteger i = 0; i < [sig numberOfArguments]; i++)
        appendCString([sig getArgumentTypeAtIndex:i]);

    [encodingString appendBytes:"\0" length:1];
    
    return [NSMethodSignature signatureWithObjCTypes:[encodingString bytes]];
}

@interface PXMultiForwarder ()
- (PXMultiForwarder*) basicAccumulateWrapperForNSObjectSelector:(SEL)sel;
@end

@implementation PXMultiForwarder

- (instancetype) initWithObjects:(id)firstObject, ... {
    NSMutableArray* objects = [[NSMutableArray alloc] init];
    va_list argumentList;
    va_start(argumentList, firstObject);
    for (id thisObject = firstObject; thisObject != nil; thisObject = va_arg(argumentList, id)) {
        [objects addObject:thisObject];
    }
    va_end(argumentList);

    return [self initWithArrayOfObjects:objects];
}

- (instancetype) initWithArrayOfObjects:(NSArray*)objects {
    if ([objects count] == 0)
        return nil;
    
    _wrappedObjects = [objects copy];
    return self;
}

- (NSMethodSignature*) methodSignatureForSelector:(SEL)sel {
    id firstObject = [_wrappedObjects objectAtIndex:0];
    NSMethodSignature* sig = [firstObject methodSignatureForSelector:sel];
    return newSignatureForSignature(sig);
}

- (void) forwardInvocation:(NSInvocation*)invocation {
    if (shouldCollect([invocation methodSignature])) {
        NSMutableArray* toWrap = [[NSMutableArray alloc] init];
        for (id obj in _wrappedObjects) {
            id returnObject;
            [invocation invokeWithTarget:obj];
            [invocation getReturnValue:&returnObject];
            [toWrap addObject:returnObject];
        }
        PXMultiForwarder* wrapper = [[PXMultiForwarder alloc] initWithArrayOfObjects:toWrap];
        void* wrapperBuf = (void*)CFBridgingRetain(wrapper);
        [invocation setReturnValue:&wrapperBuf];
    } else {
        for (id obj in _wrappedObjects) {
            [invocation invokeWithTarget:obj];
        }
    }
}

- (Class) class {
    return (Class)[self basicAccumulateWrapperForNSObjectSelector:_cmd];
}

- (Class) superclass {
    return (Class)[self basicAccumulateWrapperForNSObjectSelector:_cmd];
}

- (PXMultiForwarder*) basicAccumulateWrapperForNSObjectSelector:(SEL)sel {
    NSMutableArray* toWrap = [[NSMutableArray alloc] init];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[NSObject methodSignatureForSelector:sel]];
    [invocation setSelector:sel];
    for (id obj in _wrappedObjects) {
        id result;
        [invocation invokeWithTarget:obj];
        [invocation getReturnValue:&result];
        [toWrap addObject:result];
    }
    return [[PXMultiForwarder alloc] initWithArrayOfObjects:toWrap];
}

@end
