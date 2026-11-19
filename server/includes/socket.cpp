#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <vector>
#include <unistd.h>
#include <iostream>

#include "socket.h"
#include "connection.h"
#include "lib.h"
#include "JSONParse.h"

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
        if (n <= 0)
        {
            perror("recvfrom");
            continue;
        }

        std::string msg(buffer, n);
        Client c;
        std::string type;
        if (!JSONParse::Parse(msg, c, type))
            continue;
        c.addr = from;

        if (type == "delete_player")
        {
            RemoveClient(c);
            return;
        }
        else if (ClientExists(c))
        {
            UpdateClient(c);
        }
        else
        {
            AddClient(c);
        }

        std::string sender = ToLower(c.name);
        for (Client &i : Clients)
        {
            if (ToLower(i.name) == sender)
                continue;

            if (sendto(socketfd, msg.data(), msg.size(), 0,
                       (const sockaddr *)&i.addr, sizeof(i.addr)) < 0)
                perror("sendto");
        }
    }
}

bool Socket::ClientExists(Client &c)
{
    std::string b = ToLower(c.name);
    for (Client &i : Clients)
    {
        if (ToLower(i.name) == b)
            return true;
    }
    return false;
}

bool Socket::CompareClients(Client &a, Client &b)
{
    return ToLower(a.name) == ToLower(b.name);
}

void Socket::AddClient(Client &c)
{
    Clients.push_back(c);

    char ip[INET_ADDRSTRLEN];
    inet_ntop(AF_INET, &c.addr.sin_addr, ip, sizeof(ip));
    std::cout << "Client Added: " << c.name << " (" << ip << ":" << ntohs(c.addr.sin_port) << ")\n";
}

void Socket::UpdateClient(Client &c)
{
    for (auto &i : Clients)
    {
        if (CompareClients(i, c))
        {
            i.position = c.position;
            i.rotation = c.rotation;
            i.addr = c.addr;
        }
    }
}

void Socket::RemoveClient(Client &client)
{
    std::string key = ToLower(client.name);
    std::erase_if(Clients, [&key](Client &i)
                  { return key == ToLower(i.name); });
}