//
//  VikeUnitIntegration.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 04.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VikeIntegrationProtocol.h"

@class VikeAnalytics;

@interface VikeIntegration : NSObject <VikeIntegrationProtocol>

- (instancetype)initWithAnalytics:(VikeAnalytics *)analytics;

@end
