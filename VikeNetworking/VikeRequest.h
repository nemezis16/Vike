//
//  VikeNetworking.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 10.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ VikeRequestCompletionBlock)(NSData * data, NSURLResponse * response, NSError * error);

@interface VikeRequest : NSObject

- (instancetype)init;

- (void)startWithURLRequest:(NSURLRequest *)request completion:(VikeRequestCompletionBlock)completion;

@end
