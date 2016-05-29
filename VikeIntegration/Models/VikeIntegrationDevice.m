//
//  VikeIntegrationDevice.m
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeIntegrationDevice.h"
#import "VikeUtils.h"

@implementation VikeIntegrationDevice

#pragma mark - Initializers

- (instancetype)init
{
    self = [super init];
    if (self) {
        _deviceId = @"TBD";
        _manufacturer = @"Apple";
        _model = GetDeviceModel();
    }
    return self;
}

#pragma mark - Public

- (NSDictionary *)jsonDictionary
{
    return @{
             @"id"           : STR_OR_WS(self.deviceId),
             @"manufacturer" : STR_OR_WS(self.manufacturer),
             @"model"        : STR_OR_WS(self.model)
             };
}

@end
