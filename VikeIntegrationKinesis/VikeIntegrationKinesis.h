//
//  VikeIntegrationKinesis.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 10.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VikeIntegrationKinesis : NSObject

+ (instancetype)setupWithWriteKey:(NSString *)writeKey;

+ (instancetype)sharedIntegrationKinesis; //need to setup first

- (void)storeRecords:(NSArray <NSData *> *)records withCompletion:(void(^)(NSError *error))completion;

@end
