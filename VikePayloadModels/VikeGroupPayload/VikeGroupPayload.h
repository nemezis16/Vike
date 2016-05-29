//
//  VikeGroupPayload.h
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikePayload.h"

@interface VikeGroupPayload : VikePayload

@property (strong, nonatomic, readonly) NSString *groupId;

@property (strong, nonatomic, readonly) NSDictionary *traits;

- (instancetype)initWithGroupId:(NSString *)groupId
                         traits:(NSDictionary *)traits
                        context:(NSDictionary *)context
                   integrations:(NSDictionary *)integrations;

@end
