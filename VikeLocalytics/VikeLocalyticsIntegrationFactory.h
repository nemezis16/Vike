//
//  VikeLocalyticsIntegrationFactory.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 06.06.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VikeIntegrationFactoryProtocol.h"

@interface VikeLocalyticsIntegrationFactory : NSObject <VikeIntegrationFactoryProtocol>

+ (instancetype)instance;

@end
