//
//  NSString+Utils.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 29.04.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "NSString+Utils.h"

static NSString *const letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

@implementation NSString (Utils)

+ (NSString *)randomStringWithLength:(NSInteger)lenght
{
    NSMutableString *randomString = [NSMutableString stringWithCapacity:lenght];
    
    for (NSInteger i = 0; i < lenght; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex:arc4random_uniform((u_int32_t)letters.length)]];
    }
    return randomString;
}

@end
