//
//  VikeUncaughtExceptionHandler.h
//  VikeTestProject
//
//  Created by Roman Osadchuk on 18.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ExceptionCallback)(NSDictionary * exceptionDictionary, BOOL *complete);

@interface VikeUncaughtExceptionHandler : NSObject

@property (copy, nonatomic) ExceptionCallback exceptionCallback;

@end
