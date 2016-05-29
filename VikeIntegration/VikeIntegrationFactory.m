//
//  VikeUnitIntegrationFactory.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 04.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeIntegrationFactory.h"

#import "VikeIntegration.h"
#import "VikeAnalytics.h"

@implementation VikeIntegrationFactory

+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    static VikeIntegrationFactory *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id<VikeIntegrationProtocol>)createWithSettings:(NSDictionary *)settings forAnalytics:(VikeAnalytics *)analytics
{
    return [[VikeIntegration alloc]initWithAnalytics:analytics];
}

- (NSString *)key
{
    return @"vike";
}

@end
