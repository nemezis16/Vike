//
//  VikeAmplitudeIntegration.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 07.06.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeAmplitudeIntegration.h"

#import "VikeIdentifyPayload.h"
#import "VikeTrackPayload.h"
#import "VikeScreenPayload.h"

#import "VikeAnalytics.h"
#import "VikeUtils.h"

@implementation VikeAmplitudeIntegration

#pragma mark - Initializers

- (id)initWithSettings:(NSDictionary *)settings
{
    if (self = [super init]) {
        _settings = settings;
        _amplitude = [Amplitude instance];
        
        if ([(NSNumber *)[self.settings objectForKey:@"trackSessionEvents"] boolValue]) {
            [Amplitude instance].trackingSessionEvents = true;
        }
        NSString *apiKey = STR_OR_WS(self.settings[@"credentials"][@"api_key"]);
        [[Amplitude instance] initializeApiKey:apiKey];
    }
    return self;
}

#pragma mark - Events

- (void)identify:(VikeIdentifyPayload *)payload
{
    [self.amplitude setUserId:payload.userId];
    [self.amplitude setUserProperties:payload.traits];
}

-(void)realTrack:(NSString *)event properties:(NSDictionary *)properties
{
    [self.amplitude logEvent:event withEventProperties:properties];
    
    NSNumber *revenue = [VikeAmplitudeIntegration extractRevenue:properties withKey:@"revenue"];
    if (revenue) {
        id productId = [properties objectForKey:@"productId"];
        if (!productId || ![productId isKindOfClass:[NSString class]]) {
            productId = nil;
        }
        id quantity = [properties objectForKey:@"quantity"];
        if (!quantity || ![quantity isKindOfClass:[NSNumber class]]) {
            quantity = [NSNumber numberWithInt:1];
        }
        id receipt = [properties objectForKey:@"receipt"];
        if (!receipt || ![receipt isKindOfClass:[NSString class]]) {
            receipt = nil;
        }
        
        [self.amplitude logRevenue:productId
                          quantity:[quantity integerValue]
                             price:revenue
                           receipt:receipt];
    }
}

- (void)track:(VikeTrackPayload *)payload
{
    [self realTrack:payload.event properties:payload.properties];
}

- (void)screen:(VikeScreenPayload *)payload
{
    NSString *event = [[NSString alloc] initWithFormat:@"Viewed %@ Screen", payload.name];
    [self realTrack:event properties:payload.properties];
}

#pragma mark - Private

+ (NSNumber *)extractRevenue:(NSDictionary *)dictionary withKey:(NSString *)revenueKey
{
    id revenueProperty = nil;
    
    for (NSString *key in dictionary.allKeys) {
        if ([key caseInsensitiveCompare:revenueKey] == NSOrderedSame) {
            revenueProperty = dictionary[key];
            break;
        }
    }
    
    if (revenueProperty) {
        if ([revenueProperty isKindOfClass:[NSString class]]) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            return [formatter numberFromString:revenueProperty];
        } else if ([revenueProperty isKindOfClass:[NSNumber class]]) {
            return revenueProperty;
        }
    }
    return nil;
}

- (void)flush
{
    [self.amplitude uploadEvents];
}

@end
