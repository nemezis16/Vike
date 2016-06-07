//
//  VikeAmplitudeIntegrationFactory.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 07.06.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeAmplitudeIntegrationFactory.h"

#import "VikeIntegrationProtocol.h"

#import "VikeAmplitudeIntegration.h"
#import "VikeAnalytics.h"

@implementation VikeAmplitudeIntegrationFactory

+ (instancetype)instance
{
    static dispatch_once_t once;
    static VikeAmplitudeIntegrationFactory *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[VikeAmplitudeIntegrationFactory alloc] init];
    });
    return sharedInstance;
}

- (id<VikeIntegrationProtocol>)createWithSettings:(NSDictionary *)settings forAnalytics:(VikeAnalytics *)analytics
{
    return [[VikeAmplitudeIntegration alloc] initWithSettings:settings];
}

- (NSString *)key
{
    return @"amplitude";
}

@end
