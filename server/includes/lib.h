#include <iostream>
#include <string>

#pragma once

template <typename... Args>
void Print(Args... args)
{
    ((std::cout << " " << args << " " << std::endl), ...);
}

inline std::string ToLower(std::string &str)
{
    for (char &c : str)
    {
        std::tolower(c);
    }
    return str;
}