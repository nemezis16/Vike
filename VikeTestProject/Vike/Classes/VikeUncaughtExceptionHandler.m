//
//  VikeUncaughtExceptionHandler.m
//  VikeTestProject
//
//  Created by Roman Osadchuk on 18.05.16.
//  Copyright © 2016 Roman Osadchuk. All rights reserved.
//

#import "VikeUncaughtExceptionHandler.h"
#import "VikeUtils.h"

#import <libkern/OSAtomic.h>
#import <execinfo.h>

static VikeUncaughtExceptionHandler *selfRef;

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

@implementation VikeUncaughtExceptionHandler

#pragma mark - Initializers

- (instancetype)init
{
    self = [super init];
    if (self) {
        InstallUncaughtExceptionHandler();
        selfRef = self;
    }
    return self;
}

#pragma mark - Private

#pragma mark - ExceptionHandling

void InstallUncaughtExceptionHandler()
{
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}

void CompleteHandledException(NSException *exception)
{
    NSString *stacktraceString = [NSString stringWithFormat:@"%@\r%@",exception.reason,ARR_OR_WS(exception.userInfo[UncaughtExceptionHandlerAddressesKey])];
    NSDictionary *exceptionDictionary = @{
                                          @"name" : exception.name,
                                          @"stacktrace" : stacktraceString,
                                          @"fatal" : @1};
    BOOL complete = NO;
    
    if (selfRef.exceptionCallback) {
        selfRef.exceptionCallback(exceptionDictionary, &complete);
    }

    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!complete) {
        for (NSString *mode in (__bridge NSArray *)allModes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]) {
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    } else {
        [exception raise];
    }
}

- (void)handleException:(NSException *)exception
{
    NSDictionary *exceptionDictionary = @{
                                          @"name" : exception.name,
                                        @"reason" :  exception.reason,
                                    @"stacktrace" : [exception.userInfo objectForKey:UncaughtExceptionHandlerAddressesKey],
                                         @"fatal" : @1};
    BOOL complete = NO;
    
    if (self.exceptionCallback) {
       self.exceptionCallback(exceptionDictionary, &complete);
    }
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!complete) {
        for (NSString *mode in (__bridge NSArray *)allModes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]) {
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    } else {
        [exception raise];
    }
}

void HandleException(NSException *exception)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    
    NSString *callStack = [VikeUncaughtExceptionHandler backtrace];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    NSException *finalException = [NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo];
    
    CompleteHandledException(finalException);
}

void SignalHandler(int signal)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
    
    NSString *callStack = [VikeUncaughtExceptionHandler backtrace];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    NSString *exceptionReason = [NSString stringWithFormat: NSLocalizedString(@"Signal %d was raised.", nil), signal];
    NSDictionary *exceptionInfo = [NSDictionary dictionaryWithObject:@(signal) forKey:UncaughtExceptionHandlerSignalKey];
    NSException *exception = [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                                                     reason:exceptionReason
                                                   userInfo:exceptionInfo];

    NSException *finalException = [NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo];
    
    CompleteHandledException(finalException);
}

#pragma mark - Backtrace

+ (NSString *)backtrace
{
    void *callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    NSString *backtrace = @"";
    for (int i = UncaughtExceptionHandlerSkipAddressCount;
         i < UncaughtExceptionHandlerSkipAddressCount + UncaughtExceptionHandlerReportAddressCount;
         i++ ) {
        backtrace = [NSString stringWithFormat:@"%@\r%@",[NSString stringWithUTF8String:strs[i]],backtrace];
    }
    free(strs);
    
    return backtrace;
}

@end
