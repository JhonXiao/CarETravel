//
//  NoDataView.h
//  YongWeiPan
//
//  Created by xiaoliwu on 2017/1/6.
//  Copyright © 2017年 xiaoliwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NodataNotificationBack <NSObject>

- (void)notificationBackResponse;

@end

@interface NoDataView : UIView
@property (weak, nonatomic) IBOutlet UIButton *noDataImgBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipLb;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)backBtnAction:(id)sender;
@property (nonatomic, assign) id<NodataNotificationBack>dele;

@end
