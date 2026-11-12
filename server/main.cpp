#include "includes/socket.h"
#include "includes/connection.h"
#include "includes/packet.h"
#include "includes/print.h"

constexpr int port = 8000;

int main()
{
    Socket socket(port);
    socket.Start();

    return 0;
}
