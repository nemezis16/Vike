//
//  VikeUtils.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeUtils.h"

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>

static BOOL AnalyticsLoggerShowLogs = YES;

#pragma mark - FileManaging

NSURL *VikeAnalyticsURLForFilename(NSString *filename)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *supportPath = [paths firstObject];
    if (![[NSFileManager defaultManager] fileExistsAtPath:supportPath
                                              isDirectory:NULL]) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:supportPath
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error]) {
            VikeLog(@"error: %@", error.localizedDescription);
        }
    }
    return [[NSURL alloc] initFileURLWithPath:[supportPath stringByAppendingPathComponent:filename]];
}

#pragma mark - Logs

void VikeSetShowDebugLogs(BOOL showDebugLogs)
{
    AnalyticsLoggerShowLogs = showDebugLogs;
}

void VikeLog(NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    NSLogv(format, args);
    va_end(args);
}

#pragma mark - UUID

NSString *GenerateUUIDString()
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    NSString *UUIDString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return UUIDString;
}

#pragma mark - ISO

NSString *VikeISO8601FormattedString(NSDate *date)
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    return [dateFormatter stringFromDate:date];
}

#pragma mark - CheckDictionaryMethods

static void AssertDictionaryTypes(id dict)
{
    BOOL compared = [dict isKindOfClass:[NSDictionary class]];
    assert(compared);
    for (id key in dict) {
        assert([key isKindOfClass:[NSString class]]);
        id value = dict[key];
        
        assert([value isKindOfClass:[NSString class]] ||
               [value isKindOfClass:[NSNumber class]] ||
               [value isKindOfClass:[NSNull class]] ||
               [value isKindOfClass:[NSArray class]] ||
               [value isKindOfClass:[NSDictionary class]] ||
               [value isKindOfClass:[NSDate class]] ||
               [value isKindOfClass:[NSURL class]]);
    }
}

static id VikeCoerceJSONObject(id obj)
{
    if ([obj isKindOfClass:[NSString class]] ||
        [obj isKindOfClass:[NSNumber class]] ||
        [obj isKindOfClass:[NSNull class]]) {
        return obj;
    }
    
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        for (id i in obj)
            [array addObject:VikeCoerceJSONObject(i)];
        return array;
    }
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (NSString *key in obj) {
            if (![key isKindOfClass:[NSString class]])
                VikeLog(@"warning: dictionary keys should be strings. got: %@. coercing "
                       @"to: %@",
                       [key class], [key description]);
            dict[key.description] = VikeCoerceJSONObject(obj[key]);
        }
        return dict;
    }
    
    if ([obj isKindOfClass:[NSDate class]])
        return VikeISO8601FormattedString(obj);
    
    if ([obj isKindOfClass:[NSURL class]])
        return [obj absoluteString];
    
    VikeLog(@"warning: dictionary values should be valid json types. got: %@. "
           @"coercing to: %@",
           [obj class], [obj description]);
    return [obj description];
}

NSDictionary *VikeCoerceDictionary(NSDictionary *dict)
{
    dict = dict ?: @{};
    AssertDictionaryTypes(dict);
    return VikeCoerceJSONObject(dict);
}

#pragma mark - DeviceInformation

NSString *GetIPAddress()
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    
    if (!success) {
        temp_addr = interfaces;
        while(temp_addr) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    
    return address;
}

NSString *GetDeviceModel()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *iOSDeviceModelsPath = [[NSBundle mainBundle] pathForResource:@"iOSDeviceModelMapping" ofType:@"plist"];
    NSDictionary *iOSDevices = [NSDictionary dictionaryWithContentsOfFile:iOSDeviceModelsPath];
    
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine
                                               encoding:NSUTF8StringEncoding];
    
    return [iOSDevices valueForKey:deviceModel];
}
