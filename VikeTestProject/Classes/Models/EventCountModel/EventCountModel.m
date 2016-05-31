//
//  EventCountModel.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 31.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "EventCountModel.h"

@implementation EventCountModel

+ (instancetype)sharedInstance
{
    static EventCountModel* eventCountModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        eventCountModel = [EventCountModel new];
    });
    return eventCountModel;
}

@end
