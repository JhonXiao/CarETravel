//
//  MemberNoticeVC.m
//  CarETravel
//
//  Created by yg on 2017/5/2.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "MemberNoticeVC.h"
#import "MainViewController.h"
#import "UIData.h"
#import "RegisterVC.h"

@interface MemberNoticeVC ()<UIWebViewDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *ContentWebView;
@property (weak, nonatomic) IBOutlet UIButton *checkRead;
@property (weak, nonatomic) IBOutlet UIButton *checkBox;
@property (weak, nonatomic) IBOutlet UIButton *disagreeBtn;
@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
- (IBAction)disagreeAction:(id)sender;
- (IBAction)agreeAction:(id)sender;
- (IBAction)checkReadAction:(id)sender;
- (IBAction)gouSelAction:(id)sender;

@end

@implementation MemberNoticeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title =@"顺事德养车会员须知";

    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"顺事德会员须知" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
//    NSURL *url = [NSURL fileURLWithPath:htmlFile];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [self.ContentWebView loadRequest:request];
    [self.ContentWebView loadHTMLString:htmlString baseURL:nil];
    self.ContentWebView.scrollView.delegate = self;
    self.ContentWebView.scrollView.bounces = NO;
    self.ContentWebView.scrollView.showsVerticalScrollIndicator = NO;
    self.ContentWebView.delegate = self;
    
    [self.checkRead setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateSelected];
    [self.checkBox setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateSelected];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    UIScrollView *scrollView = self.ContentWebView.scrollView;
    if (scrollView.contentSize.height -CGRectGetHeight(scrollView.frame) < 10.f) {
        self.checkRead.enabled = YES;
        self.agreeBtn.enabled = YES;
        scrollView.delegate = nil;
//        [self addTapToConfirmLabel];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    BOOL enableCheckBox = scrollView.contentSize.height -scrollView.contentOffset.y -CGRectGetHeight(scrollView.frame) < 10.f;
    if (enableCheckBox) {
        self.agreeBtn.enabled = YES;
        self.checkRead.enabled = YES;
        self.ContentWebView.scrollView.delegate = nil;
//        [self addTapToConfirmLabel];
    }
}

- (IBAction)disagreeAction:(id)sender {
    [UIData sharedClient].loginVCStatus = 1;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)agreeAction:(id)sender {
    if (self.checkRead.selected) {
        RegisterVC * registerVC = [[RegisterVC alloc] initWithNibName:@"RegisterVC" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:registerVC animated:YES];
    }
}

- (IBAction)checkReadAction:(id)sender {
//    self.checkRead.selected = !self.checkRead.selected;
}

- (IBAction)gouSelAction:(id)sender {
    self.checkRead.selected = !self.checkRead.selected;
}

@end
