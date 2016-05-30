//
//  VikeMixpanelIntegration.h
//  VikeTestProject
//
//  Created by user on 05.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VikeIntegrationProtocol.h"

@interface VikeMixpanelIntegration : NSObject <VikeIntegrationProtocol>

@property (nonatomic, strong) NSDictionary *settings;

- (instancetype)initWithSettings:(NSDictionary *)settings;

@end
