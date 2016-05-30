//
//  VikeCrashlyticsFactory.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 20.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VikeIntegrationFactoryProtocol.h"

@interface VikeCrashlyticsIntegrationFactory : NSObject <VikeIntegrationFactoryProtocol>

+ (instancetype)instance;

@end
