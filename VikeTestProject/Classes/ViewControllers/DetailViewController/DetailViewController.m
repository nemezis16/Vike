//
//  DetailViewController.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 29.04.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "DetailViewController.h"

#import "DummySession.h"

#import "VikeAnalytics.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation DetailViewController

#pragma mark - LifeCycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[VikeAnalytics sharedAnalytics] screen:@"Second screen" properties:@{@"screen prop" : @"screen prop"} options:@{VikePayloadKeyIntegrations : @[@"Vike", @"Some integration"]}];
}

#pragma mark - Actions

- (IBAction)handleFistEventTap:(id)sender
{
    NSString *userID = [DummySession defaultSession].currentUser.userID;
    [[VikeAnalytics sharedAnalytics] identify:userID traits:@{@"traitsKey":@"traitsVal"} options:@{VikePayloadKeyAnonymousID : @"olololid"}];
}

- (IBAction)handleSecondEventTap:(id)sender
{
    NSString *userID = [DummySession defaultSession].currentUser.userID;
    NSString *trackString = [NSString stringWithFormat:@"Track with user: %@", userID];
    
    [[VikeAnalytics sharedAnalytics] track:trackString properties:@{@"somePropKey": @"somePropVal"} options:nil];
}

@end
