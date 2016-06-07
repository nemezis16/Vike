//
//  VikeLocalyticsIntegrationFactory.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 06.06.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeLocalyticsIntegrationFactory.h"

#import "VikeIntegrationProtocol.h"

#import "VikeLocalyticsIntegration.h"
#import "VikeAnalytics.h"

@implementation VikeLocalyticsIntegrationFactory

+ (instancetype)instance
{
    static dispatch_once_t once;
    static VikeLocalyticsIntegrationFactory *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[VikeLocalyticsIntegrationFactory alloc] init];
    });
    return sharedInstance;
}

- (id<VikeIntegrationProtocol>)createWithSettings:(NSDictionary *)settings forAnalytics:(VikeAnalytics *)analytics
{
    return [[VikeLocalyticsIntegration alloc] initWithSettings:settings];
}

- (NSString *)key
{
    return @"localytics";
}

@end
