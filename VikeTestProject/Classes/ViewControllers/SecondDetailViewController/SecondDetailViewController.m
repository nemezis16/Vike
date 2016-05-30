//
//  SecondDetailViewController.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 29.04.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "SecondDetailViewController.h"

#import "VikeAnalytics.h"

@interface SecondDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation SecondDetailViewController

#pragma mark - LifeCycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[VikeAnalytics sharedAnalytics] screen:@"Third screen" properties:@{@"screen prop" : @"screen prop"} options:@{VikePayloadKeyIntegrations : @[@"Vike", @"Some integration"]}];
}
#pragma mark - Actions

- (IBAction)handleFirstEventTap:(id)sender
{
    [self performSelector:@selector(string)];
}

- (IBAction)handleSecondEventTap:(id)sender
{
    void (*nullFunction)() = NULL;
    
    nullFunction();
}

- (IBAction)handleThirdEventTap:(id)sender
{
    NSLog(@"Event not implemented");
}

@end
