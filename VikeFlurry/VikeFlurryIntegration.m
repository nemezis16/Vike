//
//  VikeFlurryIntegration.m
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeFlurryIntegration.h"

#import "VikeIdentifyPayload.h"
#import "VikeTrackPayload.h"
#import "VikeScreenPayload.h"

#import "VikeUtils.h"

#import <Flurry-iOS-SDK/Flurry.h>

@implementation VikeFlurryIntegration

#pragma mark - Initializers

- (id)initWithSettings:(NSDictionary *)settings
{
    if (self = [super init]) {
        _settings = settings;
        
        [Flurry setLogLevel:FlurryLogLevelNone];
        NSNumber *sessionContinueSeconds = settings[@"sessionContinueSeconds"];
        if (sessionContinueSeconds) {
            [Flurry setSessionContinueSeconds:[sessionContinueSeconds intValue]];
        }
        NSString *apiKey = STR_OR_WS(self.settings[@"credentials"][@"api_key"]);
        [Flurry startSession:apiKey];
    }
    return self;
}

#pragma mark - VikeIntegrationProtocol

- (void)identify:(VikeIdentifyPayload *)payload
{
    [Flurry setUserID:payload.userId];
    
    NSDictionary *traits = payload.traits;
    if (!traits) {
        return;
    }
    
    NSString *gender = traits[@"gender"];
    if (gender) {
        [Flurry setGender:[gender substringToIndex:1]];
    }
    
    NSString *age = traits[@"age"];
    if (age) {
        [Flurry setAge:[age intValue]];
    }
    
    NSDictionary *location = traits[@"location"];
    if (location) {
        float latitude = [location[@"latitude"] floatValue];
        float longitude = [location[@"longitude"] floatValue];
        float horizontalAccuracy = [location[@"horizontalAccuracy"] floatValue];
        float verticalAccuracy = [location[@"verticalAccuracy"] floatValue];
        [Flurry setLatitude:latitude longitude:longitude horizontalAccuracy:horizontalAccuracy verticalAccuracy:verticalAccuracy];
    }
}

- (void)track:(VikeTrackPayload *)payload
{
    [Flurry logEvent:payload.event withParameters:payload.properties];
}

- (void)screen:(VikeScreenPayload *)payload
{
    NSString *event = [[NSString alloc] initWithFormat:@"Viewed %@ Screen", payload.name];
    [Flurry logEvent:event withParameters:payload.properties];
    
    [Flurry logPageView];
}

@end