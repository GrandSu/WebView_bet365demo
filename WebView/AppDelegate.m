//
//  AppDelegate.m
//  WebView
//
//  Created by bet001 on 2018/8/1.
//  Copyright © 2018年 bet365. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) MainViewController *mainVC;

@end

@implementation AppDelegate
static BOOL isShow = NO;


- (MainViewController *)mainVC {
    if (!_mainVC) {
        _mainVC = [[MainViewController alloc] init];
    }
    return _mainVC;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [NSThread sleepForTimeInterval:2.0];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // 监听网络状态
    [self listenNetworkReachabilityStatus];
    
    
    [self.window setRootViewController:self.mainVC];
    
    //    // 让当前 UIWindow 窗口变成 keyWiindow (主窗口)
    //    [self.window makeKeyWindow];
    
    // 让当前 UIWindow 窗口变成 keyWiindow (主窗口)，并显示出来
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)listenNetworkReachabilityStatus {
    
    // 实例化 AFNetworkReachabilityManager
    AFNetworkReachabilityManager * afManager = [AFNetworkReachabilityManager sharedManager];
    
    
    /**
     判断网络状态并处理
     @param status 网络状态
     AFNetworkReachabilityStatusUnknown             = 未知网络
     AFNetworkReachabilityStatusNotReachable        = 没有网络
     AFNetworkReachabilityStatusReachableViaWWAN    = 蜂窝网络（3g、4g、wwan）
     AFNetworkReachabilityStatusReachableViaWiFi    = wifi网络
     */
    [afManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"当前网络状态未知");
                [self starAlertControllerWithNote:@"当前网络状态未知"];
                isShow = YES;
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"网络已断开");
                [self starAlertControllerWithNote:@"网络已断开"];
                isShow = YES;
                break;
                
            default:
                NSLog(@"网络已连接");
                if (isShow) {
                    [self starAlertControllerWithNote:@"网络已连接"];
                    isShow = NO;
                }
                break;
        }
    }];
    
    // 开始监听
    [afManager startMonitoring];
}

- (void)dealloc {
    // 移除网络监听通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)starAlertControllerWithNote:(NSString *)note {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:note preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.mainVC.webView reloadFromOrigin];
    }];
    
    [alertController addAction:action];
    
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
