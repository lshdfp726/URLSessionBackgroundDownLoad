//
//  AppDelegate.m
//  URLSessionBackGroundDownLoad
//
//  Created by 刘松洪 on 16/10/14.
//  Copyright © 2016年 刘松洪. All rights reserved.
//

#import "AppDelegate.h"
#define ImageUrl @"http://img05.tooopen.com/images/20141208/sy_76623349543.jpg"
#define moveMp4 @"http://up.qyjtb.com:90/x1x/2016101414/HD_dytt8-1482_u9m.exe"
@interface AppDelegate () <NSURLSessionDownloadDelegate>
@property (strong, nonatomic) NSString *filePath;//文件存储路径
@property (strong, nonatomic) void(^completionHandler)(void);
@property (strong, nonatomic) NSURLSessionDownloadTask *taskData;
@end

@implementation AppDelegate

- (NSString *)filePath {
    if (!_filePath) {
        NSArray *fileArray =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path     = [fileArray firstObject];
        _filePath          = [path stringByAppendingString:@"/Image"];
    }
    return _filePath;
}

- (NSURLSession *)backgroundSession {
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *identifier = @"BackgroundSession";
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        [configuration setSessionSendsLaunchEvents:YES];
        [configuration setDiscretionary:YES];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    });
    return session;
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"下载完成");
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager contentsAtPath:self.filePath]) {
        NSError *saveError = nil;
        //复制temp 下文件到自定义的文件夹下。
        [manager moveItemAtPath:location.relativePath toPath:self.filePath error:&saveError];
    }

}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
 
    NSLog(@"数据的大小:%lld",totalBytesExpectedToWrite);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"下载暂停");
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self performSelectorInBackground:@selector(downloadBackgroundTask) withObject:nil];
//    [self performSelector:@selector(downloadBackgroundTask) withObject:nil afterDelay:5.0];
    return YES;
}

- (void)downloadBackgroundTask {
//    NSFileManager *manager = [NSFileManager defaultManager];
//    if (![manager contentsAtPath:self.filePath]) {
        NSURL *url = [NSURL URLWithString:ImageUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSession *session = [self backgroundSession];
        self.taskData = [session downloadTaskWithRequest:request];
        self.taskData.priority = NSURLSessionTaskPriorityHigh;
        [self.taskData resume];
//    }else {
//       [[NSNotificationCenter defaultCenter] postNotificationName:@"updataImage" object:self.filePath];
//    }
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
//    NSURLSession *session = [self backgroundSession];
    if (!self.completionHandler) {
        self.completionHandler = completionHandler;
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
    if (self.completionHandler) { //session.configuration.identifier 就是我们之前标识的session 的名字,获取对应handler
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updataImage" object:self.filePath];
        self.completionHandler();
    }

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"进入后台");
 
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
