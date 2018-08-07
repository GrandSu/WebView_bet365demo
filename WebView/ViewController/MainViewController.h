//
//  MainViewController.h
//  WebView
//
//  Created by bet001 on 2018/8/1.
//  Copyright © 2018年 bet365. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <WKUIDelegate, WKNavigationDelegate> {
    BOOL ResquestHttp;  // 请求头切换
}
@property (nonatomic, strong) WKWebViewConfiguration *config;
@property (nonatomic, strong) WKWebView *webView;  // 浏览器
@property (nonatomic, strong) UIProgressView *progressView;  // 进度条
@property (nonatomic, strong) NSString *currenWeb_Url;  // 当前网站
@property (nonatomic, strong) NSString *baseWeb_Url;
@property (nonatomic, strong) UIImageView *bgImageview;  // 背景图片

@end
