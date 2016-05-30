//
//  VikeFlurryIntegrationFactory.m
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeFlurryIntegrationFactory.h"
#import "VikeIntegrationProtocol.h"
#import "VikeFlurryIntegration.h"
#import "VikeAnalytics.h"

@implementation VikeFlurryIntegrationFactory

+ (id)instance
{
    static dispatch_once_t once;
    static VikeFlurryIntegrationFactory *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    return self;
}

- (id<VikeIntegrationProtocol>)createWithSettings:(NSDictionary *)settings forAnalytics:(VikeAnalytics *)analytics
{
    return [[VikeFlurryIntegration alloc] initWithSettings:settings];
}

- (NSString *)key
{
    return @"flurry";
}

@end
