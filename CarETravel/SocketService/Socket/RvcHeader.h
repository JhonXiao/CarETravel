//
//  RvcHeader.h
//  RvcNetwork
//
//  Created by revenco on 14-6-10.
//  Copyright (c) 2014年 sunrise. All rights reserved.
//

#define SUCESSED_CODE 99999    //响应成功编码
#define FORCEOFF_CODE 4006     //系统强制下线编码
#define LSPACKET_FLAG 1        //数据最后一包标识

//心跳
static const int Req_HeartBeat = 0x00010001;
static const int Res_HeartBeat = 0x00010002;
//密钥交换请求
static const int Req_exchangeKey = 0X10010003;
static const int Res_exchangeKey = 0X10010004;
//密钥验证请求
static const int Req_exchangeCheckKey = 0X10010005;
static const int Res_exchangeCheckKey = 0X10010006;

//获取短信验证码
static const int Req_GetValidateCode = 0x20010011;//车e行
static const int Res_GetValidateCode = 0x20010012;
/*
 用户注册：请求*0x20010012,应答*0x20010013
 */
static const int Req_UserRegister = 0x20010013;//车e行
static const int Res_UserRegister = 0x20010014;

//登录
static const int Req_Login = 0X30010001;//车e行
static const int Res_Login = 0X30010002;

//ServeListQueryReq 0X20010001, ServeListQueryRes 0X20010002
//服务列表查询请求
static const int Req_ServeList = 0X20010001;//车e行
static const int Res_ServeList = 0X20010002;

//UserOrderListQueryReq 0X20010007, UserOrderListQueryRes 0X20010008
//用户订单列表查询请求
static const int Req_UserOrderList = 0X20010007;//车e行
static const int Res_UserOrderList = 0X20010008;

//UserServeOrderReq 0X20010003, UserServeOrderRes 0X20010004
//用户服务订购请求
static const int Req_UserServeOrder = 0X20010003;//车e行
static const int Res_UserServeOrder = 0X20010004;

/**
 *用户订单支付请求*0x20010005,用户服务订购应答*0x20010006
 **/
static const int Req_OrderPayment = 0x20010005;//车e行
static const int Res_OrderPayment = 0x20010006;

/***
 用户账户余额查询：请求*0x2001001B，应答*0x2001001C
 ***/
static const int Req_GetUserBalance = 0x2001001B;//车e行
static const int Res_GetUserBalance = 0x2001001C;
/**
 用户充值：请求*0x2001001D，应答*0x2001000E(标准应答)
 **/
static const int Req_UserCharge = 0x2001001D;//车e行
static const int Res_UserCharge = 0x2001001E;

/**
 客户资料查询：请求*0x20010017，应答*0x20010018
 **/
static const int Req_GetUserInfo = 0x20010017;//车e行
static const int Res_GetUserInfo = 0x20010018;

/*
 客户资料完善：请求*0x20010015，应答*0x20010016
 一个客户下最多可以登记三个车牌
 */
static const int Req_UserInfoMod = 0x20010015;//车e行
static const int Res_UserInfoMod = 0x20010016;
//OrderBarcodeBindReq 0X20010009, OrderBarcodeBindRes 0X2001000A
//订单二维码绑定请求
static const int Req_OrderBarcodeBind = 0X20010009;//车e行
static const int Res_OrderBarcodeBind = 0X2001000A;

/**
 扫码校验请求：请求0x20010027,应答0x20010028
 **/
static const int Req_QuickBarcodeBind = 0x20010027;//车e行
static const int Res_QuickBarcodeBind = 0x20010028;

/**
 取消订单请求0x20010029,取消订单应答0x2001002A
 **/
static const int Req_CancelOrder = 0x20010029;//车e行
static const int Res_CancelOrder = 0x2001002A;

/***
 客服信息查询：请求*0x20010023,应答*0x20010024
 ***/
static const int Req_GetCSInfo = 0x20010023;//车e行
static const int Res_GetCSInfo = 0x20010024;

/****
 密码修改：请求*0x20010025,应答*0x20010026 标准应答
 ****/
static const int Req_ChagePasswd = 0x20010025;//车e行
static const int Res_ChagePasswd = 0x20010026;

/****
 汽车品牌查询协议  汽车品牌查询请求0x2001002B,汽车品牌查询应答0x2001002C
 ****/
static const int Req_CarBand = 0x2001002B;//车e行
static const int Res_CarBand = 0x2001002C;

/****
 汽车型号查询协议，汽车型号查询请求0x2001002D,汽车型号查询应答0x2001002E
 ****/
static const int Req_CarType = 0x2001002D;//车e行
static const int Res_CarType = 0x2001002E;

//公告
static const int Push_SysBulletin = 0X03010023;
static const int Push_Bulletin = 0X03010024;

