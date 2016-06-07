//
//  VikeKissmetricsIntegration.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 07.06.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <KISSmetricsSDK/KISSmetricsAPI.h>

#import "VikeKissmetricsIntegration.h"

#import "VikeIdentifyPayload.h"
#import "VikeTrackPayload.h"
#import "VikeScreenPayload.h"

#import "VikeAnalytics.h"

@implementation VikeKissmetricsIntegration

#pragma mark - Initializers

- (id)initWithSettings:(NSDictionary *)settings
{
    if (self = [super init]) {
        _settings = settings;
#warning hardcoded 
        [KISSmetricsAPI sharedAPIWithKey:@"25731d072f19e6982adc5913441eb9123054374e"];
    }
    return self;
}

#pragma mark - Events

- (void)identify:(VikeIdentifyPayload *)payload
{
    [[KISSmetricsAPI sharedAPI] identify:payload.userId];
}

- (void)track:(VikeTrackPayload *)payload
{
    [self recordWithEventString:payload.event properties:payload.properties];
}

- (void)screen:(VikeScreenPayload *)payload
{
    NSString *event = [[NSString alloc] initWithFormat:@"Viewed %@ Screen", payload.name];
    [self recordWithEventString:event properties:payload.properties];
}

#pragma mark - Private

- (void)recordWithEventString:(NSString *)event properties:(NSDictionary *)properties
{
    [[KISSmetricsAPI sharedAPI] record:event];
    if (properties) {
        [[KISSmetricsAPI sharedAPI] record:event withProperties:properties];
    }
}

@end
