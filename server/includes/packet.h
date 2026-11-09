#include <string>
#pragma once

struct Packet
{
    std::string header;
    std::string data;
    std::string identifier;
};