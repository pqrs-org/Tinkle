// -*- mode: objective-c -*-

@import Cocoa;

@interface OpenAtLoginObjc : NSObject

+ (BOOL)enabled:(NSURL *)appURL;

+ (void)enable:(NSURL *)appURL;
+ (void)disable:(NSURL *)appURL;

@end
