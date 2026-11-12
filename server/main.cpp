#include "includes/socket.h"
#include "includes/connection.h"
#include "includes/packet.h"
#include "includes/print.h"

int main()
{
    Socket socket(8000);
    socket.Start();

    return 0;
}
