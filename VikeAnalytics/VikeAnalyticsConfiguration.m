//
//  VikeAnalyticsConfiguration.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 03.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeAnalyticsConfiguration.h"

#import "VikeIntegrationFactory.h"

@interface VikeAnalyticsConfiguration ()

@property (strong, nonatomic, readwrite) NSString *writeKey;
@property (strong, nonatomic, readwrite) NSMutableArray *factories;

@end

@implementation VikeAnalyticsConfiguration

#pragma mark - Initializers

- (instancetype)init
{
    self = [super init];
    if (self) {
        _factories = [NSMutableArray array];
        [_factories addObject:[VikeIntegrationFactory instance]];
    }
    return self;
}

#pragma mark - Public

+ (instancetype)configurationWithWriteKey:(NSString *)writeKey
{
    VikeAnalyticsConfiguration *configuration = [[VikeAnalyticsConfiguration alloc] init];
    configuration.writeKey = writeKey;
    
    return configuration;
}

#pragma mark - Private

- (void)use:(id<VikeIntegrationFactoryProtocol>)factory
{
    [self.factories addObject:factory];
}

@end
