//
//  VikeIntegrationApp.m
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeIntegrationApp.h"
#import "VikeUtils.h"

@implementation VikeIntegrationApp

#pragma mark - Initializers

- (instancetype)init
{
    self = [super init];
    if (self) {
        _name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"];
        _appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        _version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        _build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        
    }
    return self;
}

#pragma mark - Public

- (NSDictionary *)jsonDictionary
{
    return @{
             @"name"    : STR_OR_WS(self.name),
             @"id"      : STR_OR_WS(self.appId),
             @"version" : STR_OR_WS(self.version),
             @"build" : STR_OR_WS(self.build)
             };
}

@end
