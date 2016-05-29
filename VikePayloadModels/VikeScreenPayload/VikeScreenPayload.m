//
//  VikeScreenPayload.m
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeScreenPayload.h"

@interface VikeScreenPayload ()

@property (strong, nonatomic, readwrite) NSString *eventTypeString;

@end

@implementation VikeScreenPayload

@synthesize eventTypeString = _eventTypeString;

- (instancetype)initWithName:(NSString *)name
                  properties:(NSDictionary *)properties
                     context:(NSDictionary *)context
                integrations:(NSDictionary *)integrations
{
    if (self = [super initWithContext:context integrations:integrations]) {
        _name = [name copy];
        _properties = [properties copy];
        _eventTypeString = @"screen";
    }
    return self;
}

@end
