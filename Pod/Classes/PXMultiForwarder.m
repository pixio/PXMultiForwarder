//
//  PXMultiForwarder.m
//  ActiveTrac
//
//  Created by Spencer Phippen on 2015/08/17.
//
//

#import "PXMultiForwarder.h"

static BOOL isSelectorOwning(SEL sel) {
    // http://clang.llvm.org/docs/AutomaticReferenceCounting.html#method-families
    static const char* strings[5] = {"alloc", "copy", "mutableCopy", "new", "init"};
    static int lengths[5] = {5, 4, 11, 3, 4};

    NSString* name = NSStringFromSelector(sel);
    NSUInteger cLength = [name lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    const char* cName = [name UTF8String];
    
    // Skip leading underscores
    while (*cName == '_') {
        cName++;
        cLength--;
    }
    
    for (int i = 0; i < 5; i++) {
        if (cLength < lengths[i])
            continue;
        
        int result = memcmp(cName, strings[i], lengths[i]);
        if (result != 0)
            continue;
        
        if (cLength == lengths[i])
            return TRUE;
        
        char after = cName[lengths[i]];
        bool islowercaseAlpha = (after >= 'a') && (after <= 'z');
        if (!islowercaseAlpha)
            return TRUE;
    }
    
    return FALSE;
}
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

static NSMethodSignature* makeSignatureForSignature(NSMethodSignature* sig) {
    if (!needToChange(sig)) {
        return sig;
    }

    NSMutableData* encodingString = [NSMutableData data];
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
    NSMutableArray* objects = [NSMutableArray array];
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

- (void) dealloc {
    [super dealloc];
    [_wrappedObjects release];
}

- (NSMethodSignature*) methodSignatureForSelector:(SEL)sel {
    id firstObject = [_wrappedObjects objectAtIndex:0];
    NSMethodSignature* sig = [firstObject methodSignatureForSelector:sel];
    return makeSignatureForSignature(sig);
}

- (void) forwardInvocation:(NSInvocation*)invocation {
    if (shouldCollect([invocation methodSignature])) {
        NSMutableArray* toWrap = [NSMutableArray array];
        for (id obj in _wrappedObjects) {
            id returnObject;
            [invocation invokeWithTarget:obj];
            [invocation getReturnValue:&returnObject];
            [toWrap addObject:returnObject];
        }
        BOOL isOwning = isSelectorOwning([invocation selector]);
        PXMultiForwarder* wrapper = [[PXMultiForwarder alloc] initWithArrayOfObjects:toWrap];
        if (!isOwning) {
            [wrapper autorelease];
        }

        [invocation setReturnValue:&wrapper];
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
    NSMutableArray* toWrap = [NSMutableArray array];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[NSObject methodSignatureForSelector:sel]];
    [invocation setSelector:sel];
    for (id obj in _wrappedObjects) {
        id result;
        [invocation invokeWithTarget:obj];
        [invocation getReturnValue:&result];
        [toWrap addObject:result];
    }
    return [[[PXMultiForwarder alloc] initWithArrayOfObjects:toWrap] autorelease];
}

@end
