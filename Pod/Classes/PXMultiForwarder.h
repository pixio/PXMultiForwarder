//
//  PXMultiForwarder.h
//  ActiveTrac
//
//  Created by Spencer Phippen on 2015/08/17.
//
//

#import <Foundation/Foundation.h>

/**
 * A proxy that forwards method calls *recursively* to the objects that it wraps.
 * Use this class when you want to call the same method (and possibly methods on the return values of that method, and so on) on many objects.
 * Example:
 * @interface Foo : NSObject
 * - (void) printMessage;
 * - (Foo*) makeAnother;
 * - (int) getNumber;
 * @end
 * @implementation Foo
 * {
 *   int _number;
 * }
 * - (instancetype) init {
 *   static int counter = 1;
 *   self = [super init];
 *   if (!self)
 *     return nil;
 *   _number = counter++;
 *   return self;
 * }
 * - (void) printMessage {
 *   NSLog(@"printMessage called on %d", _number);
 * }
 * - (Foo*) makeAnother {
 *     return [[Foo alloc] init];
 * }
 * - (int) getNumber {
 *   return _number;
 * }
 * @end
 *
 * Foo* foo1 = [[Foo alloc] init];
 * Foo* foo2 = [[Foo alloc] init];
 * PXMultiForwarder* forwarder = [[PXMultiForwarder alloc] initWithObjects:foo1, foo2, nil];
 * Foo* fakeFoo = (Foo*)forwarder;
 *
 * // fakeNewFoo is actually an PXMultiForwarder that forwards to 2 Foo objects created
 * // inside the call to makeAnother
 * Foo* fakeNewFoo = [fakeFoo makeAnother];
 * [fakeNewFoo printMessage]; // Prints lines "printMessage called on 3" and "printMessage called on 4"
 * int number = [fakeNewFoo getNumber]; // number is 4, the return value of the last wrapped Foo object
 *
 *
 ***********************
 * TECHNICAL USAGE NOTES
 ***********************
 * Every method call you make on PXMultiForwarder gets forwarded to all of the objects it wraps (with a few exceptions, noted below).
 * However, the value returned from the method call depends on the return type of the original method.
 * If the original method returns an object or class object, the results are collected into an PXMultiForwarder, which is the return value.
 * However, if the original method returns any other type (including void), the return value is the return value of the LAST wrapped object.
 *
 * SOME methods are not forwarded. Specifically, any method implemented by this class, including NSProxy methods
 * (e.g. alloc, dealloc, description, any method in the NSObject protocol) is called directly on the
 * PXMultiForwarder and handled in the typical fashion. However, some of these methods (see the bottom of this file)
 * are overridden to forward instead of being handled normally.
 */
@interface PXMultiForwarder : NSProxy

- (instancetype) initWithObjects:(id)firstObject, ...;
- (instancetype) initWithArrayOfObjects:(NSArray*)objects;

@property (readonly) NSArray* wrappedObjects;

#pragma mark NSProxy methods overridden to forward
/** Overridden to forward to the wrapped objects (returns an PXMultiForwarder*). */
- (Class) class;

/** Overridden to forward to the wrapped objects (returns an PXMultiForwarder*). */
- (Class) superclass;

@end