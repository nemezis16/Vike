//
//  VikeIdentifyPayload.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 03.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeIdentifyPayload.h"

@interface VikeIdentifyPayload ()

@property (strong, nonatomic, readwrite) NSString *eventTypeString;

@end

@implementation VikeIdentifyPayload

@synthesize eventTypeString = _eventTypeString;

- (instancetype)initWithUserId:(NSString *)userId
                   anonymousId:(NSString *)anonymousId
                        traits:(NSDictionary *)traits
                       context:(NSDictionary *)context
                  integrations:(NSDictionary *)integrations
{
    if (self = [super initWithContext:context integrations:integrations]) {
        _userId = [userId copy];
        _anonymousId = [anonymousId copy];
        _traits = [traits copy];
        _eventTypeString = @"identify";
    }
    return self;
}

@end
