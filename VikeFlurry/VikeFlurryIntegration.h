//
//  VikeFlurryIntegration.h
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VikeIntegrationProtocol.h"

@interface VikeFlurryIntegration : NSObject <VikeIntegrationProtocol>

@property (nonatomic, strong) NSDictionary *settings;

- (instancetype)initWithSettings:(NSDictionary *)settings;

@end
