//
//  VikeTrackPayload.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 03.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikePayload.h"

@interface VikeTrackPayload : VikePayload

@property (strong, nonatomic, readonly) NSString *event;

@property (strong, nonatomic, readonly) NSDictionary *properties;

- (instancetype)initWithEvent:(NSString *)event
                   properties:(NSDictionary *)properties
                      context:(NSDictionary *)context
                 integrations:(NSDictionary *)integrations;

@end
