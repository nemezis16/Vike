//
//  VIKEAnalytics.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 29.04.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VikeAnalyticsConfiguration.h"

static NSString *const VikePayloadKeyAnonymousID = @"anonymousID";
static NSString *const VikePayloadKeyContext = @"context";
static NSString *const VikePayloadKeyIntegrations = @"integrations";

@interface VikeAnalytics : NSObject

@property (strong, nonatomic, readonly) VikeAnalyticsConfiguration *configuration;

+ (instancetype)sharedAnalytics;

+ (void)setupWithConfiguration:(VikeAnalyticsConfiguration *)configuration;

- (void)identify:(NSString *)userId;
- (void)identify:(NSString *)userId traits:(NSDictionary *)traits;
- (void)identify:(NSString *)userId traits:(NSDictionary *)traits options:(NSDictionary *)options;

- (void)track:(NSString *)event;
- (void)track:(NSString *)event properties:(NSDictionary *)properties;
- (void)track:(NSString *)event properties:(NSDictionary *)properties options:(NSDictionary *)options;

- (void)screen:(NSString *)screenTitle;
- (void)screen:(NSString *)screenTitle properties:(NSDictionary *)properties;
- (void)screen:(NSString *)screenTitle properties:(NSDictionary *)properties options:(NSDictionary *)options;

- (NSDictionary *)bundledIntegrations;

@end
