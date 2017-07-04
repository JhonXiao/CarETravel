//
//  IPAddress.h
//  NetSocketLib
//
//  Created by revenco on 13-12-4.
//  Copyright (c) 2013年 com.sunrise. All rights reserved.
//

#ifndef TradeClient_IPAddress_h
#define TradeClient_IPAddress_h

#define MAXADDRS	32

extern char *if_names[MAXADDRS];
extern char *ip_names[MAXADDRS];
extern char *hw_addrs[MAXADDRS];
extern unsigned long ip_addrs[MAXADDRS];

// Function prototypes

void InitAddresses();
void FreeAddresses();
void GetIPAddresses();
//void GetHWAddresses();
#endif
