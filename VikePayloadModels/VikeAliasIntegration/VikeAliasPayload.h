//
//  VikeAliasPayload.h
//  VikeTestProject
//
//  Created by user on 05.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikePayload.h"

@interface VikeAliasPayload : VikePayload

@property (nonatomic, readonly) NSString *theNewId;

- (instancetype)initWithNewId:(NSString *)newId
                      context:(NSDictionary *)context
                 integrations:(NSDictionary *)integrations;

@end
