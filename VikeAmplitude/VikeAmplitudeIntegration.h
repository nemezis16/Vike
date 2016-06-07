//
//  VikeAmplitudeIntegration.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 07.06.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Amplitude-iOS/Amplitude.h>

#import "VikeIntegrationProtocol.h"

@interface VikeAmplitudeIntegration : NSObject <VikeIntegrationProtocol>

@property (strong, nonatomic) NSDictionary *settings;
@property (strong, nonatomic) Amplitude *amplitude;

- (instancetype)initWithSettings:(NSDictionary *)settings;

@end
