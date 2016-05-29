//
//  VikeScreenPayload.h
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikePayload.h"

@interface VikeScreenPayload : VikePayload

@property (nonatomic, readonly) NSString *name;

@property (nonatomic, readonly) NSString *category;

@property (nonatomic, readonly) NSDictionary *properties;

- (instancetype)initWithName:(NSString *)name
                  properties:(NSDictionary *)properties
                     context:(NSDictionary *)context
                integrations:(NSDictionary *)integrations;

@end
