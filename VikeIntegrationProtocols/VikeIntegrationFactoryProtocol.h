//
//  VikeIntegrationFactory.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 03.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VikeIntegrationProtocol.h"

@class VikeAnalytics;

@protocol VikeIntegrationFactoryProtocol <NSObject>

- (id <VikeIntegrationProtocol>)createWithSettings:(NSDictionary *)settings forAnalytics:(VikeAnalytics *)analytics;

- (NSString *)key;

@end
