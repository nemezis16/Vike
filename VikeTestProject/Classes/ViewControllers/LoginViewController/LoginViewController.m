//
//  LoginViewController.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 29.04.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "LoginViewController.h"

#import "VikeAnalytics.h"
#import "DummySession.h"

#import "FakeUser.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UILabel *userEmailLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (strong, nonatomic) FakeUser *currentUser;
@property (strong, nonatomic) NSMutableArray *cachedUsers;

@end

@implementation LoginViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentUser = [DummySession defaultSession].currentUser;
    self.cachedUsers = [DummySession defaultSession].cachedUsers;
    
    [self configureView];
}

#pragma mark - Actions

- (IBAction)handleRegisterButtonTap:(id)sender
{
    [self registerUser];
}

- (IBAction)handleLoginButtonTap:(id)sender
{
    [self loginUser];
}

- (IBAction)handleLogoutButton:(id)sender
{
    [self logoutUser];
}

#pragma mark - Private

- (void)configureView {
    [self configureButtons];
    [self configureLabels];
}

- (void)configureLabels {
    if (self.currentUser) {
        self.userEmailLabel.text = [@"User email: " stringByAppendingString:self.currentUser.userEmail];
        self.userIDLabel.text = [@"User ID: " stringByAppendingString: self.currentUser.userID];
    } else {
        self.userEmailLabel.text = @"No Email";
        self.userIDLabel.text = @"No ID";
    }
}

- (void)configureButtons {
    if (self.currentUser) {
        self.registerButton.enabled = NO;
        self.loginButton.enabled = NO;
        self.logoutButton.enabled = YES;
    } else if (self.cachedUsers.count > 0) {
        self.loginButton.enabled = YES;
        self.registerButton.enabled = YES;
        self.logoutButton.enabled = NO;
    } else {
        self.loginButton.enabled = NO;
        self.registerButton.enabled = YES;
        self.logoutButton.enabled = NO;
    }
}

- (void)registerUser
{
    self.currentUser = [DummySession defaultSession].currentUser = [FakeUser generateUser];
    
    [self configureButtons];
    [self configureLabels];
}

- (void)loginUser
{
    self.currentUser = [DummySession defaultSession].currentUser = [DummySession defaultSession].randomUser;

    [self configureButtons];
    [self configureLabels];
}

- (void)logoutUser
{
    self.currentUser = nil;
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCurrentUserKey];
    
    [self configureButtons];
    [self configureLabels];
}

@end
