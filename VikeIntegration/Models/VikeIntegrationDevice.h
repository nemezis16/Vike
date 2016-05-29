//
//  VikeIntegrationDevice.h
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VikeIntegrationDevice : NSObject

@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) NSString *manufacturer;
@property (strong, nonatomic) NSString *model;

- (instancetype)init;

- (NSDictionary *)jsonDictionary;

@end
