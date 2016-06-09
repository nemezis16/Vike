//
//  VIKEAnalytics.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 29.04.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "VikeAnalytics.h"
#import "VikeIntegrationFactory.h"

#import "VikeIdentifyPayload.h"
#import "VikeTrackPayload.h"
#import "VikeScreenPayload.h"
#import "VikeRequest.h"

#import "VikeUtils.h"
#import "VikeConstants.h"

@interface VikeAnalytics ()

@property (strong, nonatomic) VikeAnalyticsConfiguration *configuration;

@property (strong, nonatomic) NSMutableArray *messageQueue;

@property (strong, nonatomic) NSMutableDictionary *registeredIntegrations;
@property (strong, nonatomic) NSMutableDictionary *integrations;
@property (strong, nonatomic) NSDictionary *cachedSettings;

@property (strong, nonatomic) NSURL *settingsURL;

@property (strong, nonatomic) dispatch_queue_t serialQueue;

@property (assign, nonatomic) BOOL initialized;

@end

static VikeAnalytics *__sharedInstance = nil;

@implementation VikeAnalytics

@synthesize cachedSettings = _cachedSettings;

#pragma mark - InitializerMethods

- (instancetype)initWithConfiguration:(VikeAnalyticsConfiguration *)configuration
{
    self = [super init];
    if (self) {
        _configuration = configuration;
        _serialQueue = dispatch_queue_create("io.Vike.Analitics", DISPATCH_QUEUE_SERIAL);
        _integrations = [NSMutableDictionary dictionaryWithCapacity:configuration.factories.count];
        _messageQueue = [[NSMutableArray alloc] init];
        _registeredIntegrations = [NSMutableDictionary dictionaryWithCapacity:configuration.factories.count];
        
        [self refreshSettings];
        [self addNotifications];
    }
    return self;
}

#pragma mark - Accessors

- (NSDictionary *)cachedSettings
{
    if (!_cachedSettings)
        _cachedSettings = [[NSDictionary alloc] initWithContentsOfURL:self.settingsURL] ? : @{};
    return _cachedSettings;
}

- (void)setCachedSettings:(NSDictionary *)settings
{
    _cachedSettings = [settings copy];
    if (!_cachedSettings) {
        return;
    }
    [_cachedSettings writeToURL:self.settingsURL atomically:YES];
    
    [self updateIntegrationsWithSettings:settings[VikePayloadKeyIntegrations]];
}

- (NSURL *)settingsURL
{
    if (!_settingsURL) {
        _settingsURL = VikeAnalyticsURLForFilename(@"analytics.settings.v2.plist");
    }
    
    return _settingsURL;
}

#pragma mark - Public

+ (void)setupWithConfiguration:(VikeAnalyticsConfiguration *)configuration
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[VikeAnalytics alloc] initWithConfiguration:configuration];
    });
}

+ (instancetype)sharedAnalytics
{
    return __sharedInstance;
}

- (NSDictionary *)bundledIntegrations
{
    return [self.registeredIntegrations copy];
}

#pragma mark - Analytics API

#pragma mark - Identify

- (void)identify:(NSString *)userId
{
    [self identify:userId traits:nil options:nil];
}

- (void)identify:(NSString *)userId traits:(NSDictionary *)traits
{
    [self identify:userId traits:traits options:nil];
}

- (void)identify:(NSString *)userId traits:(NSDictionary *)traits options:(NSDictionary *)options
{
    VikeIdentifyPayload *identifyPayload = [[VikeIdentifyPayload alloc] initWithUserId:userId
                                                                           anonymousId:options[VikePayloadKeyAnonymousID]
                                                                                traits:traits
                                                                               context:options[VikePayloadKeyContext]
                                                                          integrations:options[VikePayloadKeyIntegrations]];
    
    [self callIntegrationsWithSelector:@selector(identify:)
                             arguments:@[identifyPayload]
                               options:options];
}

#pragma mark - Track

- (void)track:(NSString *)event
{
    [self track:event properties:nil options:nil];
}

- (void)track:(NSString *)event properties:(NSDictionary *)properties
{
    [self track:event properties:properties options:nil];
}

- (void)track:(NSString *)event properties:(NSDictionary *)properties options:(NSDictionary *)options
{
    VikeTrackPayload *payload = [[VikeTrackPayload alloc] initWithEvent:event
                                                            properties:VikeCoerceDictionary(properties)
                                                               context:VikeCoerceDictionary(options[VikePayloadKeyContext])
                                                          integrations:options[VikePayloadKeyIntegrations]];
    
    [self callIntegrationsWithSelector:@selector(track:)
                             arguments:@[payload]
                               options:options];
}

#pragma mark - Screen

- (void)screen:(NSString *)screenTitle
{
    [self screen:screenTitle properties:nil options:nil];
}

- (void)screen:(NSString *)screenTitle properties:(NSDictionary *)properties
{
    [self screen:screenTitle properties:properties options:nil];
}

- (void)screen:(NSString *)screenTitle properties:(NSDictionary *)properties options:(NSDictionary *)options
{
    VikeScreenPayload *payload = [[VikeScreenPayload alloc] initWithName:screenTitle
                                                              properties:VikeCoerceDictionary(properties)
                                                                 context:VikeCoerceDictionary(options[VikePayloadKeyContext])
                                                            integrations:options[VikePayloadKeyIntegrations]];
    
    [self callIntegrationsWithSelector:@selector(screen:)
                             arguments:@[payload]
                               options:options];
}


#pragma mark - Private

#pragma mark - NotificationMethods

- (void)addNotifications
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(onAppForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    NSArray *statesNotifications = @[ UIApplicationDidEnterBackgroundNotification,
                                      UIApplicationDidFinishLaunchingNotification,
                                      UIApplicationWillEnterForegroundNotification,
                                      UIApplicationWillTerminateNotification,
                                      UIApplicationWillResignActiveNotification,
                                      UIApplicationDidBecomeActiveNotification ];
    for (NSString *name in statesNotifications) {
        [notificationCenter addObserver:self selector:@selector(handleAppStateNotification:) name:name object:nil];
    }
}

- (void)handleAppStateNotification:(NSNotification *)note
{
    static NSDictionary *selectorMapping;
    static dispatch_once_t selectorMappingOnce;
    dispatch_once(&selectorMappingOnce, ^{
        selectorMapping = @{
                            UIApplicationDidFinishLaunchingNotification :
                                NSStringFromSelector(@selector(applicationDidFinishLaunching:)),
                            UIApplicationDidEnterBackgroundNotification :
                                NSStringFromSelector(@selector(applicationDidEnterBackground)),
                            UIApplicationWillEnterForegroundNotification :
                                NSStringFromSelector(@selector(applicationWillEnterForeground)),
                            UIApplicationWillTerminateNotification :
                                NSStringFromSelector(@selector(applicationWillTerminate)),
                            UIApplicationWillResignActiveNotification :
                                NSStringFromSelector(@selector(applicationWillResignActive)),
                            UIApplicationDidBecomeActiveNotification :
                                NSStringFromSelector(@selector(applicationDidBecomeActive))
                            };
    });
    SEL selector = NSSelectorFromString(selectorMapping[note.name]);
    if (selector) {
        [self callIntegrationsWithSelector:selector arguments:nil options:nil];
    }
}

#pragma mark - NSNotificationCenter Callback

- (void)onAppForeground:(NSNotification *)note
{
    [self refreshSettings];
}

#pragma mark - Analytics Settings

- (void)updateIntegrationsWithSettings:(NSDictionary *)projectSettings
{
    for (id<VikeIntegrationFactoryProtocol> factory in self.configuration.factories) {
        NSString *key = [factory key];
        NSDictionary *integrationSettings = [projectSettings objectForKey:key];
        if (integrationSettings || [key isEqualToString:@"vike"]) {
            id<VikeIntegrationProtocol> integration = [factory createWithSettings:integrationSettings forAnalytics:self];
            if (integration) {
                self.integrations[key] = integration;
                self.registeredIntegrations[key] = @YES;
            }
        } else {
            VikeLog(@"No settings for %@. Skipping.", key);
        }
    }
    
    dispatch_async(self.serialQueue, ^{
        [self flushMessageQueue];
        self.initialized = YES;
    });
}

- (void)refreshSettings
{
    NSString *compoundedURLString = [NSString stringWithFormat:@"%@?%@%@",IntegrationsURLString, ProjectIDPrefixString, self.configuration.writeKey];
    NSURL *url = [NSURL URLWithString:compoundedURLString];
    NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:url];
    URLRequest.HTTPMethod = @"GET";
    
    __weak typeof(self) weakSelf = self;
    VikeRequest *vikeRequest = [[VikeRequest alloc] init];
    [vikeRequest startWithURLRequest:URLRequest completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if ([error.domain isEqualToString:NSURLErrorDomain]) {
                switch (error.code) {
                    case NSURLErrorNotConnectedToInternet: {
                        static dispatch_once_t once;
                        dispatch_once(&once, ^{
                            [self updateIntegrationsWithSettings:@{}];
                        });
                        break;
                    }
                    default: {
                        break;
                    }
                }
            }
            VikeLog(@"Error: %@",error.localizedDescription);
        } else {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            [weakSelf setCachedSettings:jsonDict];
        }
    }];
}

#pragma mark - Invoketion

- (void)callIntegrationsWithSelector:(SEL)selector arguments:(NSArray *)arguments options:(NSDictionary *)options
{
    dispatch_async(self.serialQueue, ^{
        if (self.initialized) {
            [self flushMessageQueue];
            [self forwardSelector:selector arguments:arguments options:options];
        } else {
            [self queueSelector:selector arguments:arguments options:options];
        }
    });
}

- (void)forwardSelector:(SEL)selector arguments:(NSArray *)arguments options:(NSDictionary *)options
{
    [self.integrations enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<VikeIntegrationProtocol> integration, BOOL *stop) {
        [self invokeIntegration:integration key:key selector:selector arguments:arguments options:options];
    }];
}

- (void)invokeIntegration:(id<VikeIntegrationProtocol>)integration key:(NSString *)key selector:(SEL)selector arguments:(NSArray *)arguments options:(NSDictionary *)options
{
    if (![integration respondsToSelector:selector]) {
        return;
    }
    
    NSInvocation *invocation = [self invocationForSelector:selector arguments:arguments];
    [invocation invokeWithTarget:integration];
}

- (NSInvocation *)invocationForSelector:(SEL)selector arguments:(NSArray *)arguments
{
    struct objc_method_description methodDescription = protocol_getMethodDescription(@protocol(VikeIntegrationProtocol), selector, NO, YES);
    
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:methodDescription.types];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;
    for (int i = 0; i < arguments.count; i++) {
        id argument = (arguments[i] == [NSNull null]) ? nil : arguments[i];
        [invocation setArgument:&argument atIndex:i + 2];
    }
    return invocation;
}

- (void)flushMessageQueue
{
    if (self.messageQueue.count) {
        for (NSArray *array in self.messageQueue)
            [self forwardSelector:NSSelectorFromString(array[0]) arguments:array[1] options:array[2]];
        [self.messageQueue removeAllObjects];
    }
}

- (void)queueSelector:(SEL)selector arguments:(NSArray *)arguments options:(NSDictionary *)options
{
    NSArray *obj = @[ NSStringFromSelector(selector), arguments ?: @[], options ?: @{} ];
    [self.messageQueue addObject:obj];
}

@end
