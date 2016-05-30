//
//  VikeGoogleAnalyticsIntegrationFactory.m
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeGoogleAnalyticsIntegrationFactory.h"
#import "VikeIntegrationProtocol.h"
#import "VikeGoogleAnalyticsIntegration.h"
#import "VikeAnalytics.h"

#pragma mark - Initializers

@implementation VikeGoogleAnalyticsIntegrationFactory

+ (id)instance
{
    static dispatch_once_t once;
    static VikeGoogleAnalyticsIntegrationFactory *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - VikeIntegrationFactoryProtocol

- (id<VikeIntegrationProtocol>)createWithSettings:(NSDictionary *)settings forAnalytics:(VikeAnalytics *)analytics
{
    return [[VikeGoogleAnalyticsIntegration alloc] initWithSettings:settings];
}

- (NSString *)key
{
    return @"google_analytics";
}


@end
