//
//  CaesarCrypt.h
//  NetSocketLib
//
//  Created by revenco on 13-12-17.
//  Copyright (c) 2013年 com.sunrise. All rights reserved.
//

#ifndef TradeClient_CaesarCrypt_h
#define TradeClient_CaesarCrypt_h

static char UC_ENCRYPT_CHARS[] = { 'M', 'D', 'X', 'U', 'P', 'I', 'B', 'E', 'J', 'C', 'T', 'N',
    'K', 'O', 'G', 'W', 'R', 'S', 'F', 'Y', 'V', 'L', 'Z', 'Q', 'A', 'H' };

static char LC_ENCRYPT_CHARS[] = { 'm', 'd', 'x', 'u', 'p', 'i', 'b', 'e', 'j', 'c', 't', 'n',
    'k', 'o', 'g', 'w', 'r', 's', 'f', 'y', 'v', 'l', 'z', 'q', 'a', 'h' };

static char UC_DECRYPT_CHARS[26] = {};

static char LC_DECRYPT_CHARS[26] = {};

bool static init_Caesar = false;

void InitCaesarUL()
{
	for (int i = 0; i < 26; i++)
	{
        char b = UC_ENCRYPT_CHARS[i];
        UC_DECRYPT_CHARS[b - 'A'] = (char) ('A' + i);
        b = LC_ENCRYPT_CHARS[i];
        LC_DECRYPT_CHARS[b - 'a'] = (char) ('a' + i);
    }
    init_Caesar=true;
    return;
}

static char CaesarEncrypt(char b)
{
 	if(!init_Caesar)
    {
        InitCaesarUL();
    }
    if (b >= 'A' && b <= 'Z')
    {
        return UC_ENCRYPT_CHARS[b - 'A'];
    }
    else if (b >= 'a' && b <= 'z')
    {
        return LC_ENCRYPT_CHARS[b - 'a'];
    }
    
    return b;
}

static char CaesarDecrypt(char b)
{
	if(!init_Caesar)
    {
        InitCaesarUL();
    }
    if (b >= 'A' && b <= 'Z')
    {
        return UC_DECRYPT_CHARS[b - 'A'];
    }
    else if (b >= 'a' && b <= 'z')
    {
        return LC_DECRYPT_CHARS[b - 'a'];
    }
    return b;
}

void CaesarEncryptStr(char a[],char out[])
{
    int i;
    unsigned long l = strlen(a);
    for(i=0;i<l;i++)
    {
        out[i]=CaesarEncrypt(a[i]);
    }
}

void CaesaDecryptStr(char a[],char out[])
{
    int i;
    unsigned long l = strlen(a);
    for(i=0;i<l;i++)
    {
        out[i]=CaesarDecrypt(a[i]);
    }
}

#endif
