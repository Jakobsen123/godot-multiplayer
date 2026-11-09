#include <sys/socket.h>
#include <netinet/in.h>
#include <vector>
#include <unistd.h>
#include <iostream>

#include "socket.h"
#include "print.h"

Socket::Socket()
{
    socketfd = socket(AF_INET, SOCK_DGRAM, 0);

    sockaddr_in sockaddr;
    sockaddr.sin_family = AF_INET;
    sockaddr.sin_addr.s_addr = INADDR_ANY;
    sockaddr.sin_port = htons(9999);
}
void Socket::Start()
{
    while (true)
    {
        int connection = accept(socketfd, nullptr, nullptr);
        char buffer[1024];
        while (true)
        {
            ssize_t bytesRead = read(connection, buffer, sizeof(buffer));
            std::cout << "Recieved:";
            std::cout.write(buffer, bytesRead);
        }
    }
};