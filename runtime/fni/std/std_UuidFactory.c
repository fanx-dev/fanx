#include "fni_ext.h"
#include "pod_std_native.h"

#ifdef _WIN64
#include <stdlib.h>
#include <Winsock2.h>
#include <Iptypes.h>
#include <iphlpapi.h>
#include <stdio.h>
#else
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>
#endif

fr_Int arrayToInt(unsigned char* bytes) {
    fr_Int x = ((bytes[0] & 0xFFL) << 40) | ((bytes[1] & 0xFFL) << 32) | ((bytes[2] & 0xFFL) << 24)
        | ((bytes[3] & 0xFFL) << 16) | ((bytes[4] & 0xFFL) << 8) | ((bytes[5] & 0xFFL) << 0);
    return x;
}

fr_Int std_UuidFactory_resolveMacAddr(fr_Env env) {

#ifdef _WIN64
    IP_ADAPTER_INFO AdapterInfo[16];
    DWORD dwBuflen = sizeof(AdapterInfo);

    DWORD dwStatus = GetAdaptersInfo(AdapterInfo, &dwBuflen);


    return arrayToInt((unsigned char*)AdapterInfo->Address);
    
#elif __APPLE__
    return 0;
#else
    struct ifreq ifreq;
    int sock;

    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
        perror("socket");
        return 0;
    }
    strcpy(ifreq.ifr_name, "eth0");    //Currently, only get eth0

    if (ioctl(sock, SIOCGIFHWADDR, &ifreq) < 0)
    {
        perror("ioctl");
        return 0;
    }

    return arrayToInt((unsigned char*)ifreq.ifr_hwaddr.sa_data);
#endif
}
