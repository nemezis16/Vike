//
//  VikeGoogleAnalyticsIntegration.h
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleAnalytics/GAI.h>
#import "VikeIntegrationProtocol.h"

@interface VikeGoogleAnalyticsIntegration : NSObject <VikeIntegrationProtocol>

@property (nonatomic, copy) NSDictionary *settings;
@property (nonatomic, copy) NSDictionary *traits;
@property (nonatomic, assign) id<GAITracker> tracker;

- (id)initWithSettings:(NSDictionary *)settings;

@end
