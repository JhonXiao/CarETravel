//
//  Config.h
//  Wqt
//
//  Created by xiaoliwu on 16/9/8.
//  Copyright © 2016年 xiaoliwu. All rights reserved.
//

#ifndef Config_h
#define Config_h

#define   ERROR_CODE_PWD_ERR                     -10000            //密码不正确
#define   ERROR_CODE_NO_ORDER                    -10001            //查不到订单
#define   ERROR_CODE_NO_CABNIT                   -10002            //没有这个储物柜在指定机柜上
#define   ERROR_CODE_CABNIT_NO_ATTR              -10003            //查询不到机柜属性
#define   ERROR_CODE_ALREADY_CHARGED             -10004            //已经扣过费
#define   ERROR_CODE_CUB_CAN_NOT_USE             -10005            //储物柜不能被占用
#define   ERROR_CODE_UNNORMAL_USER               -10006            //不正常的LOGINID
#define   ERROR_CODE_UNCORRECT_STATUS            -10007            //当前订单状态不正确
#define   ERROR_CODE_UNKNOW_USER_TYPE            -10008            //未知的用户类型
#define   ERROR_CODE_GRID_OFFLINE                -10009            //机柜下线
#define   ERROR_CODE_NO_GRID                     -10010            //指定的机柜ID不存在
#define   ERROR_CODE_ALL_CUBE_UNUSEABLE          -10011            //所有储物柜都不可用
#define   ERROR_CODE_GET_ORDER_ID_FAILD          -10012            //获取订单号失败
#define   ERROR_CODE_BAD_USER_TYPE               -10013            //错误的用户类型

#define day70_00  25566//1900和1970之间的天数

//定义枚举类型
typedef enum {
    ENUM_ProfitItemViewState_Normal =0,//正常
    ENUM_ProfitItemViewState_Selected,//选中
} ENUM_ProfitItemViewState_StateType;

// 开休市状态
typedef NS_ENUM(NSInteger, MarketStatus) {
    MarketClosed = 0,
    MarketOpened = 1,
    MarketPaused = 2
};

#define SUCESSED_CODE 99999    //响应成功编码
#define FORCEOFF_CODE 4006     //系统强制下线编码
#define AF_FORCEOFF_CODE 2     //报表生成强制退出

#define kParseRetCodeOK @"_ParseRetCodeOK_"

#define kQuotdataCache @"QuotData_Cache_"
#define kQuotPushdataCache @"QuotPushData_Cache_" // 缓存的上一口报价
#define kQuotPushCacheCount 100 // 缓存的报价口数
#define kTradeClientTag 1002 // 交易客户类型

#define kCommodityInfoData @"CommodityInfoData"
#define kQuotionDataQuery @"QuotationDataRecently"
#define kCustomerBankInfo @"CustomerBankInfo"
#define kE2eQueryMoneyAmountInfo @"E2eQueryMoneyAmount"
#define kHolderOrderInfo @"HolderOrderInfo"
#define kAccountQueryInfo @"AccountQueryInfo"
#define kDictItemData @"DictItemData"

#define COMMON_BACK_COLOR [UIColor colorWithWhite:0.942 alpha:1];
#define LEFT_MENU_COLOR [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1]

#define kSystemVersionLowerThan7 ([UIDevice currentDevice].systemVersion.floatValue<7.0)
#define screen_width  [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height

#define kUIScreenWidth [UIScreen mainScreen].bounds.size.width
#define kUIScreenHeight [UIScreen mainScreen].bounds.size.height

#endif /* Config_h */
