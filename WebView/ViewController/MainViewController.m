//
//  MainViewController.m
//  WebView
//
//  Created by bet001 on 2018/8/1.
//  Copyright © 2018年 bet365. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController () <WKUIDelegate, WKNavigationDelegate> {
    BOOL ResquestHttp;  // 请求头切换
}
@property (nonatomic, strong) WKWebViewConfiguration *config;
@property (nonatomic, strong) WKWebView *webView;  // 浏览器
@property (nonatomic, strong) UIProgressView *progressView;  // 进度条
@property (nonatomic, strong) NSString *currenWeb_Url;  // 当前网站
@property (nonatomic, strong) NSString *baseWeb_Url;
@property (nonatomic, strong) UIImageView *bgImageview;  // 背景图片


@end

@implementation MainViewController

#pragma mark - 懒加载

- (WKWebViewConfiguration *)config {
    if (!_config) {
        
        // 禁止长按拷贝、剪切、粘贴事件
        // 禁止选择CSS
        
        NSString *css = @"body{-webkit-user-select:none;-webkit-user-drag:none;}";
        
        // CSS选中样式取消
        NSMutableString *javascript = [NSMutableString string];
        [javascript appendString:@"var style = document.createElement('style');"];
        [javascript appendString:@"style.type = 'text/css';"];
        [javascript appendFormat:@"var cssContent = document.createTextNode('%@');", css];
        [javascript appendString:@"style.appendChild(cssContent);"];
        [javascript appendString:@"document.body.appendChild(style);"];
        
        // javascript注入
        WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        [userContentController addUserScript:noneSelectScript];
        
        // 初始化
        _config = [[WKWebViewConfiguration alloc] init];
        
        // 是否支持 JavaScript
        _config.preferences.javaScriptEnabled = YES;
        // 不通过用户交互是否可以打开窗口
        _config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    }
    return _config;
}

//
- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:mainWebViewFrame configuration:self.config];
        
        // 代理
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        
        // 侧滑返回
        _webView.allowsBackForwardNavigationGestures = YES;
        // 自动适配横屏
        [_webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [_webView setAutoresizesSubviews:YES];
        
        [self.view addSubview:_webView];
    }
    return _webView;
}

//
- (UIProgressView *)progressView {
    if (!_progressView) {
        // 初始化并设置展示风格（ UIProgressViewStyleBar 一般用于 toolbar ）
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
//        _progressView.frame = progressViewFrame;
        
        _progressView.backgroundColor = [UIColor greenColor];  // 背景颜色
        _progressView.progressTintColor = [UIColor redColor];  // 填充部分颜色（即进度条颜色）
        _progressView.trackTintColor = [UIColor yellowColor];  // 为填充部分颜色
        [self.view addSubview:_progressView];
    }
    return _progressView;
}

//
- (NSString *)currenWeb_Url {
    return  _currenWeb_Url;
}

//
- (UIImageView *)bgImageview {
    if (!_bgImageview) {
        _bgImageview = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self.view addSubview:_bgImageview];
    }
    return _bgImageview;
}


#pragma mark - View 视图周期
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ResquestHttp = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView.backgroundColor = [UIColor whiteColor];
    
    [self startLoadRequestWithUrl:Host_default];

    // 设置监听者KVO，监听 WKWebView 对象的 title 和 estimatedProgress 属性，就是当前网页的 标题 和 网页加载的进度
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    // 移除 KVO
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

#pragma mark - KVO监听
/** KVO 进度条监听 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    // 判断是否是自定义webView
    if (object ==self.webView) {
        if ([keyPath isEqualToString:@"estimatedProgress"]) {
            
            [self.progressView setAlpha:1.0f];
            [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
            NSLog(@"已加载：%.2f", self.progressView.progress);
            
            /**
             添加一个简单的动画，将 progressView 变为透明
             动画时长0.3s，延时0.3s后开始动画
             动画结束后将 progressView 变为透明
             */
            if (self.webView.estimatedProgress >= 1.0f) {
                [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.progressView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [self.progressView setProgress:0.0f animated:NO];
                }];
            }
            
        }else if ([keyPath isEqualToString:@"title"]) {
            NSLog(@"webtitle:%@", self.webView.title);
            
        }else {
            
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
            
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

#pragma mark - WKWebView
/** WKWebView 加载 */
- (void) startLoadRequestWithUrl:(NSString *)urlStr {
    
    // 请求的url
    self.baseWeb_Url = urlStr;
    
    if (ResquestHttp) {
        self.currenWeb_Url = [NSString stringWithFormat:Host_http, self.baseWeb_Url];
        ResquestHttp = NO;
    }else {
        self.currenWeb_Url = [NSString stringWithFormat:Host_https, self.baseWeb_Url];
        ResquestHttp = YES;
    }
    NSLog(@"当前加载：%@", self.currenWeb_Url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.currenWeb_Url]];
    [self.webView loadRequest:request];
}


#pragma mark - WKNavigationDelegate
/** 页面开始加载webView内容时调用 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"开始加载webView内容");
}

/** 当webView内容开始返回时调用 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"webView内容开始返回");
}

/** 当webView加载完成时调用 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"webView加载完成");
}

/** webView加载失败时调用 (【web视图加载内容时】发生错误) */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"webView加载失败");
}

/** webView导航过程中发生错误时调用 */
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"webView导航加载错误");
    NSLog(@"Error:%@", error);
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.webView reload];
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
    
    [self creatAlertControllerWithTitle:@"网页加载失败" Message:@"请问是否重新加载" PreferredStyle:UIAlertControllerStyleAlert AlertActionArr:@[action1, action2]];
}

/** 当webView内容进程终止时调用 */
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"webView终止加载内容");
}

/** 在发送请求之前，决定是否跳转 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"发送请求前,决定是否跳转");
    NSLog(@"加载：%@", [navigationAction.request valueForKey:@"URL"]);
    
    // 确认可以跳转
    decisionHandler(WKNavigationActionPolicyAllow);
}

/** 在收到响应后，决定是否跳转 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"在收到响应后，决定是否跳转");
    
    // 确认可以跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
}

/** 收到服务器重定向之后调用（接收到服务器跳转请求）*/
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"接收到服务器跳转请求");
}

/** 证书验证处理 https 可以自签名 */
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(nonnull NSURLAuthenticationChallenge *)challenge completionHandler:(nonnull void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        // 如果没有错误的情况下，创建一个凭证，并使用证书
        if (challenge.previousFailureCount == 0) {
            //创建一个凭证，并使用证书
            NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }else {
            //验证失败，取消本次验证
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    }else {
        //验证失败，取消本次验证
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
    
}

#pragma mark - WKUIDelegate
/** 创建新的webView（打开新窗口） */
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    /** 创建新的wenview窗口有点浪费资源，直接在原有窗口进行加载即可 */
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        [webView loadRequest:navigationAction.request];
    }
    NSLog(@"打开新窗口");
    
    return nil;
    
}

/** 关闭webView */
- (void)webViewDidClose:(WKWebView *)webView {
    NSLog(@"关闭webView");
}

/** 以下三个代理都是与界面弹出提示框相关，分别针对web界面的三种提示框（警告框、确认框、输入框）的代理，如果不实现网页的alert函数无效 */
/** 警告框 【显示 JavaScript 弹窗alert】 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [self creatAlertControllerWithTitle:message Message:nil PreferredStyle:UIAlertControllerStyleAlert AlertActionArr:@[action]];
    
}

/** 选择框 【测试JS代码：confirm（"confirm message"）】 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    
    [self creatAlertControllerWithTitle:message Message:nil PreferredStyle:UIAlertControllerStyleAlert AlertActionArr:@[action1, action2]];
}

/** 输入框  */
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    NSLog(@"输入框");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = defaultText;
    }];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields.firstObject;
        completionHandler(textField.text);
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UIAlertViewController
/** UIAlertViewController 简单封装 */
- (void)creatAlertControllerWithTitle:(NSString *)title Message:(NSString *)message PreferredStyle:(UIAlertControllerStyle)preferredStyle AlertActionArr:(NSArray *)alertActionArr {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    
    // 遍历
    for (UIAlertAction *action in alertActionArr) {
        [alertController addAction:action];
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
//    self.webView.frame = mainWebViewFrame;
    NSLog(@"屏幕方面变了");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
