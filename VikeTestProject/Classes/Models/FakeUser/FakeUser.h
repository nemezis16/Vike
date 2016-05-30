//
//  FakeUser.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 29.04.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kCurrentUserKey;

@interface FakeUser : NSObject <NSCoding>

@property (strong, nonatomic, readonly) NSString *userEmail;
@property (strong, nonatomic, readonly) NSString *userID;

+ (instancetype)generateUser;

//+ (FakeUser *)currentUserFromStorage;
//- (void)saveUserAsCurrentUserToStorage;

@end
