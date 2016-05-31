//
//  EventCountModel.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 31.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventCountModel : NSObject

@property (assign, nonatomic) NSInteger identifyCount;
@property (assign, nonatomic) NSInteger trackCount;
@property (assign, nonatomic) NSInteger screenCount;

+ (instancetype)sharedInstance;

@end
