//
//  VikePayload.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 29.04.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VikePayload : NSObject

- (instancetype)initWithContext:(NSDictionary *)context integrations:(NSDictionary *)integrations;

@property (strong, nonatomic, readonly) NSString *eventTypeString;
@property (strong, nonatomic, readonly) NSDictionary *context;
@property (strong, nonatomic, readonly) NSDictionary *integrations;

@end
