//
//  VikeMixpanelIntegration.m
//  VikeTestProject
//
//  Created by user on 05.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeMixpanelIntegration.h"

#import "VikeIdentifyPayload.h"
#import "VikeTrackPayload.h"
#import "VikeScreenPayload.h"

#import "VikeUtils.h"

#import <Mixpanel/Mixpanel.h>

@implementation VikeMixpanelIntegration

#pragma mark - Initializers

- (instancetype)initWithSettings:(NSDictionary *)settings
{
    if (self = [super init]) {
        _settings = settings;
        NSString *token = STR_OR_WS(self.settings[@"credentials"][@"token"]);
        [Mixpanel sharedInstanceWithToken:token];
    }
    return self;
}

#pragma mark - VikeIntegrationProtocol

- (void)identify:(VikeIdentifyPayload *)payload {
    if ([self userIdIsSet:payload]) {
        [[Mixpanel sharedInstance] identify:payload.userId];
        VikeLog(@"[[Mixpanel sharedInstance] identify:%@]", payload.userId);
    }
    
    NSDictionary *map = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"$first_name", @"firstName",
                         @"$last_name", @"lastName",
                         @"$created", @"createdAt",
                         @"$last_seen", @"lastSeen",
                         @"$email", @"email",
                         @"$name", @"name",
                         @"$username", @"username",
                         @"$phone", @"phone", nil];
    
    if ([self setAllTraitsByDefault]) {
        NSDictionary *mappedTraits = [VikeMixpanelIntegration map:payload.traits withMap:map];
        
        [[Mixpanel sharedInstance] registerSuperProperties:mappedTraits];
        VikeLog(@"[[Mixpanel sharedInstance] registerSuperProperties:%@]", mappedTraits);
        
        if ([self peopleEnabled]) {
            [[[Mixpanel sharedInstance] people] set:mappedTraits];
            VikeLog(@"[[[Mixpanel sharedInstance] people] set:%@]", mappedTraits);
        }
        return;
    }
    
    NSArray *superProperties = [self.settings objectForKey:@"superProperties"];
    NSMutableDictionary *superPropertyTraits = [NSMutableDictionary dictionaryWithCapacity:superProperties.count];
    for (NSString *superProperty in superProperties) {
        superPropertyTraits[superProperty] = payload.traits[superProperty];
    }
    NSDictionary *mappedSuperProperties = [VikeMixpanelIntegration map:superPropertyTraits
                                                               withMap:map];
    [[Mixpanel sharedInstance] registerSuperProperties:mappedSuperProperties];
    VikeLog(@"[[Mixpanel sharedInstance] registerSuperProperties:%@]", mappedSuperProperties);
    
    if ([self peopleEnabled]) {
        NSArray *peopleProperties = [self.settings objectForKey:@"peopleProperties"];
        NSMutableDictionary *peoplePropertyTraits = [NSMutableDictionary dictionaryWithCapacity:peopleProperties.count];
        for (NSString *peopleProperty in peopleProperties) {
            peoplePropertyTraits[peopleProperty] = payload.traits[peopleProperty];
        }
        NSDictionary *mappedPeopleProperties = [VikeMixpanelIntegration map:peoplePropertyTraits withMap:map];
        [[[Mixpanel sharedInstance] people] set:mappedPeopleProperties];
        VikeLog(@"[[[Mixpanel sharedInstance] people] set:%@]", mappedSuperProperties);
    }
}

- (void)screen:(VikeScreenPayload *)payload
{
    NSString *event = [[NSString alloc] initWithFormat:@"Viewed %@ Screen", payload.name];
    [self realTrack:event properties:payload.properties];
}

- (void)track:(VikeTrackPayload *)payload {
    [self realTrack:payload.event properties:payload.properties];
}

- (void)reset
{
    [self flush];
    
    [[Mixpanel sharedInstance] reset];
    VikeLog(@"[[Mixpanel sharedInstance] reset]");
}

- (void)flush
{
    [[Mixpanel sharedInstance] flush];
    VikeLog(@"[[Mixpanel sharedInstance] flush]");
}

- (void)registeredForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[[Mixpanel sharedInstance] people] addPushDeviceToken:deviceToken];
    VikeLog(@"[[[[Mixpanel sharedInstance] people] addPushDeviceToken:%@]", deviceToken);
}

#pragma mark - Private

+ (NSDictionary *)map:(NSDictionary *)dictionary withMap:(NSDictionary *)map
{
    NSMutableDictionary *mapped = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    [map enumerateKeysAndObjectsUsingBlock:^(NSString *original, NSString *new, BOOL* stop) {
        id data = [mapped objectForKey:original];
        if (data) {
            [mapped setObject:data forKey:new];
            [mapped removeObjectForKey:original];
        }
    }];
    
    return [mapped copy];
}

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

- (void)realTrack:(NSString *)event properties:(NSDictionary *)properties
{
    [[Mixpanel sharedInstance] track:event properties:properties];
    if (![self peopleEnabled]) {
        return;
    }
    
    NSNumber *revenue = [VikeMixpanelIntegration extractRevenue:properties withKey:@"revenue"];
    if (revenue) {
        [[[Mixpanel sharedInstance] people] trackCharge:revenue];
        VikeLog(@"[[[Mixpanel sharedInstance] people] trackCharge:%@]", revenue);
    }

    if ([self eventShouldIncrement:event]) {
        [[[Mixpanel sharedInstance] people] increment:event by:@1];
        VikeLog(@"[[[Mixpanel sharedInstance] people] increment:%@ by:1]", event);
        
        NSString *lastEvent = [NSString stringWithFormat:@"Last %@", event];
        NSDate *lastDate = [NSDate date];
        [[[Mixpanel sharedInstance] people] set:lastEvent to:lastDate];
        VikeLog(@"[[[Mixpanel sharedInstance] people] set:%@ to:%@]", lastEvent, lastDate);
    }
}

- (BOOL)eventShouldIncrement:(NSString *)event
{
    NSArray *increments = [self.settings objectForKey:@"increments"];
    for (NSString *increment in increments) {
        if ([event caseInsensitiveCompare:increment] == NSOrderedSame) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)userIdIsSet:(VikeIdentifyPayload *)payload
{
    return payload.userId != nil && [payload.userId length] != 0;
}

- (BOOL)setAllTraitsByDefault
{
    return [(NSNumber *)self.settings[@"setAllTraitsByDefault"] boolValue];
}

- (BOOL)peopleEnabled
{
    return [(NSNumber *)self.settings[@"people"] boolValue];
}

@end
