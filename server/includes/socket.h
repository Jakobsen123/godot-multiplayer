#include <sys/socket.h>
#include <netinet/in.h>
#include <vector>
#include <unistd.h>
#include <iostream>
#include "connection.h"
#include <string>

class Socket
{
public:
    explicit Socket(const int port);
    void Start();
    void AddClient(const Client &c);
    void RemoveClient(const Client &client);
    bool CompareClients(const Client &a, const Client &b);
    bool ClientExists(Client &c);

private:
    int socketfd;
    std::vector<Client> Clients;
};