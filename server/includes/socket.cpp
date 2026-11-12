#include <sys/socket.h>
#include <netinet/in.h>
#include <vector>
#include <unistd.h>
#include <iostream>

#include "socket.h"
#include "print.h"

Socket::Socket(int port)
{
    socketfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (socketfd < 0)
    {
        perror("socket");
        return;
    }

    sockaddr_in addr{};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_port = htons(port);

    if (bind(socketfd, (sockaddr *)&addr, sizeof(addr)) < 0)
    {
        perror("bind");
        return;
    }
    std::cout << "LIVE: " << port << std::endl;
}

void Socket::Start()
{
    char buffer[1024];
    while (true)
    {
        sockaddr_in from{};
        socklen_t fromLen = sizeof(from);
        ssize_t n = recvfrom(socketfd, buffer, sizeof(buffer), 0, (sockaddr *)&from, &fromLen);

        std::cout << "Received: ";
        std::cout.write(buffer, n);
        std::cout << std::endl;
    }
}
