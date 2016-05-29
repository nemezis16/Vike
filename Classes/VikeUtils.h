//
//  VikeUtils.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 06.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define STR_OR_WS(str)  str ? str : @""
#define ARR_OR_WS(arr)  arr ? arr : @[]

NSString *VikeISO8601FormattedString(NSDate *date);

NSDictionary *VikeCoerceDictionary(NSDictionary *dict);

NSURL *VikeAnalyticsURLForFilename(NSString *filename);

NSString *GetIPAddress();
NSString *GetDeviceModel();

NSString *GenerateUUIDString();

void VikeSetShowDebugLogs(BOOL showDebugLogs);
void VikeLog(NSString *format, ...);