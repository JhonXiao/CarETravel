//
//  ViewController.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/3.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "ViewController.h"
#import "GcdNetSocket.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[GcdNetSocket shared] ipv6Connect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
