//
//  VikeIntegrationApp.h
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VikeIntegrationApp : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *build;

- (instancetype)init;

- (NSDictionary *)jsonDictionary;

@end
