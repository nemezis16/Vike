//
//  VikeAnalyticsConfiguration.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 03.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VikeIntegrationFactoryProtocol.h"

@interface VikeAnalyticsConfiguration : NSObject 

@property (strong, nonatomic, readonly) NSString *writeKey;
@property (strong, nonatomic, readonly) NSMutableArray *factories;

+ (instancetype)configurationWithWriteKey:(NSString *)writeKey;
- (void)use:(id <VikeIntegrationFactoryProtocol>)factory;

@end
