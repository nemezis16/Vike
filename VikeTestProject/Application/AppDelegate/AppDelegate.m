//
//  AppDelegate.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 29.04.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "AppDelegate.h"

#import <AWSCognito.h>
#import <AWSKinesis/AWSKinesis.h>

#import "VikeAnalytics.h"
#import "VikeAnalyticsConfiguration.h"
//#import "VikeFlurryIntegrationFactory.h"
//#import "VikeMixpanelIntegrationFactory.h"
//#import "VikeGoogleAnalyticsIntegrationFactory.h"
//#import "VikeCrashlyticsIntegrationFactory.h"

static NSString *const ProjectIDString = @"346f23a2740818ecc9f91";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    VikeAnalyticsConfiguration *configuration = [VikeAnalyticsConfiguration configurationWithWriteKey:ProjectIDString];
    
//    [configuration use:[VikeFlurryIntegrationFactory instance]];
//    [configuration use:[VikeMixpanelIntegrationFactory instance]];
//    [configuration use:[VikeGoogleAnalyticsIntegrationFactory instance]];
//    [configuration use:[VikeCrashlyticsIntegrationFactory instance]];
    
    [VikeAnalytics setupWithConfiguration:configuration];

    return YES;
}

@end
