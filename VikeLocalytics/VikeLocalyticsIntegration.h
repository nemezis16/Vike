//
//  VikeLocalyticsIntegration.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 06.06.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VikeIntegrationProtocol.h"

@interface VikeLocalyticsIntegration : NSObject <VikeIntegrationProtocol>

@property (nonatomic, strong) NSDictionary *settings;

- (instancetype)initWithSettings:(NSDictionary *)settings;

@end
