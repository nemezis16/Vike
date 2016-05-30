//
//  VikeIntegrationOs.h
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VikeIntegrationOs : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *version;

- (instancetype)init;

- (NSDictionary *)jsonDictionary;

@end
