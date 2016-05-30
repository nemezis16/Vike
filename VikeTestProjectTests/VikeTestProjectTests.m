//
//  VikeTestProjectTests.m
//  VikeTestProjectTests
//
//  Created by Roman Osadchuk on 23.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VikeAnalytics.h"
#import "VikeAnalyticsConfiguration.h"

#import "VikeIntegrationKinesis.h"
//#import <AWSCognito.h>

#import "VikeFlurryIntegrationFactory.h"
#import "VikeMixpanelIntegrationFactory.h"
#import "VikeGoogleAnalyticsIntegrationFactory.h"
#import "VikeCrashlyticsIntegrationFactory.h"

static NSString *const ProjectIDString = @"346f23a2740818ecc9f91";
static NSString *const FakeProjectIDString = @"346f23a2740818ecc9f92";

@interface VikeAnalytics (Test)

- (instancetype)initWithConfiguration:(VikeAnalyticsConfiguration *)configuration;

@end

@interface VikeIntegrationKinesis (Test)

//@property (strong, nonatomic) AWSCognitoCredentialsProvider *credentialsProvider;

- (instancetype)initWithWriteKey:(NSString *)writeKey;

@end

@interface VikeTestProjectTests : XCTestCase

@property (strong, nonatomic) VikeAnalytics *analytics;

@end

@implementation VikeTestProjectTests

#pragma mark - LifeCycle

- (void)setUp
{
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - VikeAnalyticsTests

- (void)testFakeProjectID
{
    [self checkRefreshedSettingsWithProjectID:FakeProjectIDString];
    XCTAssertEqual(self.analytics.bundledIntegrations.count, 1);
}

- (void)testCorrectProjectID
{
    [self checkRefreshedSettingsWithProjectID:ProjectIDString];
    XCTAssertEqual(self.analytics.bundledIntegrations.count, 5);
}

- (void)checkRefreshedSettingsWithProjectID:(NSString *)projectID
{
    VikeAnalyticsConfiguration *analyticsConfiguration = [VikeAnalyticsConfiguration configurationWithWriteKey:projectID];
    [analyticsConfiguration use:[VikeFlurryIntegrationFactory instance]];
    [analyticsConfiguration use:[VikeMixpanelIntegrationFactory instance]];
    [analyticsConfiguration use:[VikeGoogleAnalyticsIntegrationFactory instance]];
    [analyticsConfiguration use:[VikeCrashlyticsIntegrationFactory instance]];
    
    self.analytics = [[VikeAnalytics alloc] initWithConfiguration:analyticsConfiguration];
    
    NSDate *runUntil = [NSDate dateWithTimeIntervalSinceNow:10.f];
    [[NSRunLoop currentRunLoop] runUntilDate:runUntil];
}

#pragma mark - VikeIntegrationKinesis

- (void)testKinesisWithFakeProjectID
{
    [self checkKinesisWithProjectID:FakeProjectIDString completion:^(NSError *error) {
        XCTAssert(error);
    }];
}

- (void)testKinesisWithCorrectProjectID
{
    [self checkKinesisWithProjectID:ProjectIDString completion:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)checkKinesisWithProjectID:(NSString *)projectID completion:(void(^)(NSError *error))completion
{
    VikeIntegrationKinesis *kinesis = [[VikeIntegrationKinesis alloc] initWithWriteKey:projectID];
    
    NSData *data = [@"adasdas" dataUsingEncoding:kCFStringEncodingUTF8];
    
    [kinesis storeRecords:@[data] withCompletion:completion];
}

@end
