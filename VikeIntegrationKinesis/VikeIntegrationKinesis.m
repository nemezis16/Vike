//
//  VikeIntegrationKinesis.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 10.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeIntegrationKinesis.h"

#import "VikeUtils.h"

#import <AWSCognito.h>
#import <AWSKinesis/AWSKinesis.h>

#import "VikeConstants.h"

static VikeIntegrationKinesis * __sharedInstance;

@interface VikeIntegrationKinesis ()

@property (strong, nonatomic) AWSCognitoCredentialsProvider *credentialsProvider;

@property (strong, nonatomic) NSString *writeKey;

@end

@implementation VikeIntegrationKinesis

#pragma mark - Initializers

- (instancetype)initWithWriteKey:(NSString *)writeKey
{
    if (self = [super init]) {
        self.credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId: IdentityPoolID];
        
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:self.credentialsProvider];
        
        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
        
        self.writeKey = writeKey;
    }
    return self;
}

+ (instancetype)setupWithWriteKey:(NSString *)writeKey
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[VikeIntegrationKinesis alloc] initWithWriteKey:writeKey];
    });
    return  __sharedInstance;
}

+ (instancetype)sharedIntegrationKinesis
{
    NSCParameterAssert(__sharedInstance);
    return  __sharedInstance;
}

#pragma mark - Public

- (void)storeRecords:(NSArray <NSData *> *)records withCompletion:(void(^)(NSError *error))completion
{
    if (!self.credentialsProvider.identityId) {
        __weak typeof(self) weakSelf = self;
        [self getIdentityIDWithCompletion:^{
            [weakSelf storeRecords:records withCompletion:completion];
        }];
        return;
    }

    AWSKinesis *kinesis = [AWSKinesis defaultKinesis];
    
    for (NSData *record in records) {
        AWSKinesisPutRecordInput *putRecordInput = [AWSKinesisPutRecordInput new];
        putRecordInput.data = record;
        putRecordInput.partitionKey = self.writeKey;
        putRecordInput.streamName = StreamNameString;
        
        [kinesis putRecord:putRecordInput completionHandler:^(AWSKinesisPutRecordOutput * _Nullable response, NSError * _Nullable error) {
            if (error) {
                VikeLog(@"Error: %@",error.localizedDescription);
            }
            if (completion) {
                completion(error);
            }
        }];
    }
    
    AWSKinesisRecorder *kinesisRecorder = [AWSKinesisRecorder defaultKinesisRecorder];
    
    NSMutableArray *tasks = [NSMutableArray new];
    for (NSData *record in records) {
        [tasks addObject:[kinesisRecorder saveRecord:record streamName:StreamNameString]];
    }
}

#pragma mark - Private

- (void)getIdentityIDWithCompletion:(void(^)())completion
{
    [[self.credentialsProvider getIdentityId] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            VikeLog(@"Error: %@", task.error.localizedDescription);
        }
        else {
            completion();
        }
        return nil;
    }];
}

@end
