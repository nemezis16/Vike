//
//  VikeIntegrationEvent.h
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VikeIntegrationApp.h"
#import "VikeIntegrationDevice.h"
#import "VikeIntegrationOs.h"

@interface VikeIntegrationEvent : NSObject

@property (strong, nonatomic) NSString *projectId;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *anonymousId;
@property (strong, nonatomic) NSString *timestamp;
@property (strong, nonatomic) NSString *ip;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *channel;
@property (strong, nonatomic) NSString *messageId;
@property (strong, nonatomic) NSDictionary *properties;
@property (strong, nonatomic) NSDictionary *bundledIntegrations;
@property (strong, nonatomic) VikeIntegrationApp *app;
@property (strong, nonatomic) VikeIntegrationDevice *device;
@property (strong, nonatomic) VikeIntegrationOs *os;

- (instancetype)init;

- (NSDictionary *)jsonDictionary;
- (NSData *)gzipData;

@end
