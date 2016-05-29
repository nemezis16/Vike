//
//  VikeTrackPayload.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 03.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeTrackPayload.h"

@interface VikeTrackPayload ()

@property (strong, nonatomic, readwrite) NSString *eventTypeString;

@end

@implementation VikeTrackPayload

@synthesize eventTypeString = _eventTypeString;

- (instancetype)initWithEvent:(NSString *)event
                   properties:(NSDictionary *)properties
                      context:(NSDictionary *)context
                 integrations:(NSDictionary *)integrations
{
    if (self = [super initWithContext:context integrations:integrations]) {
        _event = [event copy];
        _properties = [properties copy];
        _eventTypeString = @"track";
    }
    return self;
}

@end
