//
//  DummySession.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 16.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FakeUser.h"

@interface DummySession : NSObject

+ (instancetype)defaultSession;

@property (strong, nonatomic) FakeUser *currentUser;
@property (strong, nonatomic, readonly) FakeUser *randomUser;

@property (strong, nonatomic, readonly) NSMutableArray *cachedUsers;

@end
