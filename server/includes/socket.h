#include <sys/socket.h>
#include <netinet/in.h>
#include <vector>
#include <unistd.h>
#include <iostream>

class Socket
{
public:
    explicit Socket(int port);
    void Start();

private:
    int socketfd;
};