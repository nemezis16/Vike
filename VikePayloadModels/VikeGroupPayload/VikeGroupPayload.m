//
//  VikeGroupPayload.m
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeGroupPayload.h"

@interface VikeGroupPayload ()

@property (strong, nonatomic, readwrite) NSString *eventTypeString;

@end

@implementation VikeGroupPayload

@synthesize eventTypeString = _eventTypeString;

- (instancetype)initWithGroupId:(NSString *)groupId
                         traits:(NSDictionary *)traits
                        context:(NSDictionary *)context
                   integrations:(NSDictionary *)integrations
{
    if (self = [super initWithContext:context integrations:integrations]) {
        _groupId = [groupId copy];
        _traits = [traits copy];
        _eventTypeString = @"group";
    }
    return self;
}

@end
