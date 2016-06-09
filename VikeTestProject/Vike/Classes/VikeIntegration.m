//
//  VikeUnitIntegration.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 04.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSCore/AWSGZIP.h>

#import "VikeIntegration.h"
#import "VikeIntegrationEvent.h"
#import "VikeIntegrationKinesis.h"

#import "VikeAnalytics.h"

#import "VikeIdentifyPayload.h"
#import "VikeTrackPayload.h"
#import "VikeScreenPayload.h"

#import "VikeConstants.h"
#import "VikeUtils.h"
#import "VikeUncaughtExceptionHandler.h"

NSString *const VikeAnonymousIdKey = @"VikeAnonymousId";
NSString *const VikeUserIdKey = @"VikeUserId";
NSString *const VikeQueueKey = @"VikeQueue";

@interface VikeIntegration ()

@property (strong, nonatomic) VikeAnalytics *analytics;
@property (strong, nonatomic) VikeUncaughtExceptionHandler *exceptionHandler;

@property (strong, nonatomic) NSURL *anonymousIDURL;
@property (strong, nonatomic) NSURL *userIDURL;

@property (strong, nonatomic) NSMutableArray *eventQueue;

@property (strong, nonatomic) NSString *anonymousId;
@property (strong, nonatomic) NSString *userId;

@property (strong, nonatomic) NSTimer *flushTimer;

@property (strong, nonatomic) dispatch_queue_t serialQueue;
@property (assign, nonatomic) UIBackgroundTaskIdentifier flushTaskID;

@end

@implementation VikeIntegration

#pragma mark - Initializers

- (instancetype)initWithAnalytics:(VikeAnalytics *)analytics
{
    self = [super init];
    if (self) {
        _analytics = analytics;
        _anonymousId = [self getAnonymousId:NO];
        _userId = [self getUserId];
        _serialQueue = dispatch_queue_create("io.Vike.Integration", DISPATCH_QUEUE_SERIAL);
        
        [self setupTimer];
        [VikeIntegrationKinesis setupWithWriteKey:analytics.configuration.writeKey];
        [self configureExceptionHandler];
    }
    return self;
}

#pragma mark - VikeIntegrationProtocol

- (void)identify:(VikeIdentifyPayload *)payload
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.serialQueue, ^{
        VikeIntegrationEvent *event = [weakSelf eventWithPayload:payload];
        
        [weakSelf saveUserId:payload.userId];
        if (payload.anonymousId) {
            [weakSelf saveAnonymousId:payload.anonymousId];
        }
        
        [weakSelf.eventQueue addObject:event.jsonDictionary];
        [weakSelf persistQueue];
    });
}

- (void)track:(VikeTrackPayload *)payload
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.serialQueue, ^{
        VikeIntegrationEvent *event = [weakSelf eventWithPayload:payload];
        event.properties = payload.properties;
        
        NSMutableDictionary *jsonDictionary = [event.jsonDictionary mutableCopy];
        [jsonDictionary addEntriesFromDictionary:@{@"event":payload.event}];
        
        [weakSelf.eventQueue addObject:jsonDictionary];
        [weakSelf persistQueue];
    });
}

- (void)screen:(VikeScreenPayload *)payload
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.serialQueue, ^{
        VikeIntegrationEvent *event = [weakSelf eventWithPayload:payload];
        event.properties = payload.properties;
        
        NSMutableDictionary *jsonDictionary = [event.jsonDictionary mutableCopy];
        [jsonDictionary addEntriesFromDictionary:@{@"name":payload.name}];
        
        [weakSelf.eventQueue addObject:jsonDictionary];
        [weakSelf persistQueue];
    });
}

- (VikeIntegrationEvent *)eventWithPayload:(VikePayload *)payload
{
    VikeIntegrationEvent *event = [VikeIntegrationEvent new];
    event.type = payload.eventTypeString;
    event.bundledIntegrations = payload.integrations ?: [self integrationsDictionary:self.analytics.bundledIntegrations];
    event.messageId = GenerateUUIDString();
    event.projectId = self.analytics.configuration.writeKey;
    
    if ([payload isMemberOfClass:[VikeIdentifyPayload class]]) {
        event.userId = ((VikeIdentifyPayload *)payload).userId;
        event.anonymousId = ((VikeIdentifyPayload *)payload).anonymousId ?: self.anonymousId;
    } else {
        event.anonymousId = self.anonymousId;
        event.userId = self.userId;
    }
    
    return event;
}

- (void)configureExceptionHandler
{
    self.exceptionHandler = [VikeUncaughtExceptionHandler new];
    
    __weak typeof(self) weakSelf = self;
    self.exceptionHandler.exceptionCallback = ^(NSDictionary *exceptionDictionary, BOOL *complete) {
        VikeIntegrationEvent *event = [VikeIntegrationEvent new];
        event.type = @"exception";
        event.projectId = weakSelf.analytics.configuration.writeKey;
        event.anonymousId = weakSelf.anonymousId;
        event.userId = weakSelf.userId;
        event.bundledIntegrations = [weakSelf integrationsDictionary:weakSelf.analytics.bundledIntegrations];
    
        dispatch_async(weakSelf.serialQueue, ^{
            NSMutableDictionary *jsonDictionary = [event.jsonDictionary mutableCopy];
            [jsonDictionary addEntriesFromDictionary:exceptionDictionary];
            
            [weakSelf.eventQueue addObject:jsonDictionary];
            [weakSelf persistQueue];
            [weakSelf flushWithCompletion:^{
                *complete = YES;
            }];
        });
    };
}

#pragma mark - Queueing

- (NSDictionary *)integrationsDictionary:(NSDictionary *)integrations
{
    NSMutableDictionary *dict = [integrations ?: @{} mutableCopy];
    for (NSString *integration in self.analytics.bundledIntegrations) {
        dict[integration] = @YES;
    }
    return [dict copy];
}

#pragma mark - Private

- (void)saveUserId:(NSString *)userId
{
    dispatch_async(self.serialQueue, ^{
        self.userId = userId;
        [[NSUserDefaults standardUserDefaults] setValue:userId forKey:VikeUserIdKey];
        [self.userId writeToURL:self.userIDURL atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    });
}

- (void)saveAnonymousId:(NSString *)anonymousId
{
    dispatch_async(self.serialQueue, ^{
        self.anonymousId = anonymousId;
        [[NSUserDefaults standardUserDefaults] setValue:anonymousId forKey:VikeAnonymousIdKey];
        [self.anonymousId writeToURL:self.anonymousIDURL atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    });
}

- (NSString *)getUserId
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:VikeUserIdKey] ?: [[NSString alloc] initWithContentsOfURL:self.userIDURL encoding:NSUTF8StringEncoding error:NULL];
}

- (NSString *)getAnonymousId:(BOOL)reset
{
    NSURL *url = self.anonymousIDURL;
    NSString *anonymousId = [[NSUserDefaults standardUserDefaults] valueForKey:VikeAnonymousIdKey] ?: [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
    if (!anonymousId || reset) {
        anonymousId = GenerateUUIDString();
        VikeLog(@"New anonymousId: %@", anonymousId);
        [[NSUserDefaults standardUserDefaults] setObject:anonymousId forKey:VikeAnonymousIdKey];
        [anonymousId writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }
    return anonymousId;
}

- (void)setupTimer
{
    __weak typeof(self) weakSelf = self;
    dispatch_sync(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.flushTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(flush) userInfo:nil repeats:YES];
#warning Need to setup time 30.0
    });
}

- (void)flush
{
    [self flushWithCompletion:nil];
}

- (void)flushWithCompletion:(void(^)())completion
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.serialQueue, ^{
        if (!weakSelf.eventQueue.count) {
            return;
        }
        NSDictionary *eventsDictionary = @{@"events" : weakSelf.eventQueue};
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:eventsDictionary options:0 error:&error];
        NSData *gzipData = [jsonData awsgzip_gzippedData];
        
        NSMutableArray *temporaryEventQueue = [self.eventQueue mutableCopy];
        [[VikeIntegrationKinesis sharedIntegrationKinesis] storeRecords:@[gzipData] withCompletion:^(NSError *error){
            if (completion) {
                completion();
            }
            if (!error) {
                NSMutableArray *distinctionArray = [self.eventQueue mutableCopy];
                [distinctionArray removeObjectsInArray:temporaryEventQueue];
                [weakSelf clearQueue];
                self.eventQueue = [distinctionArray mutableCopy];
            }
        }];
    });
}

- (void)persistQueue
{
    [[NSUserDefaults standardUserDefaults] setValue:[self.eventQueue copy] forKey:VikeQueueKey];
    [[self.eventQueue copy] writeToURL:self.queueURL atomically:YES];
}

- (void)clearQueue
{
    [[NSUserDefaults standardUserDefaults] setValue:@[] forKey:VikeQueueKey];
    [[NSFileManager defaultManager] removeItemAtURL:self.queueURL error:NULL];
    self.eventQueue = [NSMutableArray array];
}

#pragma mark - Accessors

- (NSMutableArray *)eventQueue
{
    if (!_eventQueue) {
        _eventQueue = ([[[NSUserDefaults standardUserDefaults] objectForKey:VikeQueueKey] mutableCopy] ?: [NSMutableArray arrayWithContentsOfURL:self.queueURL]) ?: [[NSMutableArray alloc] init];
    }
    return _eventQueue;
}

- (NSURL *)anonymousIDURL
{
    return VikeAnalyticsURLForFilename(@"vike.anonymousId");
}

- (NSURL *)userIDURL
{
    return VikeAnalyticsURLForFilename(@"vike.userId");
}

- (NSURL *)queueURL
{
    return VikeAnalyticsURLForFilename(@"vike.queue.plist");
}

- (void)applicationDidEnterBackground
{
    [self beginBackgroundTask];
    [self flush];
}

- (void)applicationWillTerminate
{
    dispatch_sync(self.serialQueue, ^{
        if (self.eventQueue.count) {
            [self persistQueue];
        }
    });
}

- (void)beginBackgroundTask
{
    [self endBackgroundTask];
    
    self.flushTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask];
    }];
}

- (void)endBackgroundTask
{
    __weak typeof(self) weakSelf = self;
    dispatch_sync(self.serialQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.flushTaskID != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:strongSelf.flushTaskID];
            strongSelf.flushTaskID = UIBackgroundTaskInvalid;
        }
    });
}

@end