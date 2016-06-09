//
//  VikeLocalyticsIntegration.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 06.06.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeLocalyticsIntegration.h"

#import "VikeIdentifyPayload.h"
#import "VikeTrackPayload.h"
#import "VikeScreenPayload.h"

#import "VikeUtils.h"

@import Localytics;

@implementation VikeLocalyticsIntegration

#pragma mark - Initializers

- (instancetype)initWithSettings:(NSDictionary *)settings
{
    if (self = [super init]) {
        _settings = settings;
        NSString *appKey = STR_OR_WS(self.settings[@"credentials"][@"app_key"]);
        [Localytics autoIntegrate:appKey launchOptions:nil];
    }
    return self;
}

#pragma mark - Events

- (void)identify:(VikeIdentifyPayload *)payload
{
    if (payload.userId) {
        [Localytics setCustomerId:payload.userId];
    }
    
    NSString *email = [payload.traits objectForKey:@"email"];
    if (email) {
        [Localytics setValue:email forIdentifier:@"email"];
    }
    NSString *name = [payload.traits objectForKey:@"name"];
    
    if (name) {
        [Localytics setValue:name forIdentifier:@"customer_name"];
    }
    
    [self setCustomDimensions:payload.traits];
    for (NSString *key in payload.traits) {
        NSString *traitValue =
        [NSString stringWithFormat:@"%@", [payload.traits objectForKey:key]];
        [Localytics setValue:traitValue
         forProfileAttribute:key
                   withScope:LLProfileScopeApplication];
    }
}

- (void)track:(VikeTrackPayload *)payload
{
    BOOL isBackgrounded = [[UIApplication sharedApplication] applicationState] !=
    UIApplicationStateActive;
    if (isBackgrounded) {
        [Localytics openSession];
    }
    
    NSNumber *revenue = [VikeLocalyticsIntegration extractRevenue:payload.properties withKey:@"revenue"];
    if (revenue) {
        [Localytics tagEvent:payload.event
                  attributes:payload.properties
       customerValueIncrease:@([revenue intValue] * 100)];
    } else {
        [Localytics tagEvent:payload.event attributes:payload.properties];
    }
    
    [self setCustomDimensions:payload.properties];
    
    if (isBackgrounded) {
        [Localytics closeSession];
    }
    
    [Localytics triggerInAppMessage:@"Item Purchased"];
}

- (void)screen:(VikeScreenPayload *)payload
{
    [Localytics tagScreen:payload.name];
}

+ (NSNumber *)extractRevenue:(NSDictionary *)dictionary withKey:(NSString *)revenueKey
{
    id revenueProperty;
    
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

- (void)setCustomDimensions:(NSDictionary *)dictionary
{
    NSDictionary *customDimensions = self.settings[@"dimensions"];
    
    for (NSString *key in dictionary) {
        if ([customDimensions objectForKey:key] != nil) {
            NSString *dimension = [customDimensions objectForKey:key];
            [Localytics setValue:[dictionary objectForKey:key]
              forCustomDimension:[dimension integerValue]];
        }
    }
}

- (void)registeredForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [Localytics setPushToken:deviceToken];
}

- (void)receivedRemoteNotification:(NSDictionary *)userInfo
{
    [Localytics handleNotification:userInfo];
}

- (void)flush
{
    [Localytics upload];
}

#pragma mark - Callbacks for app state changes

- (void)applicationDidEnterBackground
{
    [Localytics dismissCurrentInAppMessage];
    [Localytics closeSession];
    [Localytics upload];
}

- (void)applicationWillEnterForeground
{
    [Localytics openSession];
    [Localytics upload];
}

- (void)applicationWillTerminate
{
    [Localytics closeSession];
    [Localytics upload];
}
- (void)applicationWillResignActive
{
    [Localytics dismissCurrentInAppMessage];
    [Localytics closeSession];
    [Localytics upload];
}
- (void)applicationDidBecomeActive
{
    [Localytics openSession];
    [Localytics upload];
}

@end
