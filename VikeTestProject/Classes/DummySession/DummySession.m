//
//  DummySession.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 16.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "DummySession.h"

static NSString *const kUsersKey = @"USERS_KEY";

@interface DummySession ()

@property (strong, nonatomic) NSMutableArray *cachedUsers;

@end

@implementation DummySession

#pragma mark - Initializers

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadCachedData];
    }
    return self;
}

#pragma mark - Accessors

- (FakeUser *)randomUser
{
    NSUInteger randomIndex = arc4random() % [self.cachedUsers count];
    return self.cachedUsers[randomIndex];
}

- (void)setCurrentUser:(FakeUser *)currentUser {
    _currentUser = currentUser;
    
    if (![self.cachedUsers containsObject:self.currentUser]) {
        [self saveCurrentUserToArray];
    }
}

#pragma mark - Public

+ (instancetype)defaultSession
{
    static DummySession *dummySession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dummySession = [[DummySession alloc]init];
    });
    
    return dummySession;
}

#pragma mark - Private

- (void)loadCachedData
{
    NSArray *usersCachedData = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults]
                                                                           objectForKey:kUsersKey]];
    if (usersCachedData) {
        self.cachedUsers = [NSMutableArray arrayWithArray:usersCachedData];
    } else {
        self.cachedUsers = [NSMutableArray new];
    }
}

- (void)saveCurrentUserToArray {
    [self.cachedUsers addObject:self.currentUser];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.cachedUsers] forKey:kUsersKey];
}

@end
