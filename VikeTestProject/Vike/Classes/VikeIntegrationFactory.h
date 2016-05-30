//
//  VikeUnitIntegrationFactory.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 04.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VikeIntegrationFactoryProtocol.h"

@interface VikeIntegrationFactory : NSObject <VikeIntegrationFactoryProtocol>

+ (instancetype)instance;

@end
