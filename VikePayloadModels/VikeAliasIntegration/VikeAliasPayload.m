//
//  VikeAliasPayload.m
//  VikeTestProject
//
//  Created by user on 05.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeAliasPayload.h"

@implementation VikeAliasPayload

- (instancetype)initWithNewId:(NSString *)newId
                      context:(NSDictionary *)context
                 integrations:(NSDictionary *)integrations
{
    if (self = [super initWithContext:context integrations:integrations]) {
        _theNewId = [newId copy];
    }
    return self;
}

@end
