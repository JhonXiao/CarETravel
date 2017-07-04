//
//  ClearCarViewController.m
//  CarETravel
//
//  Created by xiaoliwu on 2017/3/5.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import "ClearCarViewController.h"
#import "HWScanViewController.h"
#import "ComDetailViewController.h"

@interface ClearCarViewController ()
- (IBAction)btnClearCar:(id)sender;

@end

@implementation ClearCarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)btnClearCar:(id)sender {
//    HWScanViewController * hwScanVC = [[HWScanViewController alloc] init];
//    [self.navigationController pushViewController:hwScanVC animated:YES];
    
    ComDetailViewController * comDetailVC = [[ComDetailViewController alloc] initWithNibName:@"ComDetailViewController" bundle:[NSBundle mainBundle]];
    comDetailVC.comInfo = _serviceInfo;
    [self.navigationController pushViewController:comDetailVC animated:YES];
}
@end
