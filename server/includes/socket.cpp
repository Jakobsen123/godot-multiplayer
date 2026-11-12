#include <sys/socket.h>
#include <netinet/in.h>
#include <vector>
#include <unistd.h>
#include <iostream>

#include "socket.h"
#include "connection.h"
#include "print.h"
#include "includes/JSONParse.h"

Socket::Socket(const int port)
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

        std::string msg(buffer, n);
        Client c;
        if (JSONParse::Parse(msg, c))
        {
            std::cout << c.name;
        }

        std::cout
            << std::endl;
    }
}

void Socket::AddClient(const std::string &msg)
{
}

void Socket::RemoveClient(const Client &client)
{
    std::string key = client.name;
    std::erase_if(Clients, [key, this](const Client &i)
                  { return key == i.name; });
}

bool CompareClients(const Client &a, const Client &b)
{
    return (a.name == b.name);
}