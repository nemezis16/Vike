//
//  VikeNetworking.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 10.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeRequest.h"

@interface VikeRequest ()

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation VikeRequest

#pragma mark - Initializers

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
    return self;
}

#pragma mark - Public

- (void)startWithURLRequest:(NSURLRequest *)request completion:(VikeRequestCompletionBlock)completion
{
    [[self.session dataTaskWithRequest:request completionHandler:completion] resume];
}

@end
