//
//  VikeIntegrationOs.m
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VikeIntegrationOs.h"
#import "VikeUtils.h"

@implementation VikeIntegrationOs

#pragma mark - Initializers

- (instancetype)init
{
    self = [super init];
    if (self) {
        _name = @"iOS";
        _version = [NSString stringWithFormat:@"%.2f", [[[UIDevice currentDevice] systemVersion] floatValue]];
    }
    return self;
}

#pragma mark - Public

- (NSDictionary *)jsonDictionary
{
    return @{
             @"name"    : STR_OR_WS(self.name),
             @"version" : STR_OR_WS(self.version)
             };
}

@end
