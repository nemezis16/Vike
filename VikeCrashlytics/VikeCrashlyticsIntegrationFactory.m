//
//  VikeCrashlyticsFactory.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 20.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeCrashlyticsIntegrationFactory.h"
#import "VikeCrashlytics.h"

@implementation VikeCrashlyticsIntegrationFactory

+ (instancetype)instance
{
    static dispatch_once_t once;
    static VikeCrashlyticsIntegrationFactory *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[VikeCrashlyticsIntegrationFactory alloc] init];
    });
    return sharedInstance;
}

- (id<VikeIntegrationProtocol>)createWithSettings:(NSDictionary *)settings forAnalytics:(VikeAnalytics *)analytics
{
    return [[VikeCrashlytics alloc]initWithSettings:settings];
}

- (NSString *)key
{
    return @"crashlytics";
}

@end
