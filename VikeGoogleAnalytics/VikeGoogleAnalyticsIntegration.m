//
//  VikeGoogleAnalyticsIntegration.m
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeGoogleAnalyticsIntegration.h"
#import "VikeIdentifyPayload.h"
#import "VikeTrackPayload.h"
#import "VikeScreenPayload.h"
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import <GoogleAnalytics/GAIFields.h>
#import "VikeUtils.h"

@implementation VikeGoogleAnalyticsIntegration

#pragma mark - Initializers

- (id)initWithSettings:(NSDictionary *)settings
{
    if (self = [super init]) {
        _settings = settings;
        NSString *trackingId = STR_OR_WS(settings[@"credentials"][@"tid"]);
        _tracker = [[GAI sharedInstance] trackerWithTrackingId:trackingId];
        [[GAI sharedInstance] setDefaultTracker:self.tracker];
        
        NSString *reportUncaughtExceptions = settings[@"reportUncaughtExceptions"];
        if ([reportUncaughtExceptions boolValue]) {
            [GAI sharedInstance].trackUncaughtExceptions = YES;
            VikeLog(@"[[GAI sharedInstance] defaultTracker] trackUncaughtExceptions = YES;");
        }
        
        NSString *demographicReports = [settings objectForKey:@"doubleClick"];
        if ([demographicReports boolValue]) {
            [self.tracker setAllowIDFACollection:YES];
            VikeLog(@"[[[GAI sharedInstance] defaultTracker] setAllowIDFACollection:YES];");
        }
    }
    return self;
}

#pragma mark - Events

- (void)identify:(VikeIdentifyPayload *)payload
{
    [self resetTraits];
    
    if (payload.userId) {
        [self.tracker set:@"&uid" value:payload.userId];
        VikeLog(@"[[[GAI sharedInstance] defaultTracker] set:&uid value:%@];", payload.userId);
    }
    
    self.traits = payload.traits;
    
    [self.traits enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self.tracker set:key value:obj];
        VikeLog(@"[[[GAI sharedInstance] defaultTracker] set:%@ value:%@];", key, obj);
    }];
    
    [self setCustomDimensionsAndMetricsOnDefaultTracker:payload.traits];
}

- (void)track:(VikeTrackPayload *)payload
{
    NSString *category = @"All"; // default
    NSString *categoryProperty = [payload.properties objectForKey:@"category"];
    if (categoryProperty) {
        category = categoryProperty;
    }
    
    NSString *label = [payload.properties objectForKey:@"label"];
    
    NSNumber *value = [VikeGoogleAnalyticsIntegration extractRevenue:payload.properties withKey:@"revenue"];
    NSNumber *valueFallback = [VikeGoogleAnalyticsIntegration extractRevenue:payload.properties withKey:@"value"];
    if (!value && valueFallback) {
        value = valueFallback;
    }
    
    GAIDictionaryBuilder *hitBuilder =
    [GAIDictionaryBuilder createEventWithCategory:category
                                           action:payload.event
                                            label:label
                                            value:value];
    NSDictionary *hit = [self setCustomDimensionsAndMetrics:payload.properties onHit:hitBuilder];
    [self.tracker send:hit];
    VikeLog(@"[[[GAI sharedInstance] defaultTracker] send:%@];", hit);
}

- (void)screen:(VikeScreenPayload *)payload
{
    [self.tracker set:kGAIScreenName value:payload.name];
    VikeLog(@"[[[GAI sharedInstance] defaultTracker] set:%@ value:%@];", kGAIScreenName, payload.name);
    
    GAIDictionaryBuilder *hitBuilder = [GAIDictionaryBuilder createScreenView];
    NSDictionary *hit = [self setCustomDimensionsAndMetrics:payload.properties onHit:hitBuilder];
    [self.tracker send:hit];
    VikeLog(@"[[[GAI sharedInstance] defaultTracker] send:%@];", hit);
}

- (void)reset
{
    [self.tracker set:@"&uid" value:nil];
    VikeLog(@"[[[GAI sharedInstance] defaultTracker] set:&uid value:nil];");
    
    [self resetTraits];
}

- (void)flush
{
    [[GAI sharedInstance] dispatch];
}

#pragma mark - Ecommerce

- (void)completedOrder:(NSDictionary *)properties
{
    NSString *orderId = properties[@"orderId"];
    NSString *currency = properties[@"currency"] ?: @"USD";
    
    NSDictionary *transaction = [[GAIDictionaryBuilder createTransactionWithId:orderId
                                                                   affiliation:properties[@"affiliation"]
                                                                       revenue:[VikeGoogleAnalyticsIntegration extractRevenue:properties
                                                                                                                      withKey:@"revenue"]
                                                                           tax:properties[@"tax"]
                                                                      shipping:properties[@"shipping"]
                                                                  currencyCode:currency] build];
    [self.tracker send:transaction];
    VikeLog(@"[[[GAI sharedInstance] defaultTracker] send:%@];", transaction);
    
    NSDictionary *item = [[GAIDictionaryBuilder createItemWithTransactionId:orderId
                                                                       name:properties[@"name"]
                                                                        sku:properties[@"sku"]
                                                                   category:properties[@"category"]
                                                                      price:properties[@"price"]
                                                                   quantity:properties[@"quantity"]
                                                               currencyCode:currency] build];
    [self.tracker send:item];
    VikeLog(@"[[[GAI sharedInstance] defaultTracker] send:%@];", item);
}

#pragma mark - Private

- (NSDictionary *)setCustomDimensionsAndMetrics:(NSDictionary *)properties onHit:(GAIDictionaryBuilder *)hit
{
    NSDictionary *customDimensions = self.settings[@"dimensions"];
    NSDictionary *customMetrics = self.settings[@"metrics"];
    
    for (NSString *key in properties) {
        NSString *dimensionString = [customDimensions objectForKey:key];
        NSUInteger dimension = [self extractNumber:dimensionString from:[@"dimension" length]];
        if (dimension != 0) {
            [hit set:[properties objectForKey:key]
              forKey:[GAIFields customDimensionForIndex:dimension]];
        }
        
        NSString *metricString = [customMetrics objectForKey:key];
        NSUInteger metric = [self extractNumber:metricString from:[@"metric" length]];
        if (metric != 0) {
            [hit set:[properties objectForKey:key]
              forKey:[GAIFields customMetricForIndex:metric]];
        }
    }
    
    return [hit build];
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

- (void)setCustomDimensionsAndMetricsOnDefaultTracker:(NSDictionary *)traits
{
    NSDictionary *customDimensions = self.settings[@"dimensions"];
    NSDictionary *customMetrics = self.settings[@"metrics"];
    
    for (NSString *key in traits) {
        NSString *dimensionString = [customDimensions objectForKey:key];
        NSUInteger dimension = [self extractNumber:dimensionString from:[@"dimension" length]];
        if (dimension) {
            [self.tracker set:[GAIFields customDimensionForIndex:dimension]
                        value:[traits objectForKey:key]];
        }
        
        NSString *metricString = [customMetrics objectForKey:key];
        NSUInteger metric = [self extractNumber:metricString from:[@"metric" length]];
        if (metric) {
            [self.tracker set:[GAIFields customMetricForIndex:metric]
                        value:[traits objectForKey:key]];
        }
    }
}

- (int)extractNumber:(NSString *)text from:(NSUInteger)start
{
    if (text == nil || [text length] == 0) {
        return 0;
    }
    return [[text substringFromIndex:start] intValue];
}

- (void)resetTraits
{
    [self.traits enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self.tracker set:key value:nil];
        VikeLog(@"[[[GAI sharedInstance] defaultTracker] set:%@ value:nil];", key);
    }];
    self.traits = nil;
}

@end
