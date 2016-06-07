//
//  VikeKissmetricsIntegration.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 07.06.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VikeIntegrationProtocol.h"

@interface VikeKissmetricsIntegration : NSObject <VikeIntegrationProtocol>

@property (strong, nonatomic) NSDictionary *settings;

- (instancetype)initWithSettings:(NSDictionary *)settings;

@end
