#include <iostream>
#include <string>

#pragma once

template <typename... Args>
void Print(Args... args)
{
    ((std::cout << " " << args << " " << std::endl), ...);
}