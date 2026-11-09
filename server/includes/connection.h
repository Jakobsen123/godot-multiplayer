#include <arpa/inet.h>
#pragma once

struct Connection 
{
    in_addr addr;
    int port;
    int uid;
};