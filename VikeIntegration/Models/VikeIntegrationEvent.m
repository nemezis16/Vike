//
//  VikeIntegrationEvent.m
//  VikeTestProject
//
//  Created by user on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeIntegrationEvent.h"

#import <AWSCore/AWSGZIP.h>

#import "VikeUtils.h"
#import "VikeConstants.h"

@implementation VikeIntegrationEvent

#pragma mark - Initializers

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
        _app = [VikeIntegrationApp new];
        _device = [VikeIntegrationDevice new];
        _os = [VikeIntegrationOs new];
        _ip = GetIPAddress();
        _channel = @"mobile";
    }
    return self;
}

#pragma mark - Public

- (NSDictionary *)jsonDictionary
{
    return @{
            @"projectId"            : STR_OR_WS(self.projectId),
            @"userId"               : STR_OR_WS(self.userId),
            @"anonymousId"          : STR_OR_WS(self.anonymousId),
            @"timestamp"            : STR_OR_WS(self.timestamp),
            @"ip"                   : STR_OR_WS(self.ip),
            @"type"                 : STR_OR_WS(self.type),
            @"channel"              : STR_OR_WS(self.channel),
            @"messageId"            : STR_OR_WS(self.messageId),
            @"properties"           : self.properties ? self.properties : @{},
            @"bundled_integrations" : self.bundledIntegrations ? self.bundledIntegrations : @{},
            @"app"                  : [self.app jsonDictionary],
            @"device"               : [self.device jsonDictionary],
            @"os"                   : [self.os jsonDictionary]
            };
}

- (NSData *)gzipData
{
    NSData *jsonData = [NSKeyedArchiver archivedDataWithRootObject:[self jsonDictionary]];
    return [jsonData awsgzip_gzippedData];
}

@end
