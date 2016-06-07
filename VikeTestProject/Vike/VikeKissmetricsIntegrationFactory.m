//
//  VikeKissmetricsIntegrationFactory.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 07.06.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeKissmetricsIntegrationFactory.h"

#import "VikeIntegrationProtocol.h"
#import "VikeKissmetricsIntegration.h"
#import "VikeAnalytics.h"

@implementation VikeKissmetricsIntegrationFactory

+ (instancetype)instance
{
    static dispatch_once_t once;
    static VikeKissmetricsIntegrationFactory *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[VikeKissmetricsIntegrationFactory alloc] init];
    });
    return sharedInstance;
}

- (id<VikeIntegrationProtocol>)createWithSettings:(NSDictionary *)settings forAnalytics:(VikeAnalytics *)analytics
{
    return [[VikeKissmetricsIntegration alloc] initWithSettings:settings];
}

- (NSString *)key
{
    return @"kissmetrics";
}

@end
