//
//  VikeMixpanelIntegrationFactory.h
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VikeIntegrationFactoryProtocol.h"

@interface VikeMixpanelIntegrationFactory : NSObject <VikeIntegrationFactoryProtocol>

+ (instancetype)instance;

@end
