//
//  DetailViewController.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 29.04.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "DetailViewController.h"

#import "DummySession.h"
#import "EventCountModel.h"

#import "VikeAnalytics.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *eventCountLabel;

@end

@implementation DetailViewController

#pragma mark - LifeCycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateEventCountLabel];
}

#pragma mark - Actions

- (IBAction)handleIdentifyEventTap:(id)sender
{
    NSString *userID = [DummySession defaultSession].currentUser.userID;
    [[VikeAnalytics sharedAnalytics] identify:userID traits:@{@"traitsKey":@"traitsVal"} options:@{VikePayloadKeyAnonymousID : @"olololid"}];
    
    [EventCountModel sharedInstance].identifyCount++;
    [self updateEventCountLabel];
}

- (IBAction)handleTrackEventTap:(id)sender
{
    NSString *userID = [DummySession defaultSession].currentUser.userID;
    NSString *trackString = [NSString stringWithFormat:@"Track with user: %@", userID];
    [[VikeAnalytics sharedAnalytics] track:trackString properties:@{@"somePropKey": @"somePropVal"} options:nil];
    
    [EventCountModel sharedInstance].trackCount++;
    [self updateEventCountLabel];
}

- (IBAction)handleScreenEventTap:(id)sender
{
      [[VikeAnalytics sharedAnalytics] screen:@"Second screen" properties:@{@"screen prop" : @"screen prop"} options:@{VikePayloadKeyIntegrations : @[@"Vike", @"Some integration"]}];
    [EventCountModel sharedInstance].screenCount++;
    [self updateEventCountLabel];
}

- (IBAction)handleExceptionEventTap:(id)sender
{
    [self performSelector:@selector(string)];
}

- (IBAction)handleBadAccessEventTap:(id)sender
{
    void (*nullFunction)() = NULL;
    nullFunction();
}

#pragma mark - Private

- (void)updateEventCountLabel
{
    EventCountModel *eventCountModel = [EventCountModel sharedInstance];
    self.eventCountLabel.text = [NSString stringWithFormat:@"Identify: %li\rTrack: %li\rScreen: %li", eventCountModel.identifyCount, eventCountModel.trackCount, eventCountModel.screenCount];
}

@end
