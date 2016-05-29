//
//  VikeIdentifyPayload.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 03.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikePayload.h"

@interface VikeIdentifyPayload : VikePayload

@property (strong, nonatomic, readonly) NSString *userId;

@property (strong, nonatomic, readonly) NSString *anonymousId;

@property (strong, nonatomic, readonly) NSDictionary *traits;

- (instancetype)initWithUserId:(NSString *)userId
                   anonymousId:(NSString *)anonymousId
                        traits:(NSDictionary *)traits
                       context:(NSDictionary *)context
                  integrations:(NSDictionary *)integrations;

@end
