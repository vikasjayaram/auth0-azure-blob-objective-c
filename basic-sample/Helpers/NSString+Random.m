//
//  NSString+Random.m
//  basic-sample
//
//  Created by Vikas Kannurpatti Jayaram on 8/08/2016.
//  Copyright © 2016 Auth0. All rights reserved.
//

#import "NSString+Random.h"

static NSString * const letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

@implementation NSString(Random)
+ (NSString *) randomStringWithLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}
@end
