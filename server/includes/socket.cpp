#include <sys/socket.h>
#include <netinet/in.h>
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

        std::string msg(buffer, n);
        Client c;
        if (JSONParse::Parse(msg, c))
        {
            if (ClientExists(c))
            {
                UpdateClient(c);
            }
            else
            {
                AddClient(c);
            }
        }
        for (Client i : Clients)
        {
            nlohmann::json out = {
                {"type", "update_player"},
                {"name", i.name},
                {"position", {{"x", i.position.x}, {"y", i.position.y}, {"z", i.position.z}}},
                {"rotation", i.rotation}};

            std::string text = out.dump();
            sendto(socketfd, text.data(), text.size(), 0, (sockaddr *)&from, fromLen);
        }
    }
}

bool Socket::ClientExists(Client &c)
{
    for (Client i : Clients)
    {
        std::string a = ToLower(i.name);
        std::string b = ToLower(c.name);

        return a == b;
    }
}

void Socket::AddClient(const Client &c)
{
    Clients.push_back(c);
    std::cout << "Client Added: " << c.name << "\n";
}

void Socket::UpdateClient(const Client &c)
{
    for (auto &i : Clients)
    {
        if (CompareClients(i, c))
        {
            i.position = c.position;
            i.rotation = c.rotation;
        }
    }
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