//
//  VikeCrashlytics.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 20.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeCrashlytics.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation VikeCrashlytics

- (instancetype)initWithSettings:(NSDictionary *)settings
{
    self = [super init];
    if (self) {
        [Fabric with:@[[Crashlytics class]]];
    }
    return self;
}

@end
