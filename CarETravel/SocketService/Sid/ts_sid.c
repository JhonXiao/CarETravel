#include <unistd.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <errno.h>
#include <net/if.h>     
#include <netinet/in.h>     
//#include <net/if_arp.h>
#include <sys/ioctl.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <net/if_dl.h>
#include <sys/sysctl.h>

#include "ts_sid.h"
#include "util.h"
#include "ts_time.h"
#include "IPAddress.h"

static int64_t get_mac_address();

int get_iphone_mac(char * macstr){
    int                    mib[6];
    size_t                len;
    char                *buf;
    unsigned char        *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl    *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return -1;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return -1;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return -1;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);
        printf("Error: sysctl, take 2");
        return -1;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);

    sprintf(macstr, "%06x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5));
    free(buf);
    
    return 0;
}

int64_t get_mac_address()
{
    int num_of_interface;
    struct ifreq req[16];
    struct ifconf ifc;
    ifc.ifc_len = sizeof(req);
    ifc.ifc_buf = (caddr_t)req;
    int64_t mac_address = -1;
    
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if(sockfd < 0)
    {
        //LOG_ERROR("socket failed.%s\n", strerror(errno));
        return -1;
    }
    
    if(!ioctl(sockfd, SIOCGIFCONF, (char*)&ifc))
    {
        num_of_interface = ifc.ifc_len/sizeof(struct ifreq);
        /*
         LOG_DEBUG("interface num = %d\n", num_of_interface);
         */
        
        for(int index = 0; index < num_of_interface; index++)
        {
            /*
             LOG_DEBUG("interface name:%s\n", req[index].ifr_name);
             */
            
            if(strncmp(req[index].ifr_name, "lo", 2) == 0)
            {
                //ignore the lo interface
                /*
                 LOG_DEBUG("ignore the lo interface.\n");
                 */
                continue;
            }
            
            if((ioctl(sockfd, SIOCGIFFLAGS, &req[index])) == -1)
            {
                //LOG_WARN("ioctl SIOCGIFFLAGS failed. %s\n", strerror(errno));
                continue;
            }
            
            if(!(req[index].ifr_flags & IFF_UP))
            {
                //ignore the interface if it's status is down.
                /*
                 LOG_DEBUG("ignore the interface if it's status is down\n");
                 */
                continue;
            }
            
            //Get HWaddr of the interface
            if(!(ioctl(sockfd, SIOCGIFMAC, &req[index])))
            {
                struct sockaddr hwaddr = req[index].ifr_addr;
                mac_address = *(int64_t*)hwaddr.sa_data;
                /*
                 LOG_DEBUG("original mac:%lx\n", mac_address);
                 */
                mac_address = ntohl64(mac_address);
                if(0 == (mac_address & 0xffff))
                {
                    mac_address = mac_address >> 16;
                    mac_address &= 0x0000ffffffffffff;
                }
                /*
                 LOG_DEBUG("after exchange:%lx\n", mac_address);
                 */
                break;
            }
            else
            {
                //LOG_WARN("ioctl SIOCGIFHWADDR failed. %d %s\n", errno, strerror(errno));
            }
        }
    }
    
    return mac_address;
}


int get_sid_two(int loginid, int64_t *sid_first, int64_t *sid_second)
{
    if((NULL == sid_first || NULL == sid_second))
    {
        return -1;
    }

    static int64_t mac = -1;
    static int pid = -1;
//    if(mac == -1)
//        mac = get_mac_address();

    if(pid == -1)
    {
        pid = getpid();
        srand((unsigned int)pid);
    }

    if(0 == loginid)
        loginid = rand();

    *sid_first = mac << 32;
    *sid_first &= 0xffffffff00000000;
    *sid_first |= loginid;

    *sid_second = get_utc_microseconds();
    *sid_second = *sid_second << 12;
    int arand = rand() % 4096;
    *sid_second |= arand;

    return 0;
}

int get_sid_one(int loginid, ts_sid_t *sid)
{
    if((NULL == sid))
    {
        return -1;
    }

    return get_sid_two(loginid, &sid->sid_first, &sid->sid_second);
}

int get_sid_str(int loginid, char* dest, int dest_len)
{
    if((NULL == dest || dest_len < 32))
        return -1;

    int64_t sid_first = -1;
    int64_t sid_second = -1;

    if(get_sid_two(loginid, &sid_first, &sid_second) != 0)
        return -1;

    char mac[128] = {0};
    
    get_iphone_mac(mac);
    //snprintf(dest, dest_len, "%llx", sid_first);
//    snprintf(dest, dest_len,"%s",mac);//get_mac_address
//    snprintf(dest + 16, dest_len - 16, "%llx", sid_second);
//    snprintf(dest, sizeof(dest),"%s",mac);//get_mac_address
//    snprintf(dest , sizeof(dest), "%llx", sid_second);
    sprintf(dest, "%16s%016llx",mac,sid_second);
    //printf("sid is :%s\n",dest);
    return 0;
}




