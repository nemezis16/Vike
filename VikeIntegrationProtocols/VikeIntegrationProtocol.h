//
//  VikeIntegration.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 03.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VikeIdentifyPayload;
@class VikeTrackPayload;
@class VikeScreenPayload;

@protocol VikeIntegrationProtocol <NSObject>

@optional

- (void)identify:(VikeIdentifyPayload *)payload;

- (void)track:(VikeTrackPayload *)payload;

- (void)screen:(VikeScreenPayload *)payload;

- (void)reset;

- (void)flush;

- (void)receivedRemoteNotification:(NSDictionary *)userInfo;
- (void)failedToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)registeredForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)applicationDidEnterBackground;
- (void)applicationWillEnterForeground;
- (void)applicationWillTerminate;
- (void)applicationWillResignActive;
- (void)applicationDidBecomeActive;

@end
