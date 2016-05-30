//
//  FakeUser.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 29.04.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "FakeUser.h"

#import "NSString+Utils.h"

NSString *const kCurrentUserKey = @"CURRENT_USER_KEY";

@interface FakeUser ()

@property (strong, nonatomic, readwrite) NSString *userEmail;
@property (strong, nonatomic, readwrite) NSString *userID;

@end

@implementation FakeUser

#pragma mark - LifeCycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userEmail = [[NSString randomStringWithLength:10] stringByAppendingString:@"@test.com"];
        self.userID = [NSUUID UUID].UUIDString;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.userEmail = [coder decodeObjectForKey:@"userEmail"];
        self.userID = [coder decodeObjectForKey:@"userID"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.userEmail forKey:@"userEmail"];
    [coder encodeObject:self.userID forKey:@"userID"];
}

#pragma mark - Public

+ (FakeUser *)currentUserFromStorage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:kCurrentUserKey];
    FakeUser *currentUser = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return currentUser;
}

+ (instancetype)generateUser
{
    FakeUser *fakeUser = [[FakeUser alloc] init];
    
    [fakeUser saveUserAsCurrentUserToStorage];

    return fakeUser;
}

- (void)saveUserAsCurrentUserToStorage {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:kCurrentUserKey];
    [defaults synchronize];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"User with\remail: %@\rID: %@",self.userEmail,self.userID];
}

@end