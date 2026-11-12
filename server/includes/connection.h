#include <arpa/inet.h>
#include <string>
#pragma once

struct Vector3
{
    float x;
    float y;
    float z;
};

struct Client 
{
    std::string name;
    Vector3 position;
    float rotation;
};