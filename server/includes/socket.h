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
    void AddClient(Client &c);
    void UpdateClient(Client &c);
    void RemoveClient(Client &client);
    bool CompareClients(Client &a, Client &b);
    bool ClientExists(Client &c);

private:
    int socketfd;
    std::vector<Client> Clients;
};