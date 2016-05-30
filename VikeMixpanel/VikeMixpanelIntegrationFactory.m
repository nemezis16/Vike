//
//  VikeMixpanelIntegrationFactory.m
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeMixpanelIntegrationFactory.h"
#import "VikeIntegrationFactory.h"
#import "VikeIntegrationProtocol.h"
#import "VikeAnalytics.h"
#import "VikeMixpanelIntegration.h"

@implementation VikeMixpanelIntegrationFactory

+ (instancetype)instance
{
    static dispatch_once_t once;
    static VikeMixpanelIntegrationFactory *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id<VikeIntegrationProtocol>)createWithSettings:(NSDictionary *)settings forAnalytics:(VikeAnalytics *)analytics
{
    return [[VikeMixpanelIntegration alloc] initWithSettings:settings];
}

- (NSString *)key
{
    return @"mixpanel";
}

@end
