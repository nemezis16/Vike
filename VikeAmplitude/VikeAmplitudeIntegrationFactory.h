//
//  VikeAmplitudeIntegrationFactory.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 07.06.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VikeIntegrationFactoryProtocol.h"

@interface VikeAmplitudeIntegrationFactory : NSObject <VikeIntegrationFactoryProtocol>

+ (instancetype)instance;

@end
